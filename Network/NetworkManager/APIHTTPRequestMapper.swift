//
//  APIHTTPRequestMapper.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation

public struct APIHTTPRequestMapper {
    /*
     With this map you are able to make some generic decision.
     for instance if you want you can deal with server in case they send 401 you navigate the user to the ogin and authorize again.
     You can have a lot more for every single status code.
     */
    public func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        if (200..<300) ~= response.statusCode {
            return try JSONDecoder().decode(T.self, from: data)
        } else if response.statusCode == 401 {
            throw NetworkError.unauthorized
        } else {
            throw NetworkError.serverErrror
        }
    }
}
