//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation
import Combine

public protocol NetworkManagerProtocol: AnyObject {
    var isNetworkReachable: Bool { get }
    
    func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response
    func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error>
}

public final class NetworkManager {
    
    // MARK: - Properties and Constants
    // MARK: Public
    public var isNetworkReachable: Bool = true
    
    // MARK: Private
    private var httpClient: HTTPClient
    private var requestMapper: RequestMapperProtocol
    private let errorMepper: ErrorMapperProtocol
    
    private let networkMonitor = NetworkMonitor()
    private var cancellable = Set<AnyCancellable>()
    
    public init(
        client: HTTPClient = URLSession.shared,
        requestMapper: RequestMapperProtocol = APIHTTPRequestMapper(),
        errorMepper: ErrorMapperProtocol = ErrorMapper()
    ) {
        self.httpClient = client
        self.requestMapper = requestMapper
        self.errorMepper = errorMepper
        observeForConnectivityChanges()
    }
}

extension NetworkManager: NetworkManagerProtocol {
    public func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        var response: HTTPURLResponse?
        do {
            let data: (value: Data, response: HTTPURLResponse) = try await httpClient.perform(urlRequest)
            response = data.response
            let convertedData: Response = try requestMapper.map(
                data: data.value,
                response: data.response
            )
            return convertedData
        } catch {
            throw errorMepper.map(
                error: error,
                response: response,
                isNetworkReachable: isNetworkReachable
            )
        }
    }
    
    public func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error> {
        return httpClient
            .publisher(urlRequest)
            .tryMap { [weak self] (data, httpURLResponse) in
                guard let self else {
                    throw NetworkError.general
                }
                do {
                    let convertedData: Response = try self.requestMapper.map(
                        data: data,
                        response: httpURLResponse
                    )
                    return convertedData
                } catch {
                    throw errorMepper.map(
                        error: error,
                        response: httpURLResponse,
                        isNetworkReachable: self.isNetworkReachable
                    )
                }
            }
            .eraseToAnyPublisher()
    }
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
