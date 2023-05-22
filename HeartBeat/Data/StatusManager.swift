
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import Foundation
import UIKit

enum HTTPStatus {
    case continueStatus
    case ok
    case multipleChoice
    case badRequest
    case internalServerError
    case error

    init(statusCode: Int) {
        switch statusCode {
        case 100..<200 :
            self = .continueStatus
        case 200..<300:
            self = .ok
        case 300..<400:
            self = .multipleChoice
        case 400..<500:
            self = .badRequest
        case 500..<600:
            self = .internalServerError
        default:
            self = .error
        }
    }
}

enum NetworkStatus {
    case sendingInit
    case sendingSuccess
    case sendingFail
    
    var statusCode: Bool {
        switch self {
        case .sendingInit:
            return false
        case .sendingFail:
            return false
        case .sendingSuccess:
            return true
        }
    }
    
    func sendingStatus() -> Bool {
        return self.statusCode
    }
}

