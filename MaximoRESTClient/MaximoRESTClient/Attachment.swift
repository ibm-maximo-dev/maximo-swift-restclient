//
//  Attachment.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class Attachment {

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

    init() {
        jo = [:]
        self.uri = String()
        self.mc = MaximoConnector()
    }
    
    init (uri: String, mc: MaximoConnector) {
        self.uri = uri
        self.mc = mc
        isUploaded = true
        jo = [:]
    }

    init (jo: [String: Any], mc: MaximoConnector) {
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
     * Attachment att = new Attachment().mc(params)
     * @param mc
     */
    func maximoConnector(mc: MaximoConnector) -> Attachment {
        self.mc = mc;
        return self;
    }
    
    func name(name: String) -> Attachment {
        self.name = name;
        return self;
    }
    
    func description(description: String) -> Attachment {
        self.description = description;
        return self;
    }
    
    func meta(type: String?, storeas: String) -> Attachment {
        var headerValue: String;
        if type != nil {
            headerValue = type! + "/" + storeas;
        } else {
            headerValue = storeas;
        }
        self.meta = headerValue;
        return self;
    }

    func wwwURI(uri: String) ->Attachment {
        self.uri = uri;
        return self;
    }
    
    func data(data: Data) -> Attachment {
        self.data = data;
        return self;
    }
    
    func getName() -> String {
        return self.name!;
    }
    
    func getDescription() -> String {
        return self.description!;
    }
    
    func getMeta() -> String{
        return self.meta!;
    }

    func toDoc() throws -> Data {
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
     *
     */
    func getURI() -> String {
        return self.uri;
    }

    /**
     * Get Attachment data in JSON
     *
     * @throws IOException
     * @throws OslcException
     */
    func toDocMeta() throws -> [String: Any] {
        if !isMetaLoaded {
            try loadMeta();
        }
        return self.jo;
    }

    /**
     * Get Attachment data in JSONBytes
     *
     * @throws IOException
     * @throws OslcException
     */
    func toDocMetaBytes() throws -> Data {
        if !isMetaLoaded {
            try loadMeta()
        }
        let data = try JSONEncoder().encode(self.jo)
        return data
    }

    /**
     * load attachment data
     * @throws OslcException
     * @throws IOException
     */
    func load() throws {
        try self.load(headers: nil)
    }
    
    /**
     * load attachment data with headers
     * @param headers
     * @throws IOException
     * @throws OslcException
     */
    func load(headers: [String: Any]?) throws {
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
    
    func reload() throws -> Attachment {
        isLoaded = false;
        try load();
        return self;
    }
    
    /**
     * load attachment meta data
     *
     * @throws IOException
     * @throws OslcException
     */
    func loadMeta() throws {
        try self.loadMeta(headers: nil);
    }

    func loadMeta(headers: [String: Any]?) throws {
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

    func reloadMeta() throws -> Attachment {
        isMetaLoaded = false;
        try loadMeta();
        return self;
    }
    
    func fetchDocMeta() throws -> [String: Any] {
        isMetaLoaded = false;
        try loadMeta();
        return self.jo;
    }

    /**
     * Delete the attachment
     * @throws IOException
     * @throws OslcException
     */
    func delete() throws {
        try self.mc.delete(uri: self.uri);
    }
}
