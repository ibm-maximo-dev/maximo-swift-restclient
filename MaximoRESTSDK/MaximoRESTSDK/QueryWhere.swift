//
//  QueryWhere.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public class QueryWhere {
    
    var strbWhere : String = String()
    var map : [String: Any] = [:]
    var currentKey : String = String()
    
    public func _where (name: String) -> QueryWhere
    {
        currentKey = name
        return self
    }
    
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
    
    public func getCurrentKey() -> String
    {
        if currentKey.contains(".")
        {
            var attrPath = currentKey.split(separator: ".")
            return String(attrPath[1]);
        }
        return currentKey
    }
    
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

    public func equalTo(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    public func startsWith(value: String) -> QueryWhere
    {
        let  s = Util.stringValue(value: value + "%")
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    public func endsWith(value: String) -> QueryWhere
    {
        let s = Util.stringValue(value: "%" + value)
        self.setQueryToken(s: "=" + s)
        return self
    }

    public func like(value: String) -> QueryWhere
    {
        let s = Util.stringValue(value: "%" + value + "%")
        self.setQueryToken(s: "=" + s)
        return self
    }
    
    public func gt(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: ">" + s)
        return self
    }
    
    public func gte(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: ">=" + s)
        return self
    }
    
    public func lt(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "<" + s)
        return self
    }
    
    public func lte(value: Any) -> QueryWhere
    {
        let s = Util.stringValue(value: value)
        self.setQueryToken(s: "<=" + s)
        return self
    }

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
