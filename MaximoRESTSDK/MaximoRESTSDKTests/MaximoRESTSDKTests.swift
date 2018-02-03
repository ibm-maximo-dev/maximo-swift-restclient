//
//  MaximoRESTSDKTests.swift
//  MaximoRESTSDKTests
//
//  Created by Silvino Vieira de Vasconcelos Neto on 10/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Quick
import Nimble
import MaximoRESTSDK

class MaximoRESTSDKTests: QuickSpec {
    
    override func spec() {
        describe("MaximoRESTSDK") {
            it("is a framework to communicate with Maximo") {
                var options = Options().user(user: "wilson").password(password: "wilson").auth(authMode: "maxauth")
                options = options.host(host: "9.85.169.134").port(port: 7001).lean(lean: true)
                let connector = MaximoConnector(options: options)
                do {
                    try connector.connect()
                    print("Login Success!")
                    
                    let workOrderSet = connector.resourceSet(osName: "mxwo")
                    _ = workOrderSet.pageSize(pageSize: 1)
                    _ = workOrderSet._where(whereClause: "spi:wonum=\"1002\" and spi:istask=0")
                    _ = workOrderSet.paging(type: true)
                    _ = try workOrderSet.fetch()
                    let resource = try workOrderSet.member(index: 0)
                    var workOrder = try resource!.toJSON()

                    print("Fetching a Work Order Success!")
                    print("Work Order JSON: ")
                    print(workOrder)

                    print("Updating a Work Order")
                    let uri = connector.getCurrentURI() + "/os/mxwo/" + Util.stringValue(value: workOrder["workorderid"]!)
                    workOrder["description"] = "Maximo iOS Integration Test"
                    workOrder["wopriority"] = 1
                    workOrder["estdur"] = 25.0
                    _ = try connector.update(uri: uri, jo: workOrder, properties: nil)

                    print("Logging out!")
                    try connector.disconnect()
                } catch {
                    print("Maximo connection failure.")
                }
            }
        }
    }
    
}
