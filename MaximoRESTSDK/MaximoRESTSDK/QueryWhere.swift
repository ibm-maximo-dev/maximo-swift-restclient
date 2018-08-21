//
//  QueryWhere.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// Operates the where clause.
public class QueryWhere {
    
    /// String to handle the where clause statements.
    var strbWhere : String = String()
    /// Map to store the where clause statements.
    var map : [String: Any] = [:]
    /// Current key control.
    var currentKey : String = String()
    
    /// Where clause function.
    ///
    /// - Parameter name: Where query name.
    /// - Returns: the current QueryWhere object.
    public func _where (name: String) -> QueryWhere
    {
        currentKey = name
        return self
    }
    
    /// Handle with AND statement.
    ///
    /// - Parameter name: Where clause name.
    /// - Returns: QueryWhere object within an updated where clause.
    public func and(name: String) -> QueryWhere
    {
        if name.contains(".")
        {
            var attrPath = name.split(separator: ".")
            var childMap : [String: String]? = map[String(attrPath[0])] as? [String : String]

            if(childMap == nil)
            {
                childMap = [:]
                map[String(attrPath[0])] = childMap
            }
        }
        currentKey = name
        return self
    }
    
    /// Retrieve the current map.
    ///
    /// - Returns: Current map.
    public func getCurrentMap() -> [String: Any]
    {
        if currentKey.contains(".")
        {
            var attrPath = currentKey.split(separator: ".")
            let childMap : [String: Any]? = map[String(attrPath[0])] as? [String : Any]
            return childMap!
        }
        return map
    }
    
    /// Retrieve the current key.
    ///
    /// - Returns: String containing the current key.
    public func getCurrentKey() -> String
    {
        if currentKey.contains(".")
        {
            var attrPath = currentKey.split(separator: ".")
            return String(attrPath[1]);
        }
        return currentKey
    }
    
    /// Set query tokens.
    ///
    /// - Parameter s: String to be tokeninzed.
    public func setQueryToken(s: String)
    {
        var currMap = self.getCurrentMap()
        var currKey = self.getCurrentKey()
        if currMap[currKey] != nil
        {
            currKey = "/" + currKey
        }
        currMap[currKey] = s
    }

    /// Equal to statement handler.
    ///
    /// - Parameter value: Any object that contains the value to compare.
    /// - Returns: QueryWhere object with equals to set.
    public func equalTo(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    /// Starts with statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with starts with test set.
    public func startsWith(value: String) -> QueryWhere
    {
        let  s = Util.stringValue(value: value + "%")
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    /// Ends with statement handler.
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with endsWith test set .
    public func endsWith(value: String) -> QueryWhere
    {
        let s = Util.stringValue(value: "%" + value)
        self.setQueryToken(s: "=" + s)
        return self
    }

    /// Like statement handler.
    ///
    /// - Parameter value: Value to scan.
    /// - Returns: QueryWhere object with like statement added.
    public func like(value: String) -> QueryWhere
    {
        let s = Util.stringValue(value: "%" + value + "%")
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    /// Greater than statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with <code>grater then statement</code> added.
    public func gt(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: ">" + s)
        return self
    }
    /// Greater than or equal to statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object <code>grater then or equals to</code> statement added.
    public func gte(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: ">=" + s)
        return self
    }
    /// Less than statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with <code>less then</code> statement added.
    public func lt(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "<" + s)
        return self
    }
    
    /// Less than or equal to statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with <code>less the or equals to</code> statement added.
    public func lte(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "<=" + s)
        return self
    }
    /// IN statement handler.
    ///
    /// - Parameter value: Value.
    /// - Returns: QueryWhere object with <code>_in</code> statement added.
    public func _in(values: [Any]) -> QueryWhere
    {
        var strb = String()
        for obj in values
        {
            strb.append(Util.stringValue(value: obj) + ",")
        }
        var s = strb
        
        let index = s.index(before: s.endIndex)
        s = String(s.prefix(upTo: index))
        self.setQueryToken(s: " in " + "[" + s + "]")
        return self
    }
    
    /// Build where clause.
    ///
    /// - Returns: String that contains the where clause.
    public func whereClause() -> String
    {
        var cnt : Int = 0
        for (key, value) in map
        {
            cnt += 1
            var keyValue : String = key;
            if key.starts(with: "/")
            {
                let index = key.index(after: key.startIndex)
                keyValue = String(key.suffix(from: index))
            }

            strbWhere.append(keyValue)
            let valueString : String? = value as? String
            
            if valueString != nil
            {
                strbWhere.append(valueString!);
            }
            else
            {
                let childMap : [String: String] = value as! [String : String]
                strbWhere.append("{");
                var ccnt : Int = 0;
                for (cKey, cValue) in childMap
                {
                    ccnt += 1
                    var cKeyValue : String = cKey;

                    if cKey.starts(with: "/")
                    {
                        let index = key.index(after: key.startIndex)
                        cKeyValue = String(cKey.suffix(from: index))
                    }
    
                    strbWhere.append(cKeyValue);
                    strbWhere.append(cValue);
    
                    if childMap.count > ccnt
                    {
                        strbWhere.append(" and ")
                    }
                }
                strbWhere.append("}");
            }
            
            if map.count > cnt
            {
                strbWhere.append(" and ");
            }
        }
        return strbWhere
    }
}
