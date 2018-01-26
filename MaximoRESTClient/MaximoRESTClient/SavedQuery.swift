//
//  SavedQuery.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public class SavedQuery {
    
    var name : String?
    var map : [String: Any]

    public init() {
        name = String()
        map = [:]
    }

    public init(name: String, map: [String: Any]) {
        self.name = name
        self.map = map
    }
    
    public func name(name: String) -> SavedQuery{
        self.name = name;
        return self;
    }

    public func params(params: [String: Any]) -> SavedQuery {
        self.map = params
        return self
    }

    public func addParam(key: String, value: Any) -> SavedQuery {
        map[key] = value
        return self
    }
    
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
