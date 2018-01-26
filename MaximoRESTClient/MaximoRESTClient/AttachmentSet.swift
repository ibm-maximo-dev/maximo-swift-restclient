//
//  AttachmentSet.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 *
 * {@code AttachmenSet} implement the operations on attachmentset from Resource.
 * It provides the set of Attachment.
 *
 * <p>This object can be created by {@code AttachmentSet}.
 * The following code shows how to create {@code AttachmentSet} using {@code AttachmentSet} Constructor
 * </p>
 * <pre>
 * <code>
 * var res = Resource()
 * var ats = res.attachmentSet(doclinkAttrName: doclinAttrName, relName: relName)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code AttachmentSet}</p>
 * <pre>
 * <code>
 * var ats = AttachmentSet()
 * var ats = AttachmentSet(jo: jsonobject, mc: maximoconnector)
 * var ats = AttachmentSet(uri: uri, mc: maximoconnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to set uri and jsonobject to {@code Attachment}</p>
 * <pre>
 * <code>
 * ats.href(href: uri)
 * ats.JsonObject(jo: jo)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to load and reload data</p>
 * <pre>
 * <code>
 * att.load()
 * att.reload()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to get AttachmentSet data from {@code AttachmentSet}</p>
 * <pre>
 * <code>
 * var jo : [String: Any] = att.toJSON()
 * var jodata : Data = att.toJSONBytes()
 * var uri : String = att.getURI()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to create, get and delete {@code Attachment} from{@code AttachmentSet}</p>
 * <pre>
 * <code>
 * var att = ats.create(att: Attachment())
 * var att = ats.create(relation: relation, att: Attachment())
 * var att = ats.member(index: index)
 * var att = ats.member(id: id)
 * ats.delete(index: index)
 * ats.delete(id: id)
 * </code>
 * </pre>
 *
 * <p>The following example shows how to get the this page size from {@code AttachmentSet}</p>
 * <pre>
 * <code>
 * var currentPageSize : Int = ats.thisPageSize()
 * </code>
 * </pre>
 *
 */
public class AttachmentSet {
    
    var href : String = String()
    var jo: [String: Any] = [:]
    var ja: [Any] = []
    var mc : MaximoConnector = MaximoConnector()
    var isLoaded : Bool = false

    public init() {
    }
    
    public init(mc: MaximoConnector) {
        self.mc = mc
    }
    
    public init(href: String, mc: MaximoConnector) {
        self.href = href
        self.mc = mc
    }

    public init(jo: [String: Any], mc: MaximoConnector) {
        self.jo = jo
        if self.jo["rdfs:member"] != nil {
            self.ja = self.jo["rdfs:member"] as! [Any]
        } else {
            self.ja = self.jo["member"] as! [Any]
        }
        if jo["rdf:about"] != nil {
            self.href = jo["rdf:about"] as! String
        } else {
            self.href = jo["href"] as! String
        }
        self.mc = mc
    }

    /**
     * Get current URI
     *
     */
    public func getURI() -> String {
        return self.href
    }

    /**
     * Get AttahcmentSet data in JSON
     *
     * @throws
     */
    public func toJSON() throws -> [String: Any] {
        _ = try self.load()
        return self.jo
    }
    
    /**
     * Get AttahcmentSet data in JSONBytes
     *
     * @throws
     */
    public func toJSONBytes() throws -> Data {
        _ = try self.load()
        let data = try JSONEncoder().encode(self.jo)
        return data
    }
    
    public func href(href: String) -> AttachmentSet {
        self.href = href
        return self
    }
    
    public func JsonObject(jo: [String: Any]) -> AttachmentSet {
        self.jo = jo
        if self.jo["rdfs:member"] != nil {
            self.ja = self.jo["rdfs:member"] as! [Any]
        } else {
            self.ja = self.jo["member"] as! [Any]
        }
        if jo["rdf:about"] != nil {
            self.href = jo["rdf:about"] as! String
        } else {
            self.href = jo["href"] as! String
        }
        return self
    }

    /**
     * Load the data for attachmentset
     *
     * @throws
     */
    public func load() throws -> AttachmentSet {
        return try self.load(headers: nil)
    }
    
    public func load(headers: [String: Any]?) throws -> AttachmentSet {
        if isLoaded {
            return self
        }
        
        if headers != nil && !(headers!.isEmpty) {
            self.jo = try self.mc.get(uri: self.href, headers: headers)
        } else {
            self.jo = try self.mc.get(uri: self.href)
        }
        if self.jo["rdfs:member"] != nil {
            self.ja = self.jo["rdfs:member"] as! [Any]
        } else {
            self.ja = self.jo["member"] as! [Any]
        }
        isLoaded = true
        return self
    }
    
    public func reload() throws -> AttachmentSet {
        isLoaded = false
        return try load()
    }
    
    /**
     * Create a new attachment
     * @param att
     *
     * @throws
     */
    public func create(att: Attachment) throws -> Attachment {
        let obj = try self.mc.createAttachment(uri: self.href, data: att.toDoc(), name: att.getName(), description: att.getDescription(), meta: att.getMeta())
        _ = try self.reload()
        return Attachment(jo: obj, mc: self.mc)
    }

    public func create(relation: String, att: Attachment) throws -> Attachment {
        if !self.href.contains(relation.lowercased()) || !self.href.contains(relation.uppercased()) {
            self.href += "/" + relation
        }

        let obj = try self.mc.createAttachment(uri: self.href, data: att.toDoc(), name: att.getName(), description: att.getDescription(), meta: att.getMeta())
        _ = try self.reload()
        return Attachment(jo: obj, mc: self.mc)
    }

    public func create(relation: String, att: Attachment, headers: [String: Any]?) throws -> Attachment {
        if !self.href.contains(relation.lowercased()) || !self.href.contains(relation.uppercased()) {
            self.href += "/" + relation
        }

        var obj : [String: Any]
        if headers != nil && !(headers!.isEmpty) {
            obj = try self.mc.createAttachment(uri: self.href, data: att.toDoc(), name: att.getName(), description: att.getDescription(), meta: att.getMeta(), headers: headers)
        } else {
            obj = try self.mc.createAttachment(uri: self.href, data: att.toDoc(), name: att.getName(), description: att.getDescription(), meta: att.getMeta())
        }

        _ = try self.reload()
        return Attachment(jo: obj, mc: self.mc)
    }

    /**
     * Get the member of attachmentset
     * @param index
     *
     * @throws
     */
    public func member(index: Int) throws -> Attachment? {
        if !isLoaded {
            _ = try load()
        }
        if index >= self.ja.count {
            return nil
        }
        let obj = self.ja[index] as! [String: Any]
        return Attachment(jo: obj, mc: self.mc);
    }
    
    public func member(id: String) throws -> Attachment? {
        if !isLoaded {
            _ = try load()
        }
        var obj : [String: Any]?
        for memberObj in self.ja {
            obj = memberObj as? [String : Any]
            if obj!["href"] != nil && (obj!["href"] as! String).contains(id) {
                break
            } else if obj!["rdf:about"] != nil && (obj!["rdf:about"] as! String).contains(id) {
                break
            }
            obj = nil
        }

        if obj == nil {
            return nil
        }
        return Attachment(jo: obj!, mc: self.mc);
    }

    /**
     * Delete the Attachment
     * @param index
     *
     * @throws
     */
    public func delete(index: Int) throws -> AttachmentSet {
        try self.member(index: index)?.delete()
        return try reload()
    }

    public func delete(id: String) throws -> AttachmentSet {
        try self.member(id: id)?.delete()
        return try reload()
    }

    public func thisPageSize() throws -> Int
    {
        if !isLoaded {
            _ = try load()
        }
        var size : Int = -1
        if self.jo["member"] != nil {
            size = (self.jo["member"] as! [Any]).count
        } else if self.jo["rdfs:member"] != nil {
            size = (self.jo["rdfs:member"] as! [Any]).count
        }
        return size
    }

    public func fetchMember(uri: String, properties: [String]?) throws -> Attachment {
        return try self.fetchMember(uri: uri, headers: nil, properties: properties)
    }

    public func fetchMember(uri: String, headers: [String: Any]?, properties: [String]?) throws -> Attachment {
        var strb : String = String(uri)
        if properties != nil && properties!.count > 0 {
            strb.append(uri.contains("?") ? "" : "?")
            strb.append("&oslc.properties=")
            for property in properties! {
                strb.append(property)
                strb.append(",")
            }
            if strb.hasSuffix(",") {
                strb.remove(at: strb.index(before: strb.endIndex))
            }
        }
        var strs = strb.split(separator: "/")
        let id = strs[strs.count - 1]
        var metaUri = strb.replacingOccurrences(of: id, with: "meta")
        metaUri = metaUri + "/" + id;
        var jo : [String: Any]
        if headers != nil && !(headers!.isEmpty) {
            jo = try self.mc.get(uri: metaUri, headers: headers)
        } else {
            jo = try self.mc.get(uri: metaUri)
        }
        return Attachment(jo: jo, mc: self.mc)
    }
}
