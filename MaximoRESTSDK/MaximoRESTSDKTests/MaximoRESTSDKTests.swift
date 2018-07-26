//
//  MaximoRESTSDKTests.swift
//  MaximoRESTSDKTests
//
//  Created by Silvino Vieira de Vasconcelos Neto on 10/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import XCTest
import MaximoRESTSDK

///REST SDK Test
class MaximoRESTSDKTests: XCTestCase {
    
    /// Maximo Connector
    static var connector : MaximoConnector?
    //String array of work orders.
    static var workOrder : [String: Any]?
    
    /// Setup this object to connect wiht Maximo REST service.
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

    /// Disconnect from server.
    override class func tearDown() {
        do {
            print("Logging out!")
            try connector!.disconnect()
        } catch {
            print("Error while logging out")
        }
        super.tearDown()
    }

    /// Test to load an Work Order into Maximo
    ///
    /// - Throws:
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

    /// Test update an existent Work Order.
    ///
    /// - Throws:
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

    /// Test create a new Work Order into the Maximo instance.
    ///
    /// - Throws: <#throws value description#>
    func testCreateWorkOrder() throws {
        print("Creating a Work Order")
        let uri = MaximoRESTSDKTests.connector!.getCurrentURI() + "/os/mxwo/"
        let newWorkOrder : [String: Any] = ["description": "Maximo iOS Create Test", "estdur": 2.0, "siteid": "BEDFORD", "orgid": "EAGLENA"]
        _ = try MaximoRESTSDKTests.connector!.create(uri: uri, jo: newWorkOrder, properties: nil)
    }

}
