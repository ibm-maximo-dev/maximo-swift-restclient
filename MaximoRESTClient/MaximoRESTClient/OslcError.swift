//
//  OslcError.swift
//  MaximoRESTClient
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public enum OslcError : Error {
    case attachmentAlreadyLoaded
    case resourceAlreadyLoaded
    case invalidResource
    case invalidRelation
    case invalidURL
    case invalidRequest
    case connectionAlreadyEstablished
    case invalidConnectorInstance
}
