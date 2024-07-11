//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation

public protocol NetworkManagerProtocol: AnyObject {
    func makeRequest()
}

public final class NetworkManager {
    
    private var httpClient: HTTPClient?
    
    public init(client: HTTPClient = URLSession.shared) {
        self.httpClient = client
    }
}

extension NetworkManager: NetworkManagerProtocol {
    public func makeRequest() {
//        Task {
//            do {
//                guard let httpClient, let urlRequest = MockEndpoint.something.urlRequest else { return }
//                let data: (Data, URLResponse) = try await httpClient.perform(urlRequest)//.perform(urlRequest)
//                print(data)
//            }
//            catch {
//                print(error)
//            }
//        }
    }
}

extension NetworkManager {
    func makeConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        /*
         A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
         */
        configuration.allowsExpensiveNetworkAccess = false
        /*
         A Boolean value that indicates whether connections may use the network when the user has specified Low Data Mode.
         */
        configuration.allowsConstrainedNetworkAccess = false
        configuration.waitsForConnectivity = true
        return configuration
    }
}
