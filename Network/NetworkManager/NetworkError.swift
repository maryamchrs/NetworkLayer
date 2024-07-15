//
//  NetworkError.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation

public enum NetworkError: Error {
    case noData
    case unableToDecode
    case URLSessionError(String)
    case networkConnectionError
    case serverError
    case outDated
    case unauthorized
    case notAcceptedStatusCode(Int)
    case general
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No Data"
        case .unableToDecode:
            return "Unable To Decode"
        case .URLSessionError(let model):
            return model
        case .networkConnectionError:
            return "some problem occured in connection"
        case .serverError:
            return "some problem occured in server"
        case .outDated:
            return "out dated"
        case .unauthorized:
            return "User is not authorized"
        case .notAcceptedStatusCode(let statusCode):
            return "Response Status code is \(statusCode)"
        case .general:
            return "Something went wrong"
        }
    }
}
