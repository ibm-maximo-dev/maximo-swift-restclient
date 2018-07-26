//
//  MaximoConnector.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 * {@code MaximoConnector} is a Connector between Oslc Client and Maximo Server.
 * It provides the authentication setting, connect, basic requests and disconnect for Server.
 *
 * <p>This object can be created by {@code MaximoConnector} with {@code Options}.
 * The following code shows how to initial {@code MaximoConnector} using {@code MaximoConnector} and {@code Options}Constructor</p>
 * <pre>
 * <code>
 * var mc = MaximoConnector(options: new Options().user(user: userName)
 *  .password(password: password).mt(mtMode: true).lean(lean: false).auth(authMode: authMethod)
 *  .host(host: hostAddress).port(port: portNum))
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code MaximoConnector}</p>
 * <pre>
 * <code>
 * var op = new Options()
 * var mc = new MaximoConnector();
 * mc.options(options: op)
 * var mc = MaximoConnector(options: Options())
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to set authentication, method, cookie for session to {@code MaximoConnector}</p>
 * <pre>
 * <code>
 * mc.setAuth(uri: uri)
 * mc.setMethod(request: request, method: "POST", properties: nil)
 * mc.setCookiesForSession(url: URL)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to connect, get, create, update, merge, delete and disconnect to Maximo Server by {@code MaximoConnector}.
 * The properties can be empty</p>
 * <pre>
 * <code>
 * mc.connect()
 * var jo : [String: Any] = mc.get(uri: uri)
 * var docBytes : Data = mc.getAttachmentData(uri: uri)
 * var docBytes : Data = mc.attachedDoc(uri: uri)
 * var jp : [String: Any] = mc.getAttachmentMeta(uri: uri)
 * var jo : [String: Any] = mc.create(uri: uri, jo: jsonObject, properties: properties)
 * var jo : [String: Any] = mc.createAttachment(uri: uri, data: data, name: name, decription: decription, meta: meta)
 * var jo : [String: Any] = mc.update(uri: uri, jo: jsonObject, properties: properties)
 * var jo : [String: Any] = mc.merge(uri: uri, jo: jsonObject, properties: properties)
 * mc.delete(uri: uri)
 * mc.deleteResource(uri: uri)
 * mc.deleteAttachment(uri: uri)
 * mc.disconnect()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples  show how to get {@code ResourceSet} or {@code Resource} or {@code Attachment} by {@code MaximoConnector}</p>
 * <pre><code>
 * var rs = mc.resourceSet(osName: osName)
 * var rs = mc.resourceSet(url: url)
 * var re = mc.resource(uri: uri)
 * var att = mc.attachment(uri: uri)
 * </code></pre>
 */
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
    
    /// Init this object using a base configuration.
    public init() {
        self.options = Options()
    }

    /// Init this object with connector options.
    ///
    /// - Parameter options: Maximo connector options.
    public init(options: Options) {
        self.options = options
    }

    /// Returns the current URI.
    ///
    /// - Returns: curretn URI information.
    public func getCurrentURI() -> String {
        return self.options.getPublicURI()
    }
    
    /// Set the options.
    ///
    /// - Parameter op: Options object.
    /// - Returns: updated options object.
    public func options(op: Options) -> MaximoConnector {
        self.options = op
        return self
    }
    
    /// Get options for Maximo Connector object.
    ///
    /// - Returns: options.
    public func getOptions() -> Options {
        return self.options
    }

    /// Rerturns a Resource set object.
    ///
    /// - Returns: ResourceSet instance.
    public func resourceSet() -> ResourceSet {
        return ResourceSet(mc: self)
    }

    /// Return a ResourceSet based on it's name.
    ///
    /// - Parameter String containing osName.
    /// - Returns:
    public func resourceSet(osName: String) -> ResourceSet {
        return ResourceSet(osName: osName, mc: self)
    }

    /// Set the URL information to the ResourceSet object.
    ///
    /// - Parameter url: String containing the URL.
    /// - Returns: ResourceSet object.
    public func resourceSet(url: String) -> ResourceSet {
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

    /// Fetch a resource based on a URI and propertie's information.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - properties: Properties containing a resource information.
    /// - Returns: ResourceSet object.
    /// - Throws:
    public func resource(uri: String, properties: [String]) throws -> Resource {
        return try ResourceSet(mc: self).fetchMember(uri: uri, properties: properties)
    }
    
    /// Rertuns a AttachmentSet object based on applicatino's URI and properties.
    ///
    /// - Parameters:
    ///   - uri: Attachment's URI information.
    ///   - properties: Properties conatining a attachment's information.
    /// - Returns: AttachmentSet object.
    /// - Throws:
    public func attachment(uri: String, properties: [String]) throws -> Attachment {
        return try AttachmentSet(mc: self).fetchMember(uri: uri, properties: properties)
    }
    
    /// Rertuns a AttachementSet object based on applicatino's URI and properties containing a meta data information.
    ///
    /// - Parameter uri: Attachment's URI information.
    /// - Returns: AttachmentSet object.
    /// - Throws:
    public func attachmentDocMeta(uri: String) throws -> [String: Any] {
        return try AttachmentSet(mc: self).fetchMember(uri: uri, properties: nil).fetchDocMeta()
    }
    
    /// Check if the HTTP method used is <b>GET</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isGET() -> Bool {
        return self.httpMethod == HTTP_METHOD_GET
    }

    ///  Check if the HTTP method used is <b>POST</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isPOST() -> Bool {
        return self.httpMethod == HTTP_METHOD_POST
    }
    
    ///  Check if the HTTP method used is <b>PATCH</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isPATCH() -> Bool {
        return self.httpMethod == HTTP_METHOD_PATCH
    }

    ///  Check if the HTTP method used is <b>MERGE</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isMERGE() -> Bool {
        return self.httpMethod == HTTP_METHOD_MERGE
    }

    ///  Check if the HTTP method used is <b>DELETE</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isDELETE() -> Bool {
        return self.httpMethod == HTTP_METHOD_DELETE
    }

    ///  Check if the HTTP method used is <b>BULK</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isBULK() -> Bool {
        return self.httpMethod == HTTP_METHOD_BULK
    }

    ///  Check if the HTTP method used is <b>SYNC</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isSYNC() -> Bool {
        return self.httpMethod == HTTP_METHOD_SYNC
    }

    ///  Check if the HTTP method used is <b>MERGESYNC</b>.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isMERGESYNC() -> Bool {
        return self.httpMethod == HTTP_METHOD_MERGESYNC
    }

    ///  Check if the package is valid.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isValid() -> Bool {
        return self.valid
    }

    ///  Check if the package is set to be Lean.
    ///
    /// - Returns: boolean value: <b>TRUE</b> means <i>yes</i>, <b>FALSE</b> means <i>no</i>.
    public func isLean() -> Bool {
        return self.options.isLean()
    }

    /// Connect to Maximo Server.
    ///
    /// - Throws:
    public func connect() throws {
        try self.connect(proxyConfiguration: nil)
    }
    
    
    /// Connect to Maximo Server with a Proxy.
    ///
    /// - Parameter proxyConfiguration: Proxy configuration description.
    /// - Throws:
    public func connect(proxyConfiguration : [String: String]?) throws {
/*
        if isValid() {
            throw OslcError.connectionAlreadyEstablished
        }
*/
        if !isValid() {
            cookies.removeAll()
        
            let uri: String = self.options.getAppURI()
            var request: URLRequest? = self.setAuth(uri: uri)
            if request == nil {
                throw OslcError.invalidRequest
            }
            else {
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
                var errorString : String?
                var responseCode : Int? = 0
                self.valid = false
                let task = session.dataTask(with: request!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if (error != nil) {
                        responseCode = 0
                        errorString = "HTTP connection failure: " + (error?.localizedDescription)!
                        print(errorString)
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        responseCode = httpResponse.statusCode
                        if (200...299).contains(httpResponse.statusCode), let fields = httpResponse.allHeaderFields as? [String : String] {
                            self.valid = true
                            /*
                            if let data = data, let str = String(data: data, encoding: .utf8) {
                                print ("HTTP Data: \(str)")
                            }
                            */
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
                        else {
                            errorString = "Server Error"
                        }
                    }
                    else {
                        responseCode = 999
                        errorString = "HTTP Response : Illegal Response: \(String(describing: response))"
                    }
                    semaphore.signal()
                })
                task.resume()
                
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                if  !self.valid {
                    if responseCode == 0, errorString != nil {
                        throw OslcError.loginFailure(message: errorString!)
                    }
                    else {
                        throw OslcError.serverError(code: responseCode!, message: errorString!)
                    }
                }
            }
        }
    }

    /// Set the authentication process based on a resource URI.
    ///
    /// - Parameter uri: String containing the URI information.
    /// - Returns: URLRequest object or nil if something is incompatible.
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
    
    /// Define the HTTP method to be used based.
    ///
    /// - Parameters:
    ///   - request: URLRequest object.
    ///   - method: String containing the METHOD description (i.e.GET, POST, PATCH, MERGE, DELETE, BULK, SYNC or MERGESYNC).
    ///   - properties: properties containing the resource information.
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

    /// Load DocumentData.
    ///
    /// - Parameter uri: Attachment's URI information.
    /// - Returns: Data information or HTTP response code.
    /// - Throws:
    public func getAttachmentData(uri: String) throws -> Data {
        return try self.getAttachmentData(uri: uri, headers: nil)
    }

    /// Retrieve the attachment metada based on resource's URI and headers information.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - headers: Resource's header information.
    /// - Returns: Data information or HTTP response code.
    /// - Throws:
    public func getAttachmentData(uri: String, headers: [String: Any]?) throws -> Data {
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
        self.setMethod(request: &request, method: "GET", properties: nil)
        
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

        return dataReceived!
    }

    /// Handle with the GET HTTP method.
    ///
    /// - Parameter uri: Resource's URI.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func get(uri: String) throws -> [String: Any] {
        return try self.get(uri: uri, headers: nil)
    }

    /// Handle with the GET HTTP method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - headers: Resource header information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func get(uri: String, headers: [String: Any]?) throws -> [String: Any] {
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
        self.setMethod(request: &request, method: "GET", properties: nil)
        
        if headers != nil && !(headers!.isEmpty) {
            self.setHeaders(request: &request, headers: headers!)
        }

        var dataReceived : Data?
        var responseError : Error?
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            dataReceived = data

            if dataReceived != nil {
                let dataAsString : String? = String(data: dataReceived!, encoding: String.Encoding.utf8)
//                print(dataAsString!)
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

    
    /// Fetch Group By data.
    ///
    /// - Parameter uri: Resource/Attachment's URI information.
    /// - Returns: JSON containing the information grouped by URI or an HTTP response code.
    /// - Throws:
    public func groupBy(uri: String) throws -> [Any] {
        return try self.groupBy(uri: uri, headers: nil)
    }

    /// Fetch Group By data.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - headers: headers information.
    /// - Returns: JSON containing the information grouped by URI or an HTTP response code.
    /// - Throws:
    public func groupBy(uri: String, headers: [String: Any]?) throws -> [Any] {
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
        self.setMethod(request: &request, method: "GET", properties: nil)
        
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

        var json : [Any] = []
        if dataReceived != nil {
            json = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [Any]
        }
        
        return json
    }

    /// Create new Resource.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: Resource's JSON data information.
    ///   - properties: Resource's properties information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func create(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.create(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    /// Create a new Resource.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: Resource's JSON data information.
    ///   - headers: Header's information.
    ///   - properties: Resource's properties information.
    /// - Returns: JSON containing the information or an HTTP response code
    /// - Throws:
    public func create(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
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

        // Converting JSON object to Data
        let postData : Data = try JSONSerialization.data(withJSONObject: jo, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "POST", properties: properties)
        request.httpBody = postData

        if headers != nil && !(headers!.isEmpty) {
            self.setHeaders(request: &request, headers: headers!)
        }
        
        var dataReceived : Data?
        var responseError : Error?
        var errorString : String?
        var responseCode : Int? = 0
        self.valid = false
        var json : [String: Any] = [:]
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                responseError = error
                responseCode = 0
                errorString = "HTTP connection failure: " + (error?.localizedDescription)!
                print(errorString as Any)
                json["error"] = errorString

            }
            else if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                    if (200...299).contains(httpResponse.statusCode) {
                        let href : String = httpResponse.allHeaderFields["Location"] as! String
                        if self.options.isLean() {
                            json["rdf:resource"] = href
                        } else {
                            json["href"] = href
                        }
                    }
                    else  {
                        if let dataReceived = data {
                            json = try! JSONSerialization.jsonObject(with: dataReceived, options: []) as! [String : Any]
                            let dataAsString : String? = String(data: dataReceived, encoding: String.Encoding.utf8)
                            errorString = dataAsString
                        }
                    }
                }
            else {
                responseCode = 999
                errorString = "HTTP Response : Illegal Response: \(String(describing: response))"
                json["error"] = errorString
            }
            semaphore.signal()
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if (responseCode! >= 400) {
            if responseError != nil {
                throw responseError!
            }
            else {
                throw OslcError.serverError(code: responseCode!, message: errorString!)
            }
        }
        
        return json
    }

    /// Create new attachment.
    ///
    /// - Parameters:
    ///   - uri: Attachement URI's information.
    ///   - data: Attachment data.
    ///   - name: Attachment's name.
    ///   - description: Attachement's description.
    ///   - meta: Attachment's meta data information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func createAttachment(uri: String, data: Data, name: String, description: String, meta: String) throws -> [String: Any] {
        return try self.createAttachment(uri: uri, data: data, name: name, description: description, meta: meta, headers: nil)
    }

    /// Create new attachment.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI
    ///   - data: Attachment's data.
    ///   - name: Attachment's name.
    ///   - description: Attachment's description.
    ///   - meta: Attachment's meta data.
    ///   - headers: Attachment's headers.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func createAttachment(uri: String, data: Data, name: String, description: String, meta: String, headers: [String: Any]?) throws -> [String: Any]
    {
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
        self.setMethod(request: &request, method: "POST", properties: nil)
        request.httpBody = data
        request.addValue(name, forHTTPHeaderField: "slug")
        request.addValue(description, forHTTPHeaderField: "x-document-description")
        request.addValue(meta, forHTTPHeaderField: "x-document-meta")

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
        let href : String = (task.response as! HTTPURLResponse).allHeaderFields["Location"] as! String
        if self.options.isLean() {
            json["rdf:resource"] = href
        } else {
            json["href"] = href
        }

        return json
    }

    /// Handle with BULK HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - ja: AnyObject containing the resource's information.
    /// - Returns: AnyObject containing the information or an HTTP response code.
    /// - Throws:
    public func bulk(uri: String, ja: [Any]) throws -> [Any] {
        return try bulk(uri: uri, ja: ja, headers: nil)
    }

    /// Handle with BULK HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - ja: AnyObject containing the resource's information.
    ///   - headers: Resource header's information.
    /// - Returns: AnyObject containing the information or an HTTP response code.
    /// - Throws:
    public func bulk(uri: String, ja: [Any], headers: [String: Any]?) throws -> [Any] {
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
        
        // Converting JSON object to Data
        let postData : Data = try JSONSerialization.data(withJSONObject: ja, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "BULK", properties: nil)
        request.httpBody = postData
        
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
        
        var jarray : [Any] = []
        if (resCode == 204) {
            return jarray
        }
        
        if dataReceived != nil {
            jarray = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [Any]
        }

        return jarray
    }

    
    /// Update Resource.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - properties: Resource's properties information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func update(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.update(uri: uri, jo: jo, headers: nil, properties: properties);
    }

    /// Update the Resource.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - headers: Resource's header information.
    ///   - properties: Resource's properties information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func update(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
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
        
        // Converting JSON object to Data
        let postData : Data = try JSONSerialization.data(withJSONObject: jo, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "PATCH", properties: properties)
        request.httpBody = postData
        
        if headers != nil && !(headers!.isEmpty) {
            self.setHeaders(request: &request, headers: headers!)
        }
        
        var responseError : Error?
        var responseCode : Int = -1
        var errorString : String?
        var json : [String: Any] = [:]
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                responseError = error
                responseCode = 0
                errorString = "HTTP connection failure: " + (error?.localizedDescription)!
                print(errorString as Any)
            }
            else if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                if let dataReceived = data {
                    // Error from the calls are sent in the body of the response
                    if  httpResponse.statusCode >= 400 {
                        let json = try! JSONSerialization.jsonObject(with: dataReceived, options: []) as! [String : Any]
                        let error = json["Error"] as! [String : Any]
                        errorString = error["message"] as? String
                    }
                    else if httpResponse.statusCode != 204 {
                        json = try! JSONSerialization.jsonObject(with: dataReceived, options: []) as! [String : Any]
                    }
                }
            }
            else {
                responseCode = 999
                errorString = "HTTP Response : Illegal Response: \(String(describing: response))"
            }
            semaphore.signal()
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if (responseCode >= 400) || (responseCode == 0){
            if responseError != nil {
                throw responseError!
            }
            else {
                throw OslcError.serverError(code: responseCode, message: errorString!)
            }
        }
        return json
    }
    
    /// Handle MERGE HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func merge(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    /// Handle MERGE HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - headers: Header's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func merge(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
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
        
        // Converting JSON object to Data
        let postData : Data = try JSONSerialization.data(withJSONObject: jo, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "MERGE", properties: properties)
        request.httpBody = postData
        
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
        if (resCode == 204) {
            return json
        }
        
        if dataReceived != nil {
            json = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [String : Any]
        }
        
        return json
    }
    
    /// Handle MERGESYNC HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func mergeSync(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }

    /// Handle MERGESYNC HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - headers: Header's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func mergeSync(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
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
        
        // Converting JSON object to Data.
        let postData : Data = try JSONSerialization.data(withJSONObject: jo, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "MERGESYNC", properties: properties)
        request.httpBody = postData

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
        if (resCode == 204) {
            return json
        }
        
        if dataReceived != nil {
            json = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [String : Any]
        }
        
        return json
    }

    /// Handle SYNC HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information.
    ///   - jo: JSON schema containing resource's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func sync(uri: String, jo: [String: Any], properties: [String]?) throws -> [String: Any] {
        return try self.merge(uri: uri, jo: jo, headers: nil, properties: properties);
    }
    
    /// Handle MERGESYNC HTTP's method.
    ///
    /// - Parameters:
    ///   - uri: Resource's URI information
    ///   - jo: JSON schema containing resource's information.
    ///   - headers: Header's information.
    ///   - properties: properties containing the resource's information.
    /// - Returns: JSON containing the information or an HTTP response code.
    /// - Throws:
    public func sync(uri: String, jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> [String: Any] {
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
        
        // Converting JSON object to Data.
        let postData : Data = try JSONSerialization.data(withJSONObject: jo, options: [])
        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "SYNC", properties: properties)
        request.httpBody = postData
        
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
        if resCode == 204 {
            return json;
        }

        if properties != nil && properties!.count > 0 {
            let href : String = (task.response as! HTTPURLResponse).allHeaderFields["Location"] as! String
            if self.options.isLean() {
                json["rdf:resource"] = href
            } else {
                json["href"] = href
            }
        } else {
            if dataReceived != nil {
                json = try! JSONSerialization.jsonObject(with: dataReceived!, options: []) as! [String : Any]
            }
        }
        
        return json
    }

   
    /// Delete a Resource or an Attachment.
    ///
    /// - Parameter uri: Resource/Attachment's URI information to be deleted.
    /// - Throws:
    public func delete(uri: String) throws {
        try delete(uri: uri, headers: nil)
    }

    /// Delete a Resource or an Attachment.
    ///
    /// - Parameters:
    ///   - uri: Resource/Attachment's URI information to be deleted.
    ///   - headers: Resource/Attachment's headers information to be deleted.
    /// - Throws:
    public func delete(uri: String, headers: [String: Any]?) throws {
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
        
        let httpURL = URL(string: requestURI)
        if cookies.isEmpty {
            try self.connect()
        }
        self.setCookiesForSession(url: httpURL!)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "DELETE", properties: nil)
        
        if headers != nil && !(headers!.isEmpty) {
            self.setHeaders(request: &request, headers: headers!)
        }
        let semaphore = DispatchSemaphore(value: 0)
        var responseError : Error?
        var responseCode : Int = -1
        var errorString : String?
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                responseError = error
                responseCode = 0
                errorString = "HTTP connection failure: " + (error?.localizedDescription)!
                print(errorString as Any)
            }
            else if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                if  httpResponse.statusCode >= 400 {
                    if let dataReceived = data {
                        let json = try! JSONSerialization.jsonObject(with: dataReceived, options: []) as! [String : Any]
                        let error = json["Error"] as! [String : Any]
                        errorString = error["message"] as? String
                    }
                }
            }
            else {
                responseCode = 999
                errorString = "HTTP Response : Illegal Response: \(String(describing: response))"
            }
            
            responseError = error
            semaphore.signal()
        } )
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if (responseCode >= 400) || (responseCode == 0){
            if responseError != nil {
                throw responseError!
            }
            else {
                throw OslcError.serverError(code: responseCode, message: errorString!)
            }
        }
    }

    /// Delete a Resource.
    ///
    /// - Parameter uri: Resource's URI information to be deleted.
    /// - Throws:
    public func deleteResource(uri: String) throws {
        try self.delete(uri: uri)
    }
    
    /// Delete an Attachment.
    ///
    /// - Parameter uri: Attachment's URI information to be deleted.
    /// - Throws: <#throws value description#>
    public func deleteAttachment(uri: String) throws {
        try self.delete(uri: uri)
    }

    /// Set headers for a Resource ro an Attchament.
    ///
    /// - Parameters:
    ///   - request: URLRequest object.
    ///   - headers: header's information.
    func setHeaders(request: inout URLRequest, headers: [String: Any]) {
        for (key, value) in headers {
            let valueAsString = Util.stringValue(value: value)
            request.setValue(valueAsString, forHTTPHeaderField: key)
        }
    }

    /// Set Cookies for a Resource or an Attchament.
    ///
    /// - Parameter url: Resource/Attachment's URL information.
    func setCookiesForSession(url: URL) {
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: url)
    }

   
    /// Get the last response code.
    ///
    /// - Returns: HTTP response code.
    public func getLastResponseCode() -> Int {
        return lastResponseCode
    }

    /// Disconnect from Maximo Server.
    ///
    /// - Throws:
    public func disconnect() throws {
        var logout = self.options.getPublicURI() + "/logout"
        if self.getOptions().isMultiTenancy() {
            logout += "?&_tenantcode=" + self.getOptions().getTenantCode()
        }

        let semaphore = DispatchSemaphore(value: 0)
        let httpURL = URL(string: logout)
        var request = URLRequest(url : httpURL!)
        self.setMethod(request: &request, method: "GET", properties: nil)
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
