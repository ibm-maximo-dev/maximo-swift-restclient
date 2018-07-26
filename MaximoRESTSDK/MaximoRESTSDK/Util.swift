//
//  Util.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 12/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

// MARK: - Equatable
extension Collection where Element: Equatable {
    func split<S: Sequence>(separators: S) -> [SubSequence]
        where Element == S.Element
    {
        return split { separators.contains($0) }
    }
}

/// Util object.
public class Util {
    
    /// Return the type inside the string.
    ///
    /// - Parameter value: Any object to be handled.
    /// - Returns: type of the information inside paramer.
    public class func stringValue(value: Any) -> String {
        let date = value as? Date
        let intNumber = value as? Int
        let doubleNumber = value as? Double
        let floatNumber = value as? Float
        let boolean = value as? Bool

        if (date != nil) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: date!)
        }
        else if (intNumber != nil) {
            return String(intNumber!)
        }
        else if (doubleNumber != nil) {
            return String(doubleNumber!)
        }
        else if (floatNumber != nil) {
            return String(floatNumber!)
        }
        else if (boolean != nil) {
            return String(boolean!)
        }
        else {
            return value as! String
        }
    }

    /// URL encoder.
    ///
    /// - Parameter value: String  containing the URL's information.
    /// - Returns: Escaped string within the URL's information.
    public class func urlEncode(value: String) -> String {
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }
    
    /// URL enconder Base64.
    ///
    /// - Parameter value: String containing the URL's information to be encoded into a Base64 enconding type.
    /// - Returns: URL's string Base64 encoded.
    public class func encodeBase64(value: String) -> String {
        let utf8String = value.data(using: String.Encoding.utf8)
        let base64Encoded = utf8String?.base64EncodedString()
        return base64Encoded!
    }
}
