//
//  HTTPClient.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation
import Combine

public protocol HTTPClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
    func perform(_ request: URLRequest) async throws -> (Data, URLResponse)
    func perform(_ request: URLRequest) async throws
}

extension URLSession: HTTPClient {
    /*
     This error only use with URLSession so no need to move in outside the extension URLSession
     */
    public struct InvalidHTTPResponseError: Error {}
    
    public func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw InvalidHTTPResponseError()
                }
                return (result.data, httpResponse)
            })
            .eraseToAnyPublisher()
    }
    
    public func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
   
    public func perform(_ request: URLRequest) async throws {
        let _ = try await data(for: request)
    }
}
