//
//  HTTPClient.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation
import Combine

public protocol HTTPClient {
    func customiseSessionConfiguration(timeout: TimeInterval,
                                       cachePolicy: URLRequest.CachePolicy) -> URLSession
  
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
    func perform(_ request: URLRequest) async throws
}

extension URLSession: HTTPClient {
    
    public func customiseSessionConfiguration(timeout: TimeInterval,
                                              cachePolicy: URLRequest.CachePolicy) -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        /*
         A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
         */
        configuration.allowsExpensiveNetworkAccess = false
        /*
         A Boolean value that indicates whether connections may use the network when the user has specified Low Data Mode.
         */
        configuration.allowsConstrainedNetworkAccess = false
        configuration.waitsForConnectivity = true
        
        configuration.requestCachePolicy = cachePolicy
        
        return URLSession(configuration: configuration)
    }
    
    /*
     This error only use with URLSession so no need to move in outside the extension URLSession
     */
    public struct InvalidHTTPResponseError: Error {}
    /*
     TIP:
     HTTPURLResponse: is a subclass of URLResponse and specifically deals with HTTP responses.
     It provides additional HTTP-specific information, such as status code, headers, and localized status code string
     */
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
    
    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse) = try await data(for: request)
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw InvalidHTTPResponseError()
        }
        return (result.data, httpResponse)
    }
   
    public func perform(_ request: URLRequest) async throws {
        let _ = try await data(for: request)
    }
}
