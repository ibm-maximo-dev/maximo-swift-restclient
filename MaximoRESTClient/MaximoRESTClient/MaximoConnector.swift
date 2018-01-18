//
//  MaximoConnector.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public class MaximoConnector {

    var options : Options
    var valid : Bool = false
    var debug : Bool = false
    var lastResponseCode : Int = 0
    var cookies : [HTTPCookie] = []

    let HTTP_METHOD_POST = "POST";
    let HTTP_METHOD_GET = "GET";
    let HTTP_METHOD_PATCH = "PATCH";
    let HTTP_METHOD_MERGE = "MERGE";
    let HTTP_METHOD_DELETE = "DELETE";
    let HTTP_METHOD_BULK = "BULK";
    let HTTP_METHOD_SYNC = "SYNC";
    let HTTP_METHOD_MERGESYNC = "MERGESYNC";
    
    var httpMethod : String = "GET";// by default it is get
    
    init() {
        self.options = Options()
    }

    public init(options: Options) {
        self.options = options
    }

    func getCurrentURI() -> String {
        return self.options.getPublicURI()
    }
    
    func options(op: Options) -> MaximoConnector {
        self.options = op
        return self
    }
    
    func getOptions() -> Options {
        return self.options
    }

    public func resourceSet() -> ResourceSet {
        return ResourceSet(mc: self)
    }

    public func resourceSet(osName: String) -> ResourceSet {
        return ResourceSet(osName: osName, mc: self)
    }

    func resourceSet(url: String) -> ResourceSet {
        var strs = url.split(separator: "/")
        var osName : String?
        var index : Int = 0
        for str in strs {
            if str == "os" {
                osName = String(strs[index + 1])
                break
            }
            index += 1
        }

        return ResourceSet(osName: osName, mc: self)
    }

    func resource(uri: String, properties: [String]) throws -> Resource {
        return try ResourceSet(mc: self).fetchMember(uri: uri, properties: properties)
    }
    
    func attachment(uri: String, properties: [String]) throws -> Attachment {
        return try AttachmentSet(mc: self).fetchMember(uri: uri, properties: properties)
    }
    
    func attachmentDocMeta(uri: String) throws -> [String: Any] {
        return try AttachmentSet(mc: self).fetchMember(uri: uri, properties: nil).fetchDocMeta()
    }
    
    func isGET() -> Bool {
        return self.httpMethod == HTTP_METHOD_GET
    }

    func isPOST() -> Bool {
        return self.httpMethod == HTTP_METHOD_POST
    }
    
    func isPATCH() -> Bool {
        return self.httpMethod == HTTP_METHOD_PATCH
    }

    func isMERGE() -> Bool {
        return self.httpMethod == HTTP_METHOD_MERGE
    }

    func isDELETE() -> Bool {
        return self.httpMethod == HTTP_METHOD_DELETE
    }

    func isBULK() -> Bool {
        return self.httpMethod == HTTP_METHOD_BULK
    }

    func isSYNC() -> Bool {
        return self.httpMethod == HTTP_METHOD_SYNC
    }

    func isMERGESYNC() -> Bool {
        return self.httpMethod == HTTP_METHOD_MERGESYNC
    }

    func isValid() -> Bool {
        return self.valid
    }

    func isLean() -> Bool {
        return self.options.isLean()
    }

    /**
     * Connect to Maximo Server
     *
     * @throws IOException
     * @throws OslcException
     */
    public func connect() throws {
        try self.connect(proxyConfiguration: nil)
    }
    
    /**
     * Connect to Maximo Server with Proxy
     *
     * @throws IOException
     * @throws OslcException
     */
    func connect(proxyConfiguration : [String: String]?) throws {
        if isValid() {
            throw OslcError.connectionAlreadyEstablished
        }
        cookies.removeAll()
    
        let uri: String = self.options.getAppURI()
        var request : URLRequest? = self.setAuth(uri: uri)
        if request != nil {
            if !self.options.isFormAuth() {
                self.setMethod(request: &request!, method: "GET", properties: nil)
            }

            let configuration = URLSessionConfiguration()
            var session : URLSession
            if proxyConfiguration != nil {
                configuration.connectionProxyDictionary = proxyConfiguration
                session = URLSession(configuration: configuration)
            } else {
                session = URLSession.shared
            }

            let semaphore = DispatchSemaphore(value: 0)
            let connectionHandler: (Data?, URLResponse?, Error?) -> Void = {
                (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
                    HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
                    for cookie in cookies {
                        var cookieProperties = [HTTPCookiePropertyKey: Any]()
                        cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                        cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                        cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                        cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                        cookieProperties[HTTPCookiePropertyKey.version] = cookie.version
                        cookieProperties[HTTPCookiePropertyKey.expires] = cookie.expiresDate
                        
                        let newCookie = HTTPCookie(properties: cookieProperties)
                        self.cookies.append(newCookie!)
                    }
                }
                
                if self.cookies.isEmpty || error != nil {
                    print("HTTP connection failure: " + error.debugDescription)
                }

                semaphore.signal()
            }

            let task = session.dataTask(with: request!, completionHandler: connectionHandler)
            task.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)

            var i : Int = -1
            if (task.response as? HTTPURLResponse) != nil {
                i = (task.response as! HTTPURLResponse).statusCode
            }
            lastResponseCode = i
            
            if  i == -1 {
                throw OslcError.invalidRequest
            }

            if i < 400 {
                self.valid = true
            }
        }
    }

    func setAuth(uri: String) -> URLRequest? {
        if self.options.getUser() != nil && self.options.getPassword() != nil {
            if options.isBasicAuth() {
                let httpURL = URL(string: uri)
                var request = URLRequest(url : httpURL!)

                let credentials = self.options.getUser()! + ":" + self.options.getPassword()!
                let encodedUserPwd : String = Util.encodeBase64(value: credentials)
                request.setValue("Basic " + encodedUserPwd, forHTTPHeaderField: "Authorization")
                return request
            } else if options.isMaxAuth() {
                let httpURL = URL(string: uri)
                var request = URLRequest(url : httpURL!)
                
                let credentials = self.options.getUser()! + ":" + self.options.getPassword()!
                let encodedUserPwd : String = Util.encodeBase64(value: credentials)
                request.setValue(encodedUserPwd, forHTTPHeaderField: "maxauth")
                return request
            } else if options.isFormAuth() {
                var appURI : String = uri
                appURI += "/j_security_check";
                
                let httpURL = URL(string: uri)

                var request = URLRequest(url : httpURL!)

                request.httpMethod = "POST"
                request.setValue("text/html,application/xhtml+xml,application/ml", forHTTPHeaderField: "Accept")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("keep-alive", forHTTPHeaderField: "Connection")
                request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")

                var postContent = String()
                postContent.append("j_username=")
                postContent.append(self.options.getUser()!)
                postContent.append("&j_password=")
                postContent.append(self.options.getPassword()!)
                request.httpBody = postContent.data(using: .utf8)

                return request
            }
        }
        return nil
    }
    
    func setMethod(request: inout URLRequest, method: String, properties: [String]?) {
        self.httpMethod = method
        if self.isGET() {
            request.httpMethod = HTTP_METHOD_GET
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
        } else if self.isPOST() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
        } else if self.isPATCH() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
            request.setValue(HTTP_METHOD_PATCH, forHTTPHeaderField: "x-method-override");
        } else if self.isMERGE() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
            request.setValue(HTTP_METHOD_PATCH, forHTTPHeaderField: "x-method-override");
            request.setValue(HTTP_METHOD_MERGE, forHTTPHeaderField: "patchtype");
        } else if self.isBULK() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
            request.setValue(HTTP_METHOD_BULK, forHTTPHeaderField: "x-method-override");
        } else if self.isSYNC() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
            request.setValue(HTTP_METHOD_SYNC, forHTTPHeaderField: "x-method-override");
        } else if self.isMERGESYNC() {
            request.httpMethod = HTTP_METHOD_POST
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
            request.setValue(HTTP_METHOD_SYNC, forHTTPHeaderField: "x-method-override");
            request.setValue(HTTP_METHOD_MERGE, forHTTPHeaderField: "patchtype");
        } else if self.isDELETE() {
            request.httpMethod = HTTP_METHOD_DELETE
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            request.setValue(self.options.getPublicURI(), forHTTPHeaderField: "x-public-uri")
        }

        if properties != nil {
            for property in properties! {
                request.addValue(property, forHTTPHeaderField: "Properties")
            }
        }
    }
    
    func getAttachmentData(uri: String) throws -> Data {
        return try self.getAttachmentData(uri: uri, headers: nil)
    }

    func getAttachmentData(uri: String, headers: [String: Any]?) throws -> Data {
        // TODO: Implement this method
        return Data()
    }

    public func get(uri: String) throws -> [String: Any] {
        return try self.get(uri: uri, headers: nil)
    }

    func get(uri: String, headers: [String: Any]?) throws -> [String: Any] {
        if !isValid() {
            throw OslcError.invalidConnectorInstance
        }
        
        var publicHost = self.options.getHost()
        if self.options.getPort() != -1 {
            publicHost += ":" + String(self.options.getPort())
        }
        var requestURI = uri
        if !uri.contains(publicHost) {
            let tempURL = URL(string: uri)
            var currentHost : String = (tempURL?.host)!
            if tempURL?.port != -1 {
                currentHost += ":" + String(describing: tempURL?.port)
            }
            requestURI = uri.replacingOccurrences(of: currentHost, with: publicHost)
        }

        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        request.httpMethod = "GET"
        
        if headers != nil && !(headers!.isEmpty) {
            self.setHeaders(request: &request, headers: headers!)
        }

        var dataReceived : Data?
        var responseError : Error?
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            dataReceived = data

            if dataReceived != nil {
                let dataAsString : String? = String(data: dataReceived!, encoding: String.Encoding.utf8)
                print(dataAsString!)
            }
            
            responseError = error
            semaphore.signal()
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        var resCode : Int = -1
        if (task.response as? HTTPURLResponse) != nil {
            resCode = (task.response as! HTTPURLResponse).statusCode
        }
        lastResponseCode = resCode;
        if (resCode >= 400) {
            if responseError != nil {
                throw responseError!
            }
        }

        var json : [String: Any] = [:]
        if dataReceived != nil {
            json = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [String : Any]
        }

        return json
    }

    /**
     *
     * Fetch Group By data
     *
     * @param uri
     * @return JsonArray
     * @throws IOException
     * @throws OslcException
     */
    func groupBy(uri: String) throws -> [Any] {
        return try self.groupBy(uri: uri, headers: nil)
    }

    func groupBy(uri: String, headers: [String: Any]?) throws -> [Any] {
        // TODO: Implement this method
        return []
    }

    func create(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.create(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    func create(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
        // TODO: Implement this method
        return [:]
    }

    func createAttachment(uri: String, data: Data, name: String, description: String, meta: String) throws -> [String: Any] {
        return try self.createAttachment(uri: uri, data: data, name: name, description: description, meta: meta, headers: nil)
    }

    func createAttachment(uri: String, data: Data, name: String, description: String, meta: String, headers: [String: Any]?) throws -> [String: Any] {
        // TODO: Implement this method
        return [:]
    }

    func bulk(uri: String, ja: [Any]) throws -> [Any] {
        return try bulk(uri: uri, ja: ja, headers: nil)
    }

    func bulk(uri: String, ja: [Any], headers: [String: Any]?) throws -> [Any] {
        // TODO: Implement this method
        return []
    }

    /**
     * Update the Resource
     * @param jo
     * @throws IOException
     * @throws OslcException
     */
    func update(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.update(uri: uri, jo: jo, headers: nil, properties: properties);
    }

    func update(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
        // TODO: Implement self method
        return [:]
    }
    
    func merge(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    func merge(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
        // TODO: Implement self method
        return [:]
    }
    
    func mergeSync(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }

    func mergeSync(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
        // TODO: Implement self method
        return [:]
    }

    func sync(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    func sync(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
        // TODO: Implement self method
        return [:]
    }

    /**
     * Delete the resource/attachment
     * @throws IOException
     * @throws OslcException
     */
    func delete(uri: String) throws {
        try delete(uri: uri, headers: nil)
    }

    func delete(uri: String, headers: [String: Any]?) throws {
        //TODO: Implement this method
    }

    func deleteResource(uri: String) throws {
        try self.delete(uri: uri)
    }
    
    func deleteAttachment(uri: String) throws {
        try self.delete(uri: uri)
    }

    func setHeaders(request: inout URLRequest, headers: [String: Any]) {
        for (key, value) in headers {
            let valueAsString = Util.stringValue(value: value)
            request.setValue(valueAsString, forHTTPHeaderField: key)
        }
    }

    func setCookiesForSession(url: URL) {
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: url)
    }

    /**
     * Get the last response code
     */
    func getLastResponseCode() -> Int {
        return lastResponseCode
    }

    /**
     * Disconnect from Maximo Server
     * @throws IOException
     */
    func disconnect() throws {
        var logout = self.options.getPublicURI() + "/logout"
        if self.getOptions().isMultiTenancy() {
            logout += "?&_tenantcode=" + self.getOptions().getTenantCode()
        }

        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: logout)
        var request = URLRequest(url : httpURL!)
        request.httpMethod = "GET"
        self.setCookiesForSession(url: httpURL!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            semaphore.signal()
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        if (task.response as? HTTPURLResponse) != nil {
            lastResponseCode = (task.response as! HTTPURLResponse).statusCode
        }
        self.valid = false
    }
}
