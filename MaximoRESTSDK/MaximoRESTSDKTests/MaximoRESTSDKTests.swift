//
//  MaximoRESTSDKTests.swift
//  MaximoRESTSDKTests
//
//  Created by Silvino Vieira de Vasconcelos Neto on 10/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import XCTest
import MaximoRESTSDK

class MaximoRESTSDKTests: XCTestCase {
    
    static var connector : MaximoConnector?
    static var workOrder : [String: Any]?
    
    override class func setUp() {
        super.setUp()
        var options = Options().user(user: "wilson").password(password: "wilson").auth(authMode: "maxauth")
        options = options.host(host: "9.85.129.75").port(port: 7001).lean(lean: true)
        connector = MaximoConnector(options: options)
        do {
            try connector!.connect()
            print("Login Success!")
        } catch {
            print("Error while logging in")
        }
    }
    
    override class func tearDown() {
        do {
            print("Logging out!")
            try connector!.disconnect()
        } catch {
            print("Error while logging out")
        }
        super.tearDown()
    }

    func testLoadWorkOrder() throws {
        let workOrderSet = MaximoRESTSDKTests.connector!.resourceSet(osName: "mxwo")
        _ = workOrderSet.pageSize(pageSize: 1)
        _ = workOrderSet._where(whereClause: "spi:wonum=\"1002\" and spi:istask=0")
        _ = workOrderSet.paging(type: true)
        _ = try workOrderSet.fetch()
        let resource = try workOrderSet.member(index: 0)
        MaximoRESTSDKTests.workOrder = try resource!.toJSON()
        
        print("Fetching a Work Order Success!")
        print("Work Order JSON: ")
        print(MaximoRESTSDKTests.workOrder!)
    }

    func testUpdateWorkOrder() throws {
        print("Updating a Work Order")
        let uri = MaximoRESTSDKTests.connector!.getCurrentURI() + "/os/mxwo/" +
            Util.stringValue(value: MaximoRESTSDKTests.workOrder!["workorderid"]!)
        MaximoRESTSDKTests.workOrder!["description"] = "Maximo iOS Integration Test"
        MaximoRESTSDKTests.workOrder!["wopriority"] = 1
        MaximoRESTSDKTests.workOrder!["estdur"] = 25.0
        _ = try MaximoRESTSDKTests.connector!.update(uri: uri, jo: MaximoRESTSDKTests.workOrder!, properties: nil)
    }
}
