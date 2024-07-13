//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation
import Combine

public protocol NetworkManagerProtocol: AnyObject {
    func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response
}

public final class NetworkManager {
    
    private var httpClient: HTTPClient
    private var requestMapper: RequestMapperProtocol
    
    private let networkMonitor = NetworkMonitor()
    private var cancellable = Set<AnyCancellable>()
    
    var isNetworkReachable: Bool = true
    
    public init(client: HTTPClient = URLSession.shared, requestMapper: RequestMapperProtocol = APIHTTPRequestMapper()) {
        self.httpClient = client
        self.requestMapper = requestMapper
        observeForConnectivityChanges()
    }
}

extension NetworkManager: NetworkManagerProtocol {
    public func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        do {
            let data: (value: Data, response: HTTPURLResponse) = try await httpClient.perform(urlRequest)
            let convertedData: Response = try requestMapper.map(
                data: data.value,
                response: data.response,
                isNetworkReachable: isNetworkReachable
            )
            return convertedData
        } catch {
            // TODO: - Add logic to convert error
            throw error
        }
    }
    
    public func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error> {
        return httpClient
            .publisher(urlRequest)
            .tryMap { [weak self] (data, response) in
                do {
                    guard let self else {
                        throw NetworkError.general
                    }
                    let convertedData: Response = try self.requestMapper.map(
                        data: data,
                        response: response,
                        isNetworkReachable: self.isNetworkReachable
                    )
                    return convertedData
                } catch {
                    // TODO: - Add logic to convert error
                    throw error
                }
            }
            .eraseToAnyPublisher()
    }
    
    //    public func makeRequest() {
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
//    }
}

extension NetworkManager {
    private func makeConfiguration() -> URLSessionConfiguration {
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
    
    /// Start observing the connectivity changes to aware user due to the fact that they need this information.
    private func observeForConnectivityChanges() {
        networkMonitor.startMonitoringNetwork()
            .sink { [weak self] networkInfo in
                guard let self else { return }
                self.isNetworkReachable = networkInfo.isActive
            }
            .store(in: &cancellable)
    }
}
