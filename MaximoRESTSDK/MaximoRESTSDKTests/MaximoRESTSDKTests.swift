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
        let testBundle = Bundle(for: MaximoRESTSDKTests.self)
        if let url = testBundle.url(forResource: "Info", withExtension: "plist"),
            let infoPlist = NSDictionary(contentsOf: url) as? [String:Any] {
            guard let maximoConnectorDict = infoPlist["MaximoConnectorConfig"] as? [String:Any] else {
                print("No MaximoConnectorConfig present in Info.plist. Please add relevant information")
                return
            }
            print("MaximoRESTSDKTests setUp() called, Connecting to \(maximoConnectorDict["host"] as! String):\(maximoConnectorDict["port"] as! Int)")
            var options = Options().user(user: maximoConnectorDict["user"] as! String).password(password: maximoConnectorDict["password"] as! String).auth(authMode: maximoConnectorDict["authMode"] as! String)
            options = options.host(host: maximoConnectorDict["host"] as! String).port(port: maximoConnectorDict["port"] as! Int).lean(lean: true)
            connector = MaximoConnector(options: options)
            do {
                try connector!.connect()
                print("Login Success!")
            } catch {
                print("Error while logging in")
            }
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
        try print(resource!.toJSON())
        MaximoRESTSDKTests.workOrder = try resource!.toJSON()
        print("Fetching a Work Order JSON: \(String(describing: MaximoRESTSDKTests.workOrder))")
    }

    func testUpdateWorkOrder() throws {
        print("Updating a Work Order")
        guard let woID = MaximoRESTSDKTests.workOrder?["workorderid"] else {
            print("Unable to update work order. workorder Id not present")
            return
        }
        let uri = MaximoRESTSDKTests.connector!.getCurrentURI() + "/os/mxwo/\(woID)"
        MaximoRESTSDKTests.workOrder!["description"] = "Maximo iOS Integration Test"
        MaximoRESTSDKTests.workOrder!["wopriority"] = 1
        MaximoRESTSDKTests.workOrder!["estdur"] = 25.0
        _ = try MaximoRESTSDKTests.connector!.update(uri: uri, jo: MaximoRESTSDKTests.workOrder!, properties: nil)
        print("Updating a Work Order JSON: \(String(describing: MaximoRESTSDKTests.workOrder))")
    }
}
