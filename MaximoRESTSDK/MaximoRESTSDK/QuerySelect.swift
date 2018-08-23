//
//  QuerySelect.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// Query select tool
public class QuerySelect {
    //a.b.*,a.c,x.y.z,x.f.g,x.y.e == a{b{*},c},x{y{z,e},f{g}}
    var map : [String: Any] = [:]

    /// Run the select clause.
    ///
    /// - Parameter selectClause: Clause to fetch
    /// - Returns: String that contains the Select clause parameters.
    public func select(selectClause: [String]) -> String
    {
        var strb = String();
        for s in selectClause {
            if s.starts(with: "$") //dynamic attributes
            {
                let index = s.index(after: s.startIndex)
                strb.append(String(s.suffix(from: index)) + ",");
            }
            else if s.contains(".")
            {
                let tokens = s.split(separator: ".")
                self.handleTokens(tokens: tokens, index: 0, selectMap: &map);
            }
            else
            {
                strb.append(s + ",");
            }
        }
        
        self.map2String(strb: &strb, map: map);
        if strb.hasSuffix(",")
        {
            strb.remove(at: strb.index(before: strb.endIndex))
        }
        return strb
    }
    
    /// Convert saved queries into the query's map to a string.
    ///
    /// - Parameters:
    ///   - strb: String to increment the query
    ///   - map: Query's map.
    func map2String(strb: inout String, map: [String: Any])
    {
        for (key, value) in map
        {
            let mapValue : [String: Any]? = value as? [String: Any]
            if mapValue == nil || mapValue?.count == 0
            {
                strb.append(key + ",");
            }
            else
            {
                strb.append(key + "{");
                self.map2String(strb: &strb, map: value as! [String : Any]);
                if strb.hasSuffix(",")
                {
                    strb.remove(at: strb.index(before: strb.endIndex))
                }
                strb.append("},");
            }
        }
    }

    /// Tokenize the query map.
    ///
    /// - Parameters:
    ///   - tokens: Token's delimiters.
    ///   - index: Map index.
    ///   - selectMap: Map that contains the saved queries.
    func handleTokens(tokens : [Substring], index: Int, selectMap: inout [String: Any])
    {
        if tokens.count < index+1 {
            return
        }
        let key = String(tokens[index])
        var map2 : [String: Any]? = selectMap[key] as? [String : Any]
        if(map2 == nil)
        {
            map2 = [:]
            selectMap[key] = map2
        }
        self.handleTokens(tokens: tokens, index: index+1, selectMap: &map2!);
    }
}
