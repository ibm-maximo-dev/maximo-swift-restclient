//
//  ResourceSet.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 *
 * {@code ResourceSet} implement the operations on {@code ResourceSet}. It
 * provides the set of Resource.
 *
 * <p>
 * This object can be created by {@code MaximoConnector}. The following code
 * shows how to create {@code MaximoConnector}
 * </p>
 *
 * <pre>
 * <code>
 * var rs = mc.resourceSet(osName: osName)
 * var rs = mc.resourceSet(url: URL)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code ResourceSet}
 * </p>
 *
 * <pre>
 * <code>
 * var rs = ResourceSet(osName: osName)
 * var rs = ResourceSet(mc: maximoConnector)
 * var rs = ResourceSet(osName: osName, mc: maximoConnector)
 * var rs = ResourceSet(url: URL, mc: maximoConnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to set {@code ResourceSet} data from
 * {@code ResourceSet}
 * </p>
 *
 * <pre>
 * <code>
 * rs._where(whereClause: queryWhere).select(selectClause: querySelect).hasTerms(terms: terms).pageSize(pageSize: pageSize)
 * rs.paging(type: true)
 * rs.stablePaging(type: true)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to fetch, load, reload, go to next page, go
 * back to previous page, get savedQuery for {@code ResourceSet} data
 * </p>
 *
 * <pre>
 * <code>
 * rs.fetch(options: mapOptions)
 * rs.load()
 * rs.reload()
 * rs.nextPage()
 * rs.previousPage()
 * rs.savedQuery(qsaved: savedQuery)
 * rs.savedQuery(name: name, paramValues: paramValues)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to get {@code ResourceSet} data from
 * {@code ResourceSet}
 * </p>
 *
 * <pre>
 * <code>
 * var jo : [String: Any] = rs.toJSON()
 * var jodata : Data = rs.toJSONBytes()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to create, get and delete {@code Resource}
 * from {@code ResourceSet}
 * </p>
 *
 * <pre>
 * <code>
 * var rs = fetchMember(uri: uri, properties: properties)
 * var rs = member(index: index)
 * var rs = create(jo: jsonObject, properties: properties)
 * </code>
 * </pre>
 *
 * <p>
 * The following example shows how to get the this page size from
 * {@code ResourceSet}
 * </p>
 *
 * <pre>
 * <code>
 * var count : Int = rs.count()
 * var totalCount : Int = rs.totalCount()
 * var totalCount : Int = rs.totalCount(fromServer: true)
 * </code>
 * </pre>
 */
public class ResourceSet {
    
    var pageSize : Int = -1
    var osName : String?
    var whereClause : String?
    var selectClause : String?
    var osURI : String?
    var publicURI : String?
    var appURI : String?
    var orderBy : [String] = []
    var savedQuery : String?
    var strbWhere : String?
    var searchTerms : String?
    var searchAttributes : String?
    var jsonObject : [String: Any]?
    var mc : MaximoConnector?
    var paging : Bool = false
    var stablePaging : Bool = false
    var isLoaded : Bool = false
    var jsonArray : [Any]?

    public init(osName: String) {
        self.osName = osName
    }
    
    public init(mc: MaximoConnector) {
        self.mc = mc
    }

    public init(osName: String?, mc: MaximoConnector) {
        self.osName = osName
        self.publicURI = mc.getCurrentURI()
        self.mc = mc
    }

    public init(publicURI: String, mc: MaximoConnector) {
        self.mc = mc;
        self.publicURI = publicURI
    }

    /**
     * Get current URI
     */
    public func getAppURI() -> String? {
        return self.appURI
    }
    
    public func getPublicURI() -> String? {
        return self.publicURI
    }
    
    public func getOsURI() -> String? {
        return self.osURI
    }

    /**
     * Get ResourceSet data in JSON
     *
     * @throws
     */
    public func toJSON() -> [String: Any]? {
        return self.jsonObject
    }

    /**
     * Get ResourceSet data in JSONBytes
     *
     * @throws
     */
    public func toJSONBytes() throws -> Data {
        let data = try JSONEncoder().encode(self.jsonObject)
        return data
    }

    // Set whereClause
    public func _where(whereClause: String) -> ResourceSet {
        self.whereClause = whereClause
        return self
    }

    public func _where(_where: QueryWhere) -> ResourceSet {
        self.whereClause = _where.whereClause()
        return self
    }
    
    public func searchAttributes(attributes: [String]) -> ResourceSet {
        self.searchAttributes = String()
        for attribute in attributes {
            self.searchAttributes?.append("" + attribute + ",")
        }
        return self
    }

    public func hasTerms(terms: [String]) -> ResourceSet {
        self.searchTerms = String()
        for term in terms {
            self.searchTerms?.append("\"" + term + "\",")
        }
        return self
    }
    
    // Set selectClause
    public func select(selectClause: [String]) -> ResourceSet {
        self.selectClause = QuerySelect().select(selectClause: selectClause)
        return self
    }
    
    public func pageSize(pageSize: Int) -> ResourceSet {
        self.pageSize = pageSize
        return self
    }
    
    // &oslc.paging=true - if paging is false - do not add the query parameter
    public func paging(type: Bool) -> ResourceSet {
        self.paging = type
        return self
    }

    public func stablePaging(type: Bool) -> ResourceSet {
        self.stablePaging = type
        return self
    }
    
    public func orderBy(orderByProperties: [String]) -> ResourceSet {
        for property in orderByProperties {
            self.orderBy.append(property)
        }
        return self
    }

    /**
     * Fetching the data for ResourceSet
     *
     * @throws
     */
    public func fetch() throws -> ResourceSet {
        _ = try self.fetch(options: nil)
        return self
    }

    /**
     * Fetching the data for ResourceSet with arbitrary parameters
     *
     * @param additionalParams
     * @throws
     */
    public func fetchWithAddtionalParams(additionalParams: [String: Any]) throws -> ResourceSet {
        return try self.fetchWithAddtionalHeadersAndParams(additionalParams: additionalParams, additionalHeaders: nil);
    }
    
    /**
     * Fetching the data for ResourceSet with arbitrary headers
     *
     * @param additionalHeaders
     * @throws
     */
    public func fetchWithAddtionalHeaders(additionalHeaders: [String: Any]) throws -> ResourceSet {
        return try self.fetchWithAddtionalHeadersAndParams(additionalParams: nil, additionalHeaders: additionalHeaders);
    }
    
    /**
     * Fetching the data for ResourceSet with arbitrary parameters and headers
     *
     * @param additionalParams
     * @param additionalHeaders
     * @throws
     */
    public func fetchWithAddtionalHeadersAndParams(additionalParams: [String: Any]?, additionalHeaders: [String: Any]?) throws -> ResourceSet {
        _ = try self.buildURI()
        var strb = String()
        strb.append(self.appURI!)
        if !self.appURI!.contains("?") {
            strb.append("?")
        }
        if additionalParams != nil && !additionalParams!.isEmpty {
            for (key, value) in additionalParams! {
                var singleParam = String()
                singleParam.append("&")
                singleParam.append(key)
                singleParam.append("=")
                singleParam.append(Util.urlEncode(value: value as! String))
                strb.append(singleParam)
            }
        }
        self.appURI = strb
        if additionalHeaders != nil && !additionalHeaders!.isEmpty {
            self.jsonObject = try self.mc?.get(uri: self.appURI!, headers: additionalHeaders)
        } else {
            self.jsonObject = try self.mc?.get(uri: self.appURI!);
        }
        if self.jsonObject!["rdfs:member"] != nil {
            self.jsonArray = self.jsonObject?["rdfs:member"] as? [Any]
        } else {
            self.jsonArray = self.jsonObject?["member"] as? [Any]
        }
        isLoaded = true;
        return self;
    }

    public func fetch(options: [String: Any]?) throws -> ResourceSet {
        _ = try self.buildURI();
        self.jsonObject = try self.mc?.get(uri: self.appURI!)
        if self.jsonObject!["rdfs:member"] != nil {
            self.jsonArray = self.jsonObject?["rdfs:member"] as? [Any]
        } else {
            self.jsonArray = self.jsonObject?["member"] as? [Any]
        }
        isLoaded = true
        return self
    }

    /**
     * Go to nextPage
     * @throws
     */
    public func nextPage() throws -> ResourceSet {
        if self.hasNextPage()
        {
            if self.jsonObject!["responseInfo"] != nil
            {
                var responseInfoObj : [String: Any] = self.jsonObject!["responseInfo"] as! [String : Any]
                if responseInfoObj["nextPage"] != nil
                {
                    var nextPageObj : [String: Any] = responseInfoObj["nextPage"] as! [String : Any]
                    self.appURI = nextPageObj["href"] as? String
                }
            }
            else if self.jsonObject!["oslc:responseInfo"] != nil
            {
                var responseInfoObj : [String: Any] = self.jsonObject!["oslc:responseInfo"] as! [String : Any]
                if responseInfoObj["oslc:nextPage"] != nil
                {
                    var nextPageObj : [String: Any] = responseInfoObj["oslc:nextPage"] as! [String : Any]
                    self.appURI = nextPageObj["rdf:resource"] as? String
                }
            }
        }
        else
        {
            return self
        }
    
        self.jsonObject = try self.mc?.get(uri: self.appURI!);
        if self.jsonObject!["rdfs:member"] != nil
        {
            self.jsonArray = self.jsonObject?["rdfs:member"] as? [Any]
        }
        else
        {
            self.jsonArray = self.jsonObject?["member"] as? [Any]
        }
        return self;
    }

    public func hasNextPage() -> Bool {
        if self.jsonObject!["responseInfo"] != nil
        {
            var responseInfoObj : [String: Any] = self.jsonObject!["responseInfo"] as! [String : Any]
            return responseInfoObj["nextPage"] != nil
        }
        else if self.jsonObject!["oslc:responseInfo"] != nil
        {
            var responseInfoObj : [String: Any] = self.jsonObject!["oslc:responseInfo"] as! [String : Any]
            return responseInfoObj["oslc:nextPage"] != nil
        }
        return false;
    }

    /**
     * Go back to previous page
     * @throws
     */
    public func previousPage() throws -> ResourceSet {
        if self.jsonObject!["responseInfo"] != nil
        {
            var responseInfoObj : [String: Any] = self.jsonObject!["responseInfo"] as! [String : Any]
            if responseInfoObj["previousPage"] != nil {
                var previousPageObj : [String: Any] = responseInfoObj["previousPage"] as! [String : Any]
                self.appURI = previousPageObj["href"] as? String
            }
        }
        else if self.jsonObject!["oslc:responseInfo"] != nil
        {
            var responseInfoObj : [String: Any] = self.jsonObject!["oslc:responseInfo"] as! [String : Any]
            if responseInfoObj["oslc:previousPage"] != nil {
                var previousPageObj : [String: Any] = responseInfoObj["oslc:previousPage"] as! [String : Any]
                self.appURI = previousPageObj["rdf:resource"] as? String
            }
        }
        else
        {
            let strs = self.appURI!.split(separators: ["=", "&", "?"])
            var isPageNo : Bool = false;
            var pageno : Int = 0;
            for str in strs {
                if str == "pageno" {
                    isPageNo = true;
                } else if isPageNo {
                    pageno = Int(str)!
                    break
                }
            }
            if pageno == 2 {
                self.appURI = self.appURI!.replacingOccurrences(of: "pageno=" + String(pageno), with: "")
            } else {
                self.appURI = self.appURI!.replacingOccurrences(of: "pageno=" + String(pageno), with: "pageno=" + String(pageno - 1))
            }
        }
        self.jsonObject = try self.mc?.get(uri: self.appURI!);
        if self.jsonObject!["rdfs:member"] != nil {
            self.jsonArray = self.jsonObject?["rdfs:member"] as? [Any]
        } else {
            self.jsonArray = self.jsonObject?["member"] as? [Any]
        }
        return self
    }
    
    /**
     * Load the current data
     * @throws
     */
    public func load() throws -> ResourceSet {
        if (isLoaded) {
            return self
        }
        self.jsonObject = try self.mc?.get(uri: self.appURI!)
        if self.jsonObject!["rdfs:member"] != nil {
            self.jsonArray = self.jsonObject?["rdfs:member"] as? [Any]
        } else {
            self.jsonArray = self.jsonObject?["member"] as? [Any]
        }
        isLoaded = true
        return self
    }

    public func reload() throws -> ResourceSet {
        isLoaded = false
        _ = try load()
        return self
    }

    /**
     * Obtains a Saved Query.
     */
    public func savedQuery(name: String, paramValues: [String: Any]) -> ResourceSet {
        self.savedQuery = SavedQuery(name: name, map: paramValues).savedQueryClause()
        return self
    }

    public func savedQuery(qsaved: SavedQuery) -> ResourceSet {
        self.savedQuery = qsaved.savedQueryClause()
        return self
    }

    /**
     * URI Builder
     *
     * @throws OslcException.invalidURL
     */
    func buildURI() throws -> ResourceSet {
        var strb = String()
        if self.publicURI != nil {
            strb.append(self.publicURI!)
        } else {
            throw OslcError.invalidURL
        }
        if self.osName != nil {
            strb.append("/os/" + self.osName!.lowercased())
        }

        strb.append(self.publicURI!.contains("?") ? "" : "?")
        strb.append("&collectioncount=1")
        self.osURI = strb

        if self.selectClause != nil {
            strb.append("&oslc.select=" + Util.urlEncode(value: self.selectClause!))
        }
        if self.whereClause != nil {
            strb.append("&oslc.where=" + Util.urlEncode(value: self.whereClause!))
        } else if strbWhere != nil {
            strb.append("&oslc.where=" + strbWhere!);
        }
        if self.pageSize != -1 {
            strb.append("&oslc.pageSize=")
            strb.append(String(pageSize))
        }
        if self.paging == true {
            strb.append("&oslc.paging=true")
        }
        if self.searchAttributes != nil {
            var searchAttr = self.searchAttributes!
            searchAttr.remove(at: searchAttr.index(before: searchAttr.endIndex))
            strb.append("&searchAttributes=" + Util.urlEncode(value: searchAttr))
        }
        if self.searchTerms != nil {
            var searchTrm = self.searchTerms!
            searchTrm.remove(at: searchTrm.index(before: searchTrm.endIndex))
            strb.append("&oslc.searchTerms=" + Util.urlEncode(value: searchTrm))
        }
        if self.stablePaging == true {
            strb.append("&stablepaging=true")
        }
        if self.savedQuery != nil{
            strb.append("&savedQuery=" + self.savedQuery!)
        }
        if self.orderBy.count > 0 {
            strb.append("&oslc.orderBy=")
            for property in self.orderBy {
                strb.append("-" + property + ",")
            }
            if strb.hasSuffix(",") {
                strb.remove(at: strb.index(before: strb.endIndex))
            }
        }
        self.appURI = strb
        return self
    }

    public func fetchMember(uri: String, properties: [String]?) throws -> Resource {
        var strb : String = String(uri)
        if properties != nil && properties!.count > 0 {
            strb.append(uri.contains("?") ? "" : "?")
            strb.append("&oslc.properties=")
            var paramsStrb : String = String()
            for property in properties! {
                paramsStrb.append(property)
                paramsStrb.append(",")
            }
            if paramsStrb.hasSuffix(",") {
                paramsStrb.remove(at: paramsStrb.index(before: paramsStrb.endIndex))
            }
            strb.append(Util.urlEncode(value: paramsStrb))
        }
        let jo : [String: Any] = try self.mc!.get(uri: strb)
        return Resource(jo: jo, mc: self.mc!);
    }
    
    /**
     * get the member in ResourceSet
     *
     * @param index
     *
     * @throws
     */
    public func member(index: Int) throws -> Resource? {
        if !isLoaded {
            _ = try load()
        }
        if index >= (self.jsonArray?.count)! {
            return nil;
        }
        let jo : [String: Any] = self.jsonArray![index] as! [String : Any]
        return Resource(jo: jo, mc: self.mc!);
    }

    /**
     * Create a new Resource with the properties in hearder
     *
     * @param jo
     * @param properties
     *
     * @throws
     */
    public func create(jo: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.create(uri: self.osURI!, jo: jo, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }
    
    public func create(jo: [String: Any], headers: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.create(uri: self.osURI!, jo: jo, headers: headers, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }

    public func sync(jo: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.sync(uri: self.osURI!, jo: jo, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }

    public func sync(jo: [String: Any], headers: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.sync(uri: self.osURI!, jo: jo, headers: headers, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }
    
    public func mergeSync(jo: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.mergeSync(uri: self.osURI!, jo: jo, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }

    public func mergeSync(jo: [String: Any], headers: [String: Any], properties: [String]) throws -> Resource {
        if self.osURI == nil {
            _ = try self.buildURI()
        }
        let rjo : [String: Any] = try self.mc!.mergeSync(uri: self.osURI!, jo: jo, headers: headers, properties: properties)
        _ = try self.reload()
        // use the maximo connector to connect to oslc server and then POST data to it
        return Resource(jo: rjo, mc: self.mc!)
        // use the maximo connector to connect to oslc server and then load data from it
    }
    
    public func configuredPageSize() -> Int {
        return self.pageSize
    }

    /**
     * Count the total number of Resources by calling RESTful API
     *
     * @throws
     */
    public func totalCount() throws -> Int {
        if !isLoaded {
            _ = try load()
        }
        var jo : [String: Any] = [:]
        var total : Int = -1;
        if self.jsonObject!["oslc:responseInfo"] != nil {
            jo = self.jsonObject!["oslc:responseInfo"] as! [String: Any]
            if jo["oslc:totalCount"] != nil {
                total = jo["oslc:totalCount"] as! Int
            } else if jo["oslc:nextPage"] == nil {
                return try self.count();
            }
        } else if self.jsonObject!["responseInfo"] != nil {
            jo = self.jsonObject!["responseInfo"] as! [String: Any]
            if jo["totalCount"] != nil {
                total = jo["totalCount"] as! Int
            } else if jo["nextPage"] == nil {
                return try self.count();
            }
        }
        total = try self.totalCount(fromServer: true)
        return total
    }

    /**
     * Count the total number of Resources.
     * When fromServer=true, it calls the totalCount API.
     * When fromServer=false, it calls the RESTful API.
     *
     * @throws
     */
    public func totalCount(fromServer: Bool) throws -> Int {
        if !fromServer {
            return try self.totalCount()
        }
        var appURI : String = self.appURI! + (self.appURI!.contains("?") ? "" : "?")
        var jo : [String: Any] = try self.mc!.get(uri: appURI + "&count=1")
        if jo["totalCount"] != nil {
            return jo["totalCount"] as! Int
        } else {
            let tempPageSize : Int = self.configuredPageSize()
            self.pageSize = -1
            appURI = try self.buildURI().appURI!
            jo = try self.mc!.get(uri: appURI)
            var size : Int = -1
            if jo["member"] != nil {
                let memberObj : [Any] = jo["member"] as! [Any]
                size = memberObj.count
            } else if jo["rdfs:member"] != nil {
                let memberObj : [Any] = jo["rdfs:member"] as! [Any]
                size = memberObj.count
            }
            self.pageSize = tempPageSize;
            _ = try self.buildURI();
            return size;
        }
    }
    
    /**
     * Get current number of Resource by calling RESTful API
     * @throws
     */
    public func count() throws -> Int {
        if !isLoaded {
            _ = try load()
        }
        var size : Int = -1
        if self.jsonObject!["member"] != nil {
            let memberObj : [Any] = jsonObject!["member"] as! [Any]
            size = memberObj.count
        } else if self.jsonObject!["rdfs:member"] != nil {
            let memberObj : [Any] = jsonObject!["rdfs:member"] as! [Any]
            size = memberObj.count
        }
        return size
    }

    public func bulk() -> BulkProcessor {
        return BulkProcessor(mc: self.mc!, uri: self.osURI!)
    }

    public func groupBy() throws -> Aggregation {
        return Aggregation(mc: self.mc!, uri: try self.buildURI().appURI!)
    }
}
