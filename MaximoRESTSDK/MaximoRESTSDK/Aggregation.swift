//
//  Aggregation.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 13/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// Utility class to aggregate data.
public class Aggregation {
    
    /// Maximo Connector object
    var mc: MaximoConnector
    /// URI information.
    var uri: String
    /// Alias map.
    var aliasMap : [String: String] = [:]
    /// List of columns.
    var gbColsList : [String] = []
    /// Map of filters.
    var gbFiltersMap : [String: String] = [:]
    /// Sort by list.
    var gbSortByList : [String] = []
    
    /// Initialize object.
    ///
    /// - Parameters:
    ///   - mc: Maximo Connector
    ///   - uri: URI information.
    public init(mc: MaximoConnector, uri: String) {
        self.mc = mc
        self.uri = uri
    }

    /// Group by
    ///
    /// - Parameter attributes: Attribute description.
    /// - Returns: Aggregation object with updated columns list
    public func groupByOn(attributes: [String]) -> Aggregation {
        for attribute in attributes {
            self.gbColsList.append(attribute)
        }
        return self
    }

    /// Count statement.
    ///
    /// - Returns: Updated string into an Aggregation object.
    public func count() -> Aggregation {
        return self.count(alias: nil)
    }
    
    /// Count statement.
    ///
    /// - Parameter alias: Aliases for the element.
    /// - Returns: Aggregation object with alias set.
    public func count(alias: String?) -> Aggregation {
        if alias == nil {
            self.aliasMap["count.*"] = "count.*"
        } else {
            self.aliasMap[alias!] = "count.*"
        }
        self.gbColsList.append("count.*");
        return self
    }

    /// Average statement.
    ///
    /// - Parameter attribute: Attribute name.
    /// - Returns: Aggregation object with average set.
    public func avgOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }

    /// Average statement that uses an alias.
    ///
    /// - Parameters:
    ///   - attribute: Attribute name.
    ///   - alias: Alias name.
    /// - Returns: Updated aggregation object.
    public func avgOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "avg", attribute: attribute, alias: alias)
    }
    
    /// Sum statement.
    ///
    /// - Parameter attribute: Attribute name
    /// - Returns: Updated ggregation object.
    public func sumOn(attribute: String) -> Aggregation {
        return self.sumOn(attribute: attribute, alias: nil)
    }
    
    /// Sum statement that uses an alias.
    ///
    /// - Parameters:
    ///   - attribute: Attribute name.
    ///   - alias: Alias name.
    /// - Returns: Updated ggregation object.
    public func sumOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "sum", attribute: attribute, alias: alias);
    }

    /// Minimum value.
    ///
    /// - Parameter attribute: Attribute name.
    /// - Returns: Updated ggregation object.
    public func minOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }
    
    /// Minimum statement that uses an alias.
    ///
    /// - Parameters:
    ///   - attribute: Attribute name.
    ///   - alias: Alias
    /// - Returns: Updated aggregation object.
    public func minOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "min", attribute: attribute, alias: alias)
    }
    
    /// Maximum statement.
    ///
    /// - Parameter attribute: Attribute name.
    /// - Returns: Updated aggregation object.
    public func maxOn(attribute: String) -> Aggregation {
        return self.avgOn(attribute: attribute, alias: nil)
    }
    
    /// Maximum statement that uses an alias.
    ///
    /// - Parameters:
    ///   - attribute: Attribute name.
    ///   - alias: Alias.
    /// - Returns: Updated ggregation object.
    public func maxOn(attribute: String, alias: String?) -> Aggregation {
        return self.aggregateOn(function: "max", attribute: attribute, alias: alias)
    }
    
    /// Aggregate statements.
    ///
    /// - Parameters:
    ///   - function: Function.
    ///   - attribute: Attribute
    ///   - alias: Alias
    /// - Returns: Updated aggregation object.
    public func aggregateOn(function: String, attribute: String, alias: String?) -> Aggregation {
        if alias == nil {
            self.aliasMap[function + "." + attribute] = "sum." + attribute
        } else {
            self.aliasMap[alias!] = function + "." + attribute
        }
        self.gbColsList.append(function + "." + attribute)
        return self
    }

    /// Having statement.
    ///
    /// - Parameter conditions: Conditions.
    /// - Returns: Updated aggregation object.
    public func having(conditions: [String]) -> Aggregation {
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

    /// Sort by statement.
    ///
    /// - Parameter attributes: Attribute name.
    /// - Returns: Sorted aggregation object.
    public func sortBy(attributes: [String]) -> Aggregation {
        for attribute in attributes {
            self.gbSortByList.append(attribute);
        }
        return self
    }

    /// Process group by
    ///
    /// - Returns: Updated and grouped contents of this Aggregation object
    /// - Throws: Exception
    public func processGroupBy() throws -> [Any] {
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
