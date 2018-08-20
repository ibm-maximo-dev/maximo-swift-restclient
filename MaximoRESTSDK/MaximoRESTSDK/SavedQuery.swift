//
//  SavedQuery.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// Object to represent the Saved query.
public class SavedQuery {
    
    /// Query name
    var name : String?
    /// Query of Any to represent the query information
    var map : [String: Any]

    /// Init the SavedQuery object.
    public init() {
        name = String()
        map = [:]
    }

    /// Init the SavedQuery object.
    ///
    /// - Parameters:
    ///   - name: Query name.
    ///   - map: map with query commands.
    public init(name: String, map: [String: Any]) {
        self.name = name
        self.map = map
    }
    
    /// Set query name.
    ///
    /// - Parameter name: String within query name.
    /// - Returns: SavedQuery object within name updated.
    public func name(name: String) -> SavedQuery{
        self.name = name;
        return self;
    }

    /// Query params.
    ///
    /// - Parameter params: Any object containing the query params.
    /// - Returns: SavedQuery object within query parameters.
    public func params(params: [String: Any]) -> SavedQuery {
        self.map = params
        return self
    }

    /// Add a new parameter to the query's parameter map.
    ///
    /// - Parameters:
    ///   - key: Key for the map
    ///   - value: parameter's value.
    /// - Returns: SavedQuery object updated, including the new parameter.
    public func addParam(key: String, value: Any) -> SavedQuery {
        map[key] = value
        return self
    }
    
    /// Save query function.
    ///
    /// - Returns: Saved query.
    public func savedQueryClause() -> String {
        var strBuilder = String()
        strBuilder.append(self.name!)

        for (key, value) in map {
            strBuilder.append("&")
            strBuilder.append("sqp:")
            strBuilder.append(key);
            let valueAsString = Util.stringValue(value: value)
            let encodeValue = Util.urlEncode(value: valueAsString)
            strBuilder.append("=")
            strBuilder.append(encodeValue);
        }

        return strBuilder;
    }
}
