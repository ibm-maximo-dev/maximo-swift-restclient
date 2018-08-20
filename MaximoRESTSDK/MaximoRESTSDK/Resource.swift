//
//  Resource.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 *
 * {@code Resource} implement the operations on Resource.
 * It provides the data, uri, attachment and so on.
 *
 * <p>This object can be created by {@code ResourceSet} or {@code MaximoConnector}.
 * The following code shows how to create {@code Resource} using {@code ResourceSet}
 * or using the {@code MaximoConnector}
 * </p>
 * <pre>
 * <code>
 * var re = re.member(index: index)
 * var re = re.fetchMember(uri: uri, properties: properties)
 * var re = mc.resource(uri: uri, properties: properties)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code Resource}</p>
 * <pre>
 * <code>
 * var re = Resource()
 * var re = Resource(uri: uri)
 * var re = Resource(jo: jsonObject)
 * var re = Resource(uri: uri, mc: maximoConnector)
 * var re = Resource(jo: jsonObject, mc: maximoConnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to set uri and maximoConnector to {@code Resource}</p>
 * <pre>
 * <code>
 * re.uri(href: URI).maximoConnector(mc: maximoConnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to load and reload data</p>
 * <pre>
 * <code>
 * re.load()
 * re.reload()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to get information from {@code Resource}</p>
 * <pre>
 * <code>
 * var jo : [String: Any] = re.toJSON()
 * var joBytes : Data = re.toJSONBytes()
 * </code>
 * </pre>
 *
 * <p>The following examples show how to update, merge and delete the {&code Resource}</p>
 * <pre>
 * <code>
 * re.update(jo: jsonObject, properties: properties)
 * re.merge(jo: jsonObject, properties: properties)
 * re.delete(index: index)
 * rs.re.delete() //if the attachment is deleted as rs.re.detele(), please reload {@code ResourceSet} after.
 * </code>
 * </pre>
 *
 * <p>The following example show how to get attachmentSet, relatedResource and how to invoke action by {@code Resource}</p>
 * <pre><code>
 * var ats = re.attachmentSet(doclinkAttrName: doclinkAttrName, relName: relName)
 * var relationRe = re.relatedResource(attrName: attrName)
 * re.invokeAction(actionName: actionName, jo: jsonObeject)
 * </code></pre>
 */
public class Resource {

    /// Resource's URL.
    var href : String
    /// JSON Object with resource information.
    var jsonObject : [String: Any]
    /// Maximo Connector Object
    var mc : MaximoConnector
    /// Booelan to identify if the object is loaded.
    var isLoaded : Bool = false

    /// Init object based on a JSON schema.
    ///
    /// - Parameter jo: JSON schema.
    public init(jo : [String: Any]) {
        self.jsonObject = jo
        self.mc = MaximoConnector()
        if jo["rdf:about"] != nil {
            self.href = jo["rdf:about"] as! String
        } else if jo["rdf:resource"] != nil {
            self.href = jo["rdf:resource"] as! String
        } else if jo["href"] != nil {
            self.href = jo["href"] as! String
        } else if jo["localref"] != nil {
            self.href = jo["localref"] as! String
        } else {
            self.href = String()
        }
    }

    /// Convenience initializer considering an Any object carrying on a JSON object and a Maximo Connector object.
    ///
    /// - Parameters:
    ///   - jo: JSON scheme to initialize this object.
    ///   - mc: Maximo Connector object.
    public convenience init(jo : [String: Any], mc: MaximoConnector) {
        self.init(jo: jo)
        self.mc = mc
    }

    /// Initializer based on a URI's information and a explicit JSON Object.
    ///
    /// - Parameter href: Resource URI's Information.
    public init(href: String) {
        self.href = href
        self.jsonObject = [:]
        self.mc = MaximoConnector()
    }

    /// Convenience initializer based on a Resource's URI information and a Maximo Connector object.
    ///
    /// - Parameters:
    ///   - href: <#href description#>
    ///   - mc: <#mc description#>
    public convenience init(href: String, mc: MaximoConnector) {
        self.init(href: href)
        self.mc = mc
    }

    /// Set the Resource's URI information.
    ///
    /// - Parameter href: Resource's URI information.
    /// - Returns: Resource object with href param updated.
    public func uri(href: String) -> Resource {
        self.href = href
        return self
    }
    
    /// Set the Maximo Connector object
    ///
    /// - Parameter mc: MaximoConnector object.
    /// - Returns: Resource object with a MaximoConnector object set.
    public func maximoConnector(mc: MaximoConnector) -> Resource {
        self.mc = mc
        return self
    }

    /// Get current URI
    ///
    /// - Returns: Reference to a String within URI's information.
    public func getURI() -> String {
        return self.href
    }

    
    /// Get Resource data in JSON
    ///
    /// - Returns: Reference to a JSON within resource data.
    /// - Throws: Exception.
    public func toJSON() throws -> [String: Any] {
        if !isLoaded {
            _ = try load()
        }
        return self.jsonObject
    }

    
    /// Get Resource data in JSON Bytes.
    ///
    /// - Returns: Data object referencing a JSON bytes.
    /// - Throws: Exception.
    public func toJSONBytes() throws -> Data {
        if !isLoaded {
            _ = try load()
        }
//        let data: Data = try JSONEncoder().encode(self.jsonObject)
        let data = try? JSONSerialization.data(withJSONObject: self.jsonObject, options: [])
        return data!
    }
    
    /// Load current data with properties in header
    ///
    /// - Returns: Resource object with current data header set.
    /// - Throws: Exception.
    public func load() throws -> Resource {
        return try self.loadWithAdditionalParamsAndHeaders(params: nil, headers: nil, properties: nil)
    }
    
    /// Load current data with properties as a parameter.
    ///
    /// - Parameter properties: header's properties.
    /// - Returns: Resource object  with properties in header set.
    /// - Throws: Exception.
    public func load(properties: [String]) throws -> Resource {
        return try self.loadWithAdditionalParamsAndHeaders(params: nil, headers: nil, properties: properties)
    }
    
    /// Load current data with properties as a parameter an additional params.
    ///
    /// - Parameters:
    ///   - params: Data params.
    ///   - properties: header's properties.
    /// - Returns: Resource object with properties in header and additional params.
    /// - Throws: Exception.
    public func loadWithAdditionalParams(params: [String: Any]?, properties: [String]?) throws -> Resource {
        return try self.loadWithAdditionalParamsAndHeaders(params: params, headers: nil, properties: properties)
    }
    
    /// Load current data with properties as a parameter an additional headers.
    ///
    /// - Parameters:
    ///   - headers: Additional header's information.
    ///   - properties: Properties information.
    /// - Returns: Resource object with current data with additional headers.
    /// - Throws: Exception.
    public func loadWithAdditionalHeaders(headers: [String: Any]?, properties: [String]?) throws -> Resource {
        return try self.loadWithAdditionalParamsAndHeaders(params: nil, headers: headers, properties: properties)
    }

    /// Load current data with properties as a parameter an additional headers and params.
    ///
    /// - Parameters:
    ///   - params: Additional params.
    ///   - headers: Additional header's information.
    ///   - properties: Properties information.
    /// - Returns: Resource object with current data with additional headers and params.
    /// - Throws: Exception.
    public func loadWithAdditionalParamsAndHeaders(params: [String: Any]?, headers: [String: Any]?, properties: [String]?) throws -> Resource {
        if isLoaded {
            // The resource has been loaded, please call reload for refreshing");
            throw OslcError.resourceAlreadyLoaded
        }
        if self.href.isEmpty {
            throw OslcError.invalidResource
        }
        var strb : String = String()
        strb.append(self.href);
        if properties != nil && properties!.count > 0 {
            strb.append(self.href.contains("?") ? "" : "?")
            strb.append("&oslc.properties=")
            var paramsStrb : String = String()
            for property in properties! {
                paramsStrb.append(property)
                paramsStrb.append(",")
            }
            if paramsStrb.hasSuffix(",") {
                let index = paramsStrb.index(before: paramsStrb.endIndex)
                paramsStrb.remove(at: index)
            }
            strb.append(Util.urlEncode(value: paramsStrb))
        }
        if params != nil && params!.count > 0 {
            strb.append(self.href.contains("?") ? "" : "?")
            for (key, value) in params! {
                var singleParam : String = String()
                singleParam.append("&")
                singleParam.append(key)
                singleParam.append("=");
                singleParam.append(Util.urlEncode(value: value as! String));
                strb.append(singleParam);
            }
        }

        if headers != nil && headers!.count > 0 {
            self.jsonObject = try self.mc.get(uri: strb, headers: headers);
        } else {
            self.jsonObject = try self.mc.get(uri: strb)
        }
        self.isLoaded = true
        return self
    }
    
    /// Reload data.
    ///
    /// - Returns: Resource object reloaded.
    /// - Throws: Exception.
    public func reload() throws -> Resource {
        self.isLoaded = false
        _ = try load()
        return self
    }
    
    /// Reload data fetching with properties.
    ///
    /// - Parameter properties: To be reloaded resource's properties.
    /// - Returns: Resource object reloaded with properties params.
    /// - Throws: Exception.
    public func reload(properties: [String]) throws -> Resource {
        self.isLoaded = false
        _ = try load(properties: properties)
        return self
    }
    
    
    /// Update the Resource
    ///
    /// - Parameters:
    ///   - jo: JSON data fetch to update the specific resource.
    ///   - properties: Resource's properties.
    /// - Returns: Reference to updated resource object.
    /// - Throws: Exception.
    public func update(jo: [String: Any], properties: [String]) throws -> Resource
    {
        return try self.update(jo: jo, headers: nil, properties: properties)
    }

    /// Update the Resource with additional headers.
    ///
    /// - Parameters:
    ///   - jo: JSON data within the resource information.
    ///   - headers: additional header's information.
    ///   - properties: resource's properties.
    /// - Returns: Reference to updated resource object.
    /// - Throws: Exception.
    public func update(jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> Resource
    {
        if self.href.isEmpty {
            throw OslcError.invalidResource
        }
        if headers != nil && headers!.count > 0 {
            self.jsonObject = try self.mc.update(uri: self.href, jo: jo, headers: headers, properties: properties)
        } else {
            self.jsonObject = try self.mc.update(uri: self.href, jo: jo, properties: properties)
        }

        if properties != nil && properties!.count > 0 {
            self.isLoaded = true
        } else {
            _ = try self.reload()
        }
        return self
    }
    
    /// Merge data
    ///
    /// - Parameters:
    ///   - jo: JSON data to merged to a resource.
    ///   - properties: Properties to be merged to a resource.
    /// - Returns: Reference to a merged resource object.
    /// - Throws: Exception.
    public func merge(jo: [String: Any], properties: [String]) throws -> Resource
    {
        return try self.merge(jo: jo, headers: nil, properties: properties);
    }
    
    /// Merge data to a resource with additional headers.
    ///
    /// - Parameters:
    ///   - jo: JSON data to merged to a resource.
    ///   - headers: Additional headers.
    ///   - properties: Properties to be merged to a resource object.
    /// - Returns: Reference to a resource merged with additional headers.
    /// - Throws: Exception.
    public func merge(jo: [String: Any], headers: [String: Any]?, properties: [String]?) throws -> Resource
    {
        if self.href.isEmpty {
            throw OslcError.invalidResource
        }
        if headers != nil && headers!.count > 0 {
            self.jsonObject = try self.mc.merge(uri: self.href, jo: jo, headers: headers, properties: properties);
        } else {
            self.jsonObject = try self.mc.merge(uri: self.href, jo: jo, properties: properties);
        }
        if properties != nil && properties!.count > 0 {
            self.isLoaded = true
        } else {
            _ = try self.reload()
        }

        return self;
    }

    /// Load the attachment set for resource
    /// <b>Note:</b> there has to be a relation between them
    ///
    /// - Parameters:
    ///   - doclinkAttrName: String with attribute name.
    ///   - relName: String with related name.
    /// - Returns: AttachmentSet object.
    public func attachmentSet(doclinkAttrName: inout String?, relName: String?) -> AttachmentSet {
        var str : String = String()
        if doclinkAttrName == nil {
            doclinkAttrName = "doclinks"
        }
        if self.jsonObject[doclinkAttrName!] != nil {
            var obj : [String: Any] = jsonObject[doclinkAttrName!] as! [String : Any]
            str = obj["href"] as! String
        } else if self.jsonObject["spi:" + doclinkAttrName!] != nil {
            var obj : [String: Any] = jsonObject["spi:" + doclinkAttrName!] as! [String : Any]
            if obj["rdf:about"] != nil {
                str = obj["rdf:about"] as! String
            } else if obj["rdf:resource"] != nil {
                str = obj["rdf:resource"] as! String
            }
        } else {
            if relName != nil
            {
                str = self.href + "/" + relName!.uppercased()
            } else {
                str = self.href + "/DOCLINKS"
            }
        }
        return AttachmentSet(href: str, mc: self.mc);
    }
    
    /// Get an Attachment Set within all attachments related to the resource.
    ///
    /// - Returns: Reference to an AttachmentSet object.
    /// - Throws: Exception. OsclError: Invalid Relation..
    public func attachmentSet() throws -> AttachmentSet {
        var str : String = String()
        if self.jsonObject["doclinks"] != nil {
            var obj : [String: Any] = jsonObject["doclinks"] as! [String : Any]
            str = obj["href"] as! String
        } else if self.jsonObject["spi:" + "doclinks"] != nil {
            var obj : [String: Any] = jsonObject["spi:" + "doclinks"] as! [String : Any]
            if obj["rdf:about"] != nil {
                str = obj["rdf:about"] as! String
            } else if obj["rdf:resource"] != nil {
                str = obj["rdf:resource"] as! String
            }
        } else {
            throw OslcError.invalidRelation
        }
        return AttachmentSet(href: str, mc: self.mc)
    }
    
    /// Get related resource through an attribute name.
    ///
    /// - Parameter attrName: Attribute name.
    /// - Returns: Reference to the resource object.
    /// - Throws: Exception. nil: Not valid data.
    public func relatedResource(attrName: String) throws -> Resource?
    {
        var url : String = String()
        var jo : [String: Any] = [:]
        if self.jsonObject[attrName] != nil {
            jo = self.jsonObject[attrName] as! [String : Any]
        } else if self.jsonObject["spi:" + attrName] != nil {
            jo = self.jsonObject["spi:" + attrName] as! [String : Any]
        } else {
            return nil;
        }
    
        if jo["href"] != nil {
            url = jo["href"] as! String;
        } else if jo["rdf:resource"] != nil {
            url = jo["rdf:resource"] as! String
        } else if jo["rdf:about"] != nil {
            url = jo["rdf:about"] as! String
        } else {
            return nil;
        }

        return try self.mc.resourceSet().fetchMember(uri: url, properties: nil)
    }

    /// Invoke Action
    ///
    /// - Parameters:
    ///   - actionName: Action name.
    ///   - jo: JSON within action information.
    /// - Returns: Reference to a resource object.
    /// - Throws: Exception.
    public func invokeAction(actionName: String, jo: [String: Any]) throws -> Resource {
        _ = try self.mc.update(uri: self.href + (self.href.contains("?") ? "" : "?") + "&action=" + actionName, jo: jo, properties: nil)
        _ = try self.reload();
        return self;
    }
    
    
    /// Invoke Action fetching the resource through properties.
    ///
    /// - Parameters:
    ///   - actionName: Action name.
    ///   - jo: JSON within action information.
    ///   - properties: Action's properties.
    /// - Returns: Reference to a resource object.
    /// - Throws: Exception.
    public func invokeAction(actionName: String, jo: [String: Any], properties: [String]) throws -> Resource {
        self.jsonObject = try self.mc.update(uri: self.href + (self.href.contains("?") ? "" : "?") + "&action=" + actionName, jo: jo, properties: properties)
        return self;
    }
    
    /// Delete a resource based on it's URI.
    ///
    /// - Throws: Exception. <#throws value description#>
    public func delete() throws {
        try self.mc.delete(uri: self.href);
    }

    /// Support pre-load resource.
    ///
    /// - Parameter isLoaded: boolean representing if the resource is loaded.
    public func setLoaded(isLoaded: Bool) {
        self.isLoaded = isLoaded;
    }
}
