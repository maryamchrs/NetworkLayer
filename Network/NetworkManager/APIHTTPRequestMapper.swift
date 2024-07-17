//
//  APIHTTPRequestMapper.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation

public protocol RequestMapperProtocol: AnyObject {
    var jsonDecoder: JSONDecoder { get set }
    func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable
}

public class APIHTTPRequestMapper: RequestMapperProtocol {
    
    public var jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
    
    public func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.notAcceptedStatusCode(response.statusCode)
        }
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.unableToDecode
        }
    }
}
