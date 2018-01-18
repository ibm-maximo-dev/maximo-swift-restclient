//
//  Aggregation.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 13/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class Aggregation {
    
    var mc: MaximoConnector
    var uri: String
    var aliasMap : [String: String] = [:]
    var gbColsList : [String] = []
    var gbFiltersMap : [String: String] = [:]
    var gbSortByList : [String] = []
    
    init(mc: MaximoConnector, uri: String) {
        self.mc = mc
        self.uri = uri
    }

    func groupByOn(attributes: [String]) -> Aggregation {
        for attribute in attributes {
            self.gbColsList.append(attribute)
        }
        return self
    }

    func count() -> Aggregation {
        return self.count(alias: nil)
    }
    
    func count(alias: String?) -> Aggregation {
        if alias == nil {
            self.aliasMap["count.*"] = "count.*"
        } else {
            self.aliasMap[alias!] = "count.*"
        }
        self.gbColsList.append("count.*");
        return self
    }

    func avgOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }

    func avgOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "avg", attribute: attribute, alias: alias)
    }
    
    func sumOn(attribute: String) -> Aggregation {
        return self.sumOn(attribute: attribute, alias: nil)
    }
    
    func sumOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "sum", attribute: attribute, alias: alias);
    }

    func minOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }
    
    func minOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "min", attribute: attribute, alias: alias)
    }
    
    func maxOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }
    
    func maxOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "max", attribute: attribute, alias: alias)
    }
    
    func aggregateOn(function: String, attribute: String, alias: String?) -> Aggregation {
        if alias == nil {
            self.aliasMap[function + "." + attribute] = "sum." + attribute
        } else {
            self.aliasMap[alias!] = function + "." + attribute
        }
        self.gbColsList.append(function + "." + attribute)
        return self
    }

    func having(conditions: [String]) -> Aggregation {
        for condition in conditions {
            var cond = condition
            cond = cond.replacingOccurrences(of: ">=", with: "@") // Changing >= to a single character @ to use split method.
            cond = cond.replacingOccurrences(of: "<=", with: "#") // Changing <= to a single character # to use split method.
            var parseCondition = cond.split(separators: ["@", "#", ">", "<", "="])
            if parseCondition.count > 1 {
                var operation : String = String()
                if condition.contains(">=") {
                    operation = ">=";
                } else if condition.contains("<=") {
                    operation = "<=";
                } else if condition.contains("=") {
                    operation = "=";
                } else if condition.contains("<") {
                    operation = "<";
                } else if condition.contains(">") {
                    operation = ">";
                }
                self.gbFiltersMap[String(parseCondition[0])] = operation + parseCondition[1]
            }
        }
        return self
    }

    func sortBy(attributes: [String]) -> Aggregation {
        for attribute in attributes {
            self.gbSortByList.append(attribute);
        }
        return self
    }

    func processGroupBy() throws -> [Any] {
        if !self.uri.contains("?") {
            self.uri.append("?")
        }
        if !self.gbColsList.isEmpty {
            self.uri.append("&gbcols=")
            for str in self.gbColsList {
                self.uri.append(Util.urlEncode(value: str))
                self.uri.append(",")
            }
            if self.uri.hasSuffix(",") {
                var newUri : String = self.uri
                newUri.remove(at: newUri.index(before: newUri.endIndex))
                self.uri = newUri
            }
        }
        if !gbFiltersMap.isEmpty && !self.aliasMap.isEmpty {
            self.uri.append("&gbfilter=")
            for (key, value) in gbFiltersMap {
                var newKey : String = key
                if self.aliasMap[key] != nil {
                    newKey = self.aliasMap[key]!
                }
                self.uri.append(Util.urlEncode(value: newKey + value))
                self.uri.append(" and ")
            }
            if self.uri.hasSuffix(" and ") {
                let newUri = self.uri
                let index = newUri.index(newUri.endIndex, offsetBy: -5)
                self.uri = String(newUri.prefix(upTo: index))
            }
        }
        if !self.gbSortByList.isEmpty {
            self.uri.append("&gbsortby=")
            for str in self.gbSortByList {
                var keys = str.split(separators: ["+", "-"])
                var key : String = String()
                if keys.count > 1 {
                    key = String(keys[1])
                }else
                {
                    key = String(keys[0])
                }
                if self.aliasMap[key] != nil {
                    key = self.aliasMap[key]!
                    if key == "count.*" {
                        key = "count"
                    }
                }
                if str.contains("+") {
                    key = "+" + key;
                }else{
                    key = "-" + key;
                }
                self.uri.append(Util.urlEncode(value: key))
                self.uri.append(",")
            }
            if self.uri.hasSuffix(",") {
                var newUri : String = self.uri
                newUri.remove(at: newUri.index(before: newUri.endIndex))
                self.uri = newUri
            }
        }

        let jarr = try self.mc.groupBy(uri: self.uri)
        return jarr;
    }
}
