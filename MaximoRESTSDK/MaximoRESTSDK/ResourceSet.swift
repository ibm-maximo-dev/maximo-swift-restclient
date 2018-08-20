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
 * {@code ResourceSet} implement the operations on the {@code ResourceSet}. It
 * provides the set of the Resource.
 *
 * <p>
 * This object can be created by the {@code MaximoConnector}. The following code
 * shows how to create a {@code MaximoConnector}:
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
 * The following examples demonstrate how to build a new {@code ResourceSet}:
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
 * The following examples show how to set {@code ResourceSet} data from the
 * {@code ResourceSet}:
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
 * The following examples show how to fetch, load, reload, go to the next page, go
 * back to the previous page, and get a savedQuery for the {@code ResourceSet} data:
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
 * The following examples show how to get {@code ResourceSet} data from the
 * {@code ResourceSet}:
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
 * The following examples show how to create, get, and delete the {@code Resource}
 * from the {@code ResourceSet}:
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
 * The following example shows how to get the page size from the
 * {@code ResourceSet}:
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
    
    /// Page Size.
    var pageSize : Int = -1
    /// OS Name.
    var osName : String?
    /// Where clause.
    var whereClause : String?
    /// Select clause.
    var selectClause : String?
    /// OS URI.
    var osURI : String?
    /// Public URI.
    var publicURI : String?
    /// App URI.
    var appURI : String?
    /// Order by clause.
    var orderBy : [String] = []
    /// Save query.
    var savedQuery : String?
    /// String buffer where clause.
    var strbWhere : String?
    /// Search terms.
    var searchTerms : String?
    /// Search attributes.
    var searchAttributes : String?
    /// JSON Object.
    var jsonObject : [String: Any]?
    /// Maximo Connector.
    var mc : MaximoConnector?
    /// Pagin enable/disable.
    var paging : Bool = false
    /// Stable paging check.
    var stablePaging : Bool = false
    /// Is resource loaded.
    var isLoaded : Bool = false
    /// To JSON array.
    var jsonArray : [Any]?

    /// Initialize object.
    ///
    /// - Parameter osName: OSLC Name.
    public init(osName: String) {
        self.osName = osName
    }
    
    /// Initialize object
    ///
    /// - Parameter mc: Maximo Connector.
    public init(mc: MaximoConnector) {
        self.mc = mc
    }

    /// Initialize object
    ///
    /// - Parameters:
    ///   - osName: Oslc Name
    ///   - mc: Maximo Connector.
    public init(osName: String?, mc: MaximoConnector) {
        self.osName = osName
        self.publicURI = mc.getCurrentURI()
        self.mc = mc
    }

    /// Initialize object
    ///
    /// - Parameters:
    ///   - publicURI: The public URI information.
    ///   - mc: Maximo Connector object.
    public init(publicURI: String, mc: MaximoConnector) {
        self.mc = mc;
        self.publicURI = publicURI
    }

    
    /// Get current URI
    ///
    /// - Returns: Reference to the URI of the current application.
    public func getAppURI() -> String? {
        return self.appURI
    }
    
    /// Get public URI information.
    ///
    /// - Returns: Reference to the public URI information.
    public func getPublicURI() -> String? {
        return self.publicURI
    }
    
    /// Get OSLC URI information.
    ///
    /// - Returns: Reference to the OSLC URI information.
    public func getOsURI() -> String? {
        return self.osURI
    }

    /// Get ResourceSet data in JSON
    ///
    /// - Returns: String with a JSON Object representing the ResourceSet.
    public func toJSON() -> [String: Any]? {
        return self.jsonObject
    }


    /// Get ResourceSet data in JSON bytes
    ///
    /// - Returns: Data object with a JSON object encoded.
    /// - Throws: Exception
    public func toJSONBytes() throws -> Data {
/*        let data = try JSONEncoder().encode(self.jsonObject)
        return data
*/
        let data = try? JSONSerialization.data(withJSONObject: self.jsonObject, options: [])
        return data!
    }

    /// Set the where clause
    ///
    /// - Parameter whereClause: String carrying on the where clause.
    /// - Returns: Reference to the updated where clause.
    public func _where(whereClause: String) -> ResourceSet {
        self.whereClause = whereClause
        return self
    }

    /// Set the where clause based on an QueryWhere object.
    ///
    /// - Parameter _where: QueryWhere object.
    /// - Returns: Reference to the QueryWhere object within the where clause.
    public func _where(_where: QueryWhere) -> ResourceSet {
        self.whereClause = _where.whereClause()
        return self
    }
    
    /// Set attributes.
    ///
    /// - Parameter attributes: String array of attributes.
    /// - Returns: Reference to the updated array of attributes.
    public func searchAttributes(attributes: [String]) -> ResourceSet {
        self.searchAttributes = String()
        for attribute in attributes {
            self.searchAttributes?.append("" + attribute + ",")
        }
        return self
    }

    /// Check if this Resource Set has such terms.
    ///
    /// - Parameter terms: String array of terms.
    /// - Returns: Returns <b>TRUE</b> if such terms are present.
    public func hasTerms(terms: [String]) -> ResourceSet {
        self.searchTerms = String()
        for term in terms {
            self.searchTerms?.append("\"" + term + "\",")
        }
        return self
    }
    
    /// Set selectc clause.
    ///
    /// - Parameter selectClause: String array carrying on select statements.
    /// - Returns: Reference to the String array updated within select statements.
    public func select(selectClause: [String]) -> ResourceSet {
        self.selectClause = QuerySelect().select(selectClause: selectClause)
        return self
    }
    
    /// Set page size for the ResourceSet object.
    ///
    /// - Parameter pageSize: Page size in int.
    /// - Returns: ResourceSet configured with a new page size.
    public func pageSize(pageSize: Int) -> ResourceSet {
        self.pageSize = pageSize
        return self
    }
    
    /// Check paging.
    /// <>bNote:</b> &oslc.paging=true - If paging is false - do not add the query parameter
    /// - Parameter type: Query parameters.
    /// - Returns: Return <b>TRUE</b> - When paging, If <b>FALSE</b> - Do not add the query parameter.
    public func paging(type: Bool) -> ResourceSet {
        self.paging = type
        return self
    }

    /// Set stable paging.
    ///
    /// - Parameter type: Boolean value.<b>TRUE</b> - if yes, <b>FALSE</b> if not.
    /// - Returns:<b>TRUE</b> - if yes, <b>FALSE</b> if not.
    public func stablePaging(type: Bool) -> ResourceSet {
        self.stablePaging = type
        return self
    }
    
    /// Set order by clause.
    ///
    /// - Parameter orderByProperties: String array with order by properties.
    /// - Returns: Reference to the order by properties array.
    public func orderBy(orderByProperties: [String]) -> ResourceSet {
        for property in orderByProperties {
            self.orderBy.append(property)
        }
        return self
    }

   
    /// Fetching the data for the ResourceSet
    ///
    /// - Returns: Data of ResourceSet.
    /// - Throws: Exception.
    public func fetch() throws -> ResourceSet {
        _ = try self.fetch(options: nil)
        return self
    }

    /// Fetching the data for a ResourceSet with arbitrary parameters
    ///
    /// - Parameter additionalParams: Additional parameters.
    /// - Returns: Reference to the additional parameters.
    /// - Throws: Exception.
    public func fetchWithAddtionalParams(additionalParams: [String: Any]) throws -> ResourceSet {
        return try self.fetchWithAddtionalHeadersAndParams(additionalParams: additionalParams, additionalHeaders: nil);
    }
    
    /// Fetching the data for a ResourceSet with arbitrary headers
    ///
    /// - Parameter additionalHeaders: Additional headers.
    /// - Returns: Reference to the data fetch with additional parameters.
    /// - Throws: Exception.
    public func fetchWithAddtionalHeaders(additionalHeaders: [String: Any]) throws -> ResourceSet {
        return try self.fetchWithAddtionalHeadersAndParams(additionalParams: nil, additionalHeaders: additionalHeaders);
    }
    
   
    /// Fetching the data for a ResourceSet with arbitrary parameters and headers
    ///
    /// - Parameters:
    ///   - additionalParams: Additional parameters.
    ///   - additionalHeaders: Additional headers.
    /// - Returns: Reference to date fetch with Additional params and headers.
    /// - Throws: Exception.
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

    /// Fetching the data for a ResourceSet with arbitrary parameters.
    ///
    /// - Parameter options: Additional parameters.
    /// - Returns: Reference to the data fetched.
    /// - Throws: Exception.
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

    /// Go to nextPage
    ///
    /// - Returns: Reference to the next page.
    /// - Throws: Exception.
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

    /// Check if the JSON response information has a next page
    ///
    /// - Returns: boole <b>TRUE</b> if there is a next page or <b>FALSE<b/>, there is no other page info.
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

    /// Get the ResourceSet object to the previews page.
    ///
    /// - Returns: Return a ResourceSet object within the previews page information inside.
    /// - Throws: Exception.
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
    
   
    /// Load the current data
    ///
    /// - Returns: Reference to the current data.
    /// - Throws: Exception.
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

    /// Reload ResourceSet.
    ///
    /// - Returns: Reference to reloaded resource set.
    /// - Throws: Exception.
    public func reload() throws -> ResourceSet {
        isLoaded = false
        _ = try load()
        return self
    }

    /// Obtain a Saved Query.
    ///
    /// - Parameters:
    ///   - name: Name of the saved query.
    ///   - paramValues: Arbitrary parameter values.
    /// - Returns: Exception.
    public func savedQuery(name: String, paramValues: [String: Any]) -> ResourceSet {
        self.savedQuery = SavedQuery(name: name, map: paramValues).savedQueryClause()
        return self
    }

    /// Obtain a Saved Query.
    ///
    /// - Parameter qsaved: Saved query description
    /// - Returns: Reference to the saved query.
    public func savedQuery(qsaved: SavedQuery) -> ResourceSet {
        self.savedQuery = qsaved.savedQueryClause()
        return self
    }

    
    /// URI Builder
    ///
    /// - Returns: ResourceSet object.
    /// - Throws: slcException.invalidURL Invalid URL.
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

    /// Fetch a Resource.
    ///
    /// - Parameters:
    ///   - uri: Resource URI's information.
    ///   - properties: Resource arbitrary properties.
    /// - Returns: Reference to a fetched Resource object.
    /// - Throws: Exception.
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
    
    /// Get the member, which is a Resource object, in a ResourceSet
    ///
    /// - Parameter index: Parameter index.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
    public func member(index: Int) throws -> Resource? {
        if !isLoaded {
            _ = try load()
        }
        if let size = self.jsonArray?.count, index > size {
            return nil
        }
        let jo : [String: Any] = self.jsonArray![index] as! [String : Any]
        return Resource(jo: jo, mc: self.mc!);
    }

    
    /// Create a new Resource with the properties in the header
    ///
    /// - Parameters:
    ///   - jo: JSON object format in an Any swift object.
    ///   - properties: Arbitrary properties array.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
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
    
    /// Create a new Resource with the properties in the header
    ///
    /// - Parameters:
    ///   - jo: JSON object format in an Any swift object.
    ///   - properties: Arbitrary properties array.
    ///   - headers: Resource header information.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
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

    /// Sync a Resource.
    ///
    /// - Parameters:
    ///   - jo: JSON Object format in a Any swift object.
    ///   - properties: Arbitrary properties array.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
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

    /// Sync a Resource based on a header information.
    ///
    /// - Parameters:
    ///   - jo: JSON Object format in an Any swift object.
    ///   - properties: Arbitrary properties array.
    ///   - headers: Resource header information.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
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
    
    /// Merge and Sync a Resource
    ///
    /// - Parameters:
    ///   - jo: JSON object format in an Any swift object.
    ///   - properties: Arbitrary properties array.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception
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

    /// Merge and Sync a Resource object using a header information in additional.
    ///
    /// - Parameters:
    ///   - jo: JSON object format in an Any swift object.
    ///   - properties: Arbitrary properties array.
    ///   - headers: Resource header information.
    /// - Returns: Reference to the Resource object.
    /// - Throws: Exception.
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
    
    /// Configure page size.
    ///
    /// - Returns: Reference to the configured page size.
    public func configuredPageSize() -> Int {
        return self.pageSize
    }

    /// Count the total number of Resources by calling the RESTful API
    ///
    /// - Returns: Int value with total count.
    /// - Throws: Exception.
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
  
    /// Count the total number of Resources.
    /// <ul>
    ///     <li> When fromServer=true, it calls the totalCount API.</li>
    ///     <li> When fromServer=false, it calls the RESTful API. </li>
    /// </ul>
    /// - Parameter fromServer: Boolean to setup the count process.
    /// - Returns: Amount of objects based on the count process.
    /// - Throws: Exception.
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
    
    /// Get current number of Resource by calling the RESTful API
    ///
    /// - Returns: Size of Resource set.
    /// - Throws: Exception.
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

    /// Set the bulk processor.
    ///
    /// - Returns: BulkProcessor object.
    public func bulk() -> BulkProcessor {
        return BulkProcessor(mc: self.mc!, uri: self.osURI!)
    }

    /// Group by aggregation
    ///
    /// - Returns: Aggregation Object.
    /// - Throws: Exception.
    public func groupBy() throws -> Aggregation {
        return Aggregation(mc: self.mc!, uri: try self.buildURI().appURI!)
    }
}
