//
//  BulkProcessor.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 13/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// Bulk processo
public class BulkProcessor {
  
    /// Bulk array
    var bulkArray : [Any] = []
    /// Maximo Connector
    var mc: MaximoConnector
    /// URI information
    var uri: String
    
    /// Initialize object
    ///
    /// - Parameters:
    ///   - mc: Maximo Connector
    ///   - uri: URI Information.
    public init(mc: MaximoConnector, uri: String) {
        self.mc = mc
        self.uri = uri
    }

    /// Create object.
    ///
    /// - Parameter jo: JSON's array of information.
    /// - Returns: self.
    public func create(jo: [String: Any]) -> BulkProcessor {
        let obj : [String: Any] = ["_data": jo]
        bulkArray.append(obj)
        return self
    }

    /// Update meta data.
    ///
    /// - Parameters:
    ///   - jo: JSON Array
    ///   - uri: URI's information.
    ///   - properties: String array of properties.
    /// - Returns: self
    public func update(jo: [String: Any], uri: String, properties: [String]) -> BulkProcessor {
        var objb : [String: Any] = ["_data": jo]
        self.addMeta(objb: &objb, method: "PATCH", uri: uri, properties: properties)
        return self
    }
    
    /// Merge.
    ///
    /// - Parameters:
    ///   - jo: JSON Array
    ///   - uri: URI's information.
    ///   - properties: String array of properties.
    /// - Returns: self
    public func merge(jo: [String: Any], uri: String, properties: [String]) -> BulkProcessor {
        var objb : [String: Any] = ["_data": jo]
        self.addMeta(objb: &objb, method: "MERGE", uri: uri, properties: properties)
        return self
    }

    /// delete an element (i.e. Resource or Attachment)
    ///
    /// - Parameter uri: Resource/Attachment URI's information.
    /// - Returns: self.
    public func delete(uri: String) -> BulkProcessor {
        var objb : [String: Any] = [:]
        self.addMeta(objb: &objb, method: "DELETE", uri: uri, properties: nil)
        return self
    }

    /// Add metadata
    ///
    /// - Parameters:
    ///   - objb: Object Any
    ///   - method: HTTP Method description.
    ///   - uri: URI's information.
    ///   - properties: String array of properties.
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
    
    /// Process Bulk
    ///
    /// - Returns: bulk processed through Maximo Connector.
    /// - Throws: <#throws value description#>
    public func processBulk() throws -> [Any] {
        return try self.mc.bulk(uri: self.uri, ja: self.bulkArray)
    }
    
    /// Properties Builder.
    ///
    /// - Parameter properties: String array of properties.
    /// - Returns: Properties built.
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
