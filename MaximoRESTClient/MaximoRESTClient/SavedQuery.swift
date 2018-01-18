//
//  SavedQuery.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class SavedQuery {
    
    var name : String?
    var map : [String: Any]

    init() {
        name = String()
        map = [:]
    }

    init(name: String, map: [String: Any]) {
        self.name = name
        self.map = map
    }
    
    func name(name: String) -> SavedQuery{
        self.name = name;
        return self;
    }

    func params(params: [String: Any]) -> SavedQuery {
        self.map = params
        return self
    }

    func addParam(key: String, value: Any) -> SavedQuery {
        map[key] = value
        return self
    }
    
    func savedQueryClause() -> String {
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
