//
//  MaximoRESTClientTests.swift
//  MaximoRESTClientTests
//
//  Created by Silvino Vieira de Vasconcelos Neto on 10/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Quick
import Nimble
import MaximoRESTClient

class MaximoRESTClientTests: QuickSpec {
    
    override func spec() {
        describe("MaximoRESTClient") {
            it("is a framework to communicate with Maximo") {
                var options = Options().user(user: "wilson").password(password: "wilson").auth(authMode: "maxauth")
                options = options.host(host: "9.80.209.185").port(port: 7001).lean(lean: true)
                let connector = MaximoConnector(options: options)
                do {
                    try connector.connect()
                    print("Login Success!")
                    
                    let workOrderSet = connector.resourceSet(osName: "mxwo")
                    _ = workOrderSet.pageSize(pageSize: 1)
                    _ = workOrderSet._where(whereClause: "spi:istask=0")
                    _ = workOrderSet.paging(type: true)
                    _ = try workOrderSet.fetch()
                    let resource = try workOrderSet.member(index: 0)
                    let workOrder = try resource!.toJSON()

                    print("Fetching a Work Order Success!")
                    print(workOrder)
                } catch {
                    print("Maximo connection failure.")
                }
            }
        }
    }
    
}
