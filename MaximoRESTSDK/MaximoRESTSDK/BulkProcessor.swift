//
//  BulkProcessor.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 13/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public class BulkProcessor {
  
    var bulkArray : [Any] = []
    var mc: MaximoConnector
    var uri: String
    
    public init(mc: MaximoConnector, uri: String) {
        self.mc = mc
        self.uri = uri
    }

    public func create(jo: [String: Any]) -> BulkProcessor {
        let obj : [String: Any] = ["_data": jo]
        bulkArray.append(obj)
        return self
    }

    public func update(jo: [String: Any], uri: String, properties: [String]) -> BulkProcessor {
        var objb : [String: Any] = ["_data": jo]
        self.addMeta(objb: &objb, method: "PATCH", uri: uri, properties: properties)
        return self
    }
    
    public func merge(jo: [String: Any], uri: String, properties: [String]) -> BulkProcessor {
        var objb : [String: Any] = ["_data": jo]
        self.addMeta(objb: &objb, method: "MERGE", uri: uri, properties: properties)
        return self
    }

    public func delete(uri: String) -> BulkProcessor {
        var objb : [String: Any] = [:]
        self.addMeta(objb: &objb, method: "DELETE", uri: uri, properties: nil)
        return self
    }

    func addMeta(objb: inout [String: Any], method: String?, uri: String?, properties: [String]?) {
        var metaObj : [String: Any] = [:]
        let propStr = self.propertiesBuilder(properties: properties)
        if propStr != nil {
            metaObj["properties"] = propStr
        }
        if method != nil && !(method!.isEmpty) {
            metaObj["method"] = method
        }
        if uri != nil && !(uri!.isEmpty) {
            metaObj["uri"] = uri
        }
        if !metaObj.isEmpty {
            objb["_meta"] = metaObj
        }
        self.bulkArray.append(objb)
    }
    
    public func processBulk() throws -> [Any] {
        return try self.mc.bulk(uri: self.uri, ja: self.bulkArray)
    }
    
    func propertiesBuilder(properties: [String]?) -> String? {
        var propStrb = String()
        if properties == nil {
            return nil
        }
        for property in properties! {
            propStrb.append(property)
            propStrb.append(",")
        }
        if propStrb.count > 0 {
            if propStrb.hasSuffix(",") {
                propStrb.remove(at: propStrb.index(before: propStrb.endIndex))
                return propStrb
            } else {
                return propStrb
            }
        }
        return nil
    }

}
