//
//  MaximoConnector.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

class MaximoConnector {

    var options : Options
    var valid : Bool = false
    var debug : Bool = false
    var lastResponseCode : Int = 0
    var cookies : [String] = [String]()

    let HTTP_METHOD_POST = "POST";
    let HTTP_METHOD_GET = "GET";
    let HTTP_METHOD_PATCH = "PATCH";
    let HTTP_METHOD_MERGE = "MERGE";
    let HTTP_METHOD_DELETE = "DELETE";
    let HTTP_METHOD_BULK = "BULK";
    let HTTP_METHOD_SYNC = "SYNC";
    let HTTP_METHOD_MERGESYNC = "MERGESYNC";
    
    var httpMethod : String = "GET";// by default it is get
    
    init() {
        self.options = Options()
    }

    init(options: Options) {
        self.options = options
    }

    func getAttachmentData(uri: String) throws -> Data {
        return Data()
    }

    func getAttachmentData(uri: String, headers: [String: Any]) throws -> Data {
        return Data()
    }

    func get(uri: String) throws -> [String: Any] {
        return try self.get(uri: uri, headers: nil)
    }

    func get(uri: String, headers: [String: Any]?) throws -> [String: Any] {
        return [:]
    }

    /**
     * Delete the resource/attachment
     * @throws IOException
     * @throws OslcException
     */
    func delete(uri: String) throws {
        // TODO: Implement method
    }
}
