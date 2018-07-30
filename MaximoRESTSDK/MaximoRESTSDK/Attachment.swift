//
//  Attachment.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 *
 * {@code Attachment} implement the operations on attachment from Resource.
 * It provides the data, meta data, uri and so on.
 *
 * <p>This object can be created by {@code AttachmentSet}.
 * The following code shows how to create {@code Attachment} using {@code AttachmentSet} Constructor
 * </p>
 * <pre>
 * <code>
 * var att = Attachment()
 * var att = AttachmentSet().create(relation: "DOCLINKS", att: att)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code Attachment}</p>
 * <pre>
 * <code>
 * var att = Attachment()
 * var att = Attachment(uri: attachmenturi, mc: maximoconnector)
 * var att = Attachment(jo: attachmentJsonObject, mc: maximoconnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to set maximoconnector, name, description, data, meta data, wwwURI to {@code Attachment}</p>
 * <pre>
 * <code>
 * att.maximoConnector(mc: maximoconnector).name(name: filename).description(description: description)
 * att.data(data: data).meta(type: type, storeas: storeas).wwwURI(uri: wwwURI)
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
 * The following examples show how to get information from {@code Attachment}
 * For file data:</p>
 * <pre>
 * <code>
 * var data : Data = att.toDoc()
 * var uri : String = att.getURI()
 * var name : String = att.getName()
 * var description : String = att.getDescription()
 * var meta : String = att.getMeta()
 * </code>
 * </pre>
 *
 * <p>
 * For file meta data:</p>
 * <pre>
 * <code>
 * var jo : [String: Any] = att.toDocMeta()
 * var jodata : Data = att.toDocMetaBytes()
 * </code>
 * </pre>
 *
 * <p>The following example shows how to delete the {@code Attachment}
 * <pre>
 * <code>
 * att.delete() //if the attachment is deleted as ats.att.detele(), please reload attachmentset after.
 * </code>
 * </pre>
 *
 */
public class Attachment {

    var name: String?
    var description: String?
    var meta: String?
    var uri: String
    var data: Data?
    var mc: MaximoConnector
    var isUploaded: Bool = false
    var isLoaded: Bool = false
    var isMetaLoaded: Bool = false
    var jo: [String: Any]

    /// Ini this class
    public init() {
        jo = [:]
        self.uri = String()
        self.mc = MaximoConnector()
    }
    
    /// Init this class based on a URI
    ///
    /// - Parameters:
    ///   - uri: String containig Unified Resource Location for the application
    ///   - mc: Maximo Connector object
    public init (uri: String, mc: MaximoConnector) {
        self.uri = uri
        self.mc = mc
        isUploaded = true
        jo = [:]
    }

    /// Init this class based on JSON object and a Maximo Connector Object
    ///
    /// - Parameters:
    ///   - jo: JSON schema
    ///   - mc: Maximo Connector object
    public init (jo: [String: Any], mc: MaximoConnector) {
        self.jo = jo
        self.mc = mc

        var docUri = ""
        if jo["rdf:about"] != nil {
            docUri = jo["rdf:about"] as! String
        } else if jo["rdf:resource"] != nil {
            docUri = jo["rdf:resource"] as! String
        } else {
            docUri = jo["href"] as! String
        }

        if docUri.contains("meta") {
            var strs = docUri.split(separator: "/")
            let id = strs[strs.count - 1]
            docUri = docUri.replacingOccurrences(of: "meta/" + id, with: id)
        }
        self.uri = docUri;
        isUploaded = true;
    }

    /**
     * var att = Attachment().maximoConnector(mc: params)
     * @param mc
     */
    public func maximoConnector(mc: MaximoConnector) -> Attachment {
        self.mc = mc;
        return self;
    }
    
    /// Object name
    ///
    /// - Parameter name: String with object name
    /// - Returns: updated name.
    public func name(name: String) -> Attachment {
        self.name = name;
        return self;
    }
    
    /// Object description
    ///
    /// - Parameter description: String description
    /// - Returns: description updated
    public func description(description: String) -> Attachment {
        self.description = description;
        return self;
    }
    
    /// meta data structure.
    ///
    /// - Parameters:
    ///   - type: Type
    ///   - storeas: String containing the "store as" information
    /// - Returns: Updated meta data.
    public func meta(type: String?, storeas: String) -> Attachment {
        var headerValue: String;
        if type != nil {
            headerValue = type! + "/" + storeas;
        } else {
            headerValue = storeas;
        }
        self.meta = headerValue;
        return self;
    }

    /// Set/Update www URI
    ///
    /// - Parameter uri: String informing the www URI
    /// - Returns: www URI updated.
    public func wwwURI(uri: String) ->Attachment {
        self.uri = uri;
        return self;
    }
    
    /// Data object
    ///
    /// - Parameter data: New Data object
    /// - Returns: updated Data object.
    public func data(data: Data) -> Attachment {
        self.data = data;
        return self;
    }
    
    /// Returns name
    ///
    /// - Returns: String containing name
    public func getName() -> String {
        return self.name!;
    }
    
    /// Returns description.
    ///
    /// - Returns: String containing object's description.
    public func getDescription() -> String {
        return self.description!;
    }
    
    /// Returns meta data.
    ///
    /// - Returns: meta data object.
    public func getMeta() -> String{
        return self.meta!;
    }

    /// Convert data to doc
    ///
    /// - Returns: data loaded.
    /// - Throws:
    public func toDoc() throws -> Data {
        if !isUploaded {
            return self.data!;
        }
        else if !isLoaded {
            try load();
        }
        return self.data!;
    }

    /**
     * Get current URI
     */
    public func getURI() -> String {
        return self.uri;
    }

    /**
     * Get Attachment data in JSON
     *
     * @throws
     */
    public func toDocMeta() throws -> [String: Any] {
        if !isMetaLoaded {
            try loadMeta();
        }
        return self.jo;
    }

    /**
     * Get Attachment data in JSONBytes
     *
     * @throws
     */
    public func toDocMetaBytes() throws -> Data {
        if !isMetaLoaded {
            try loadMeta()
        }
        /*
        let data = try JSONEncoder().encode(self.jo)
        return data
 */
        let data = try? JSONSerialization.data(withJSONObject: self.jo, options: [])
        return data!
    }

   
    /// load attachment data
    ///
    /// - Throws: <#throws value description#>
    public func load() throws {
        try self.load(headers: nil)
    }
    
    /**
     * load attachment data with headers
     * @param headers
     * @throws OslcError.attachmentAlreadyLoaded
     */
    public func load(headers: [String: Any]?) throws {
        if isLoaded {
            // The attachment has been loaded, please call reload for refreshing
            throw OslcError.attachmentAlreadyLoaded
        }
        if headers != nil && headers!.count > 0 {
            self.data = try self.mc.getAttachmentData(uri: self.uri, headers: headers!)
        } else {
            self.data = try self.mc.getAttachmentData(uri: self.uri)
        }
        isLoaded = true;
    }
    
    public func reload() throws -> Attachment {
        isLoaded = false;
        try load();
        return self;
    }
    
    /**
     * load attachment meta data
     *
     * @throws OslcError.attachmentAlreadyLoaded
     */
    public func loadMeta() throws {
        try self.loadMeta(headers: nil);
    }

    /// Load meta data
    ///
    /// - Parameter headers: meta data with headers parameters.
    /// - Throws: <#throws value description#>
    public func loadMeta(headers: [String: Any]?) throws {
        if isMetaLoaded {
            // The attachment has been loaded, please call reloadMeta for refreshing
            throw OslcError.attachmentAlreadyLoaded
        }
        var metauri = String();
        if self.uri.contains("meta") {
            jo = try self.mc.get(uri: self.uri)
            isMetaLoaded = true
        }
        let temp = self.uri.split(separator: "/");
        for str in temp {
            metauri.append(String(str))
            metauri.append("/")
            if str.uppercased() == "DOCLINKS" {
                metauri.append("meta")
                metauri.append("/")
            }
        }
        
        if metauri.hasSuffix("/") {
            metauri.remove(at: metauri.index(before: metauri.endIndex))
        }
        if headers != nil && headers!.count > 0 {
            jo = try self.mc.get(uri: metauri, headers: headers)
        } else {
            jo = try self.mc.get(uri: metauri)
        }
    
        if(jo["rdf:about"] != nil){
            self.name = jo["dcterms:title"] as? String
            self.description = jo["dcterms:description"] as? String
            self.meta = (jo["spi:urlType"] as! String) + "/" + "Attachments"
        } else {
            self.name = jo["title"] as? String
            self.description = jo["description"] as? String
            self.meta = (jo["urlType"] as! String) + "/" + "Attachments";
        }
        isMetaLoaded = true;
    }
    /// Reload Meta data
    ///
    /// - Returns: updated meta data.
    /// - Throws: <#throws value description#>
    public func reloadMeta() throws -> Attachment {
        isMetaLoaded = false;
        try loadMeta();
        return self;
    }
    
    /// Fetch meta data to a JSON document.
    ///
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    public func fetchDocMeta() throws -> [String: Any] {
        isMetaLoaded = false;
        try loadMeta();
        return self.jo;
    }

    /**
     * Delete the attachment
     * @throws
     */
    public func delete() throws {
        try self.mc.delete(uri: self.uri);
    }
}
