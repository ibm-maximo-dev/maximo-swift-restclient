//
//  OslcError.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/// OslcError enumeration
///
/// - attachmentAlreadyLoaded: Attachment is already loaded.
/// - resourceAlreadyLoaded: Resource is already loaded.
/// - invalidAttachment: Invalid attachment.
/// - invalidResource: Invalid resource.
/// - invalidRelation: Invalid relation.
/// - invalidURL: Invalid URL.
/// - invalidRequest: Invalid request.
/// - invalidResponse: Invalid response.
/// - loginFailure: Login failure.
/// - serverError: Server error.
/// - connectionAlreadyEstablished: The connection is already estabilished.
/// - invalidConnectorInstance: Invalid connector instance.
/// - noAttachmentFound: No attachment found.
/// - noResourceFound: No resource found.
/// - noRelationFound: No relation found.
/// - noURLFound: No URL found.
public enum OslcError : Error {
    case attachmentAlreadyLoaded
    case resourceAlreadyLoaded
    case invalidAttachment
    case invalidResource
    case invalidRelation
    case invalidURL
    case invalidRequest
    case invalidResponse
    case loginFailure(message: String)
    case serverError(code: Int, message: String)
    case connectionAlreadyEstablished
    case invalidConnectorInstance
    case noAttachmentFound
    case noResourceFound
    case noRelationFound
    case noURLFound
}
