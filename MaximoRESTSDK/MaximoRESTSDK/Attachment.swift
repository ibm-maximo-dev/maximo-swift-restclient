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
 * {@code Attachment} implements the operations on the attachment from a Resource.
 * It provides the data, metadata, URI and so on.
 *
 * <p>This object can be created by {@code AttachmentSet}.
 * The following code shows how to create {@code Attachment} by using the {@code AttachmentSet} Constructor:
 * </p>
 * <pre>
 * <code>
 * var att = Attachment()
 * var att = AttachmentSet().create(relation: "DOCLINKS", att: att)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to build a new {@code Attachment}:</p>
 * <pre>
 * <code>
 * var att = Attachment()
 * var att = Attachment(uri: attachmenturi, mc: maximoconnector)
 * var att = Attachment(jo: attachmentJsonObject, mc: maximoconnector)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples demonstrate how to set the maximoconnector, name, description, data, metadata, wwwURI for the {@code Attachment}:</p>
 * <pre>
 * <code>
 * att.maximoConnector(mc: maximoconnector).name(name: filename).description(description: description)
 * att.data(data: data).meta(type: type, storeas: storeas).wwwURI(uri: wwwURI)
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to load and reload data:</p>
 * <pre>
 * <code>
 * att.load()
 * att.reload()
 * </code>
 * </pre>
 *
 * <p>
 * The following examples show how to get information from the {@code Attachment}:
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
 * For file metadata:</p>
 * <pre>
 * <code>
 * var jo : [String: Any] = att.toDocMeta()
 * var jodata : Data = att.toDocMetaBytes()
 * </code>
 * </pre>
 *
 * <p>The following example shows how to delete the {@code Attachment}:
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
    ///   - uri: String that contains the Unified Resource Location for the application
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

    
    /// Set the Maximo connector object
    ///
    /// - Parameter mc: MaximoConnector object
    /// - Returns: Attachment object with the MaximoConnector object set.
    public func maximoConnector(mc: MaximoConnector) -> Attachment {
        self.mc = mc;
        return self;
    }
    
    /// Set the Attachment name
    ///
    /// - Parameter name: String that contains the object name
    /// - Returns: updated name.
    public func name(name: String) -> Attachment {
        self.name = name;
        return self;
    }
    
    /// Set the Attachment description.
    ///
    /// - Parameter description: String description
    /// - Returns: Attachment object with the description set.
    public func description(description: String) -> Attachment {
        self.description = description;
        return self;
    }
    
    /// metadata structure.
    ///
    /// - Parameters:
    ///   - type: Type
    ///   - storeas: String that contains the "store as" information
    /// - Returns: Updated metadata.
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
    /// - Returns: Attachment with the URI updated.
    public func wwwURI(uri: String) ->Attachment {
        self.uri = uri;
        return self;
    }
    
    /// Set the Data object
    ///
    /// - Parameter data: New Data object
    /// - Returns: Attachment with data object set.
    public func data(data: Data) -> Attachment {
        self.data = data;
        return self;
    }
    
    /// Returns name
    ///
    /// - Returns: String that contains the name
    public func getName() -> String {
        return self.name!;
    }
    
    /// Returns description.
    ///
    /// - Returns: String that contains the object's description.
    public func getDescription() -> String {
        return self.description!;
    }
    
    /// Returns metadata.
    ///
    /// - Returns: metadata object.
    public func getMeta() -> String{
        return self.meta!;
    }

    /// Convert data to doc
    ///
    /// - Returns: data loaded.
    /// - Throws: Exception.
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

    
    /// Get Attachment data in JSON
    ///
    /// - Returns: String object within a JSON structure.
    /// - Throws: Exception.
    public func toDocMeta() throws -> [String: Any] {
        if !isMetaLoaded {
            try loadMeta();
        }
        return self.jo;
    }

    
    /// Get Attachment data in JSON
    ///
    /// - Returns: Data object with JSON's data encoded.
    /// - Throws: Exception.
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

   
    /// Load attachment data
    ///
    /// - Throws: Exception.
    public func load() throws {
        try self.load(headers: nil)
    }
    
    
    /// Load attachment data with headers
    ///
    /// - Parameter headers: <#headers description#>
    /// - Throws: Exception
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
    
    /// Load attachment meta data
    ///
    /// - Throws: Exception
    public func loadMeta() throws {
        try self.loadMeta(headers: nil);
    }

    /// Load metadata
    ///
    /// - Parameter headers: metadata with headers parameters.
    /// - Throws: Exception.
    public func loadMeta(headers: [String: Any]?) throws {
        if isMetaLoaded {
            // The attachment was loaded. Call reloadMeta to refresh.
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
    /// Reload metadata
    ///
    /// - Returns: Attachment object within an updated metadata.
    /// - Throws: Exception.
    public func reloadMeta() throws -> Attachment {
        isMetaLoaded = false;
        try loadMeta();
        return self;
    }
    
    /// Fetch metadata to a JSON document.
    ///
    /// - Returns: String with an JSON data.
    /// - Throws: Exception.
    public func fetchDocMeta() throws -> [String: Any] {
        isMetaLoaded = false;
        try loadMeta();
        return self.jo;
    }

    /**
     * Delete the attachment object
     * @throws Exception
     */
    public func delete() throws {
        try self.mc.delete(uri: self.uri);
    }
}
