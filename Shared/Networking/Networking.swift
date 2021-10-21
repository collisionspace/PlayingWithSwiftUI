//
//  Networking.swift
//  Networking
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

final class Networking {

    enum APIMethod: String {
        case get = "GET"
    }

    /// Will fetch data from an `url` as long as the `generic T` conforms to a `Codable`
    /// - parameter url: String
    /// - parameter method: APIMethod
    /// - parameter parameters: [String: String]?
    /// - parameter headers: [String: String]?
    static func request<T: Codable>(url: URL?, method: APIMethod = .get, parameters: [String: String]? = nil, headers: [String: String]? = nil) async -> Result<T, Error> {
        guard let url = url else {
             return .failure(RequestError.invalidUrl)
        }

        // Sets up the request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        // If any parameters has been passed in then attempt to serialize this
        // so it can be part of the request http body
        if let parameters = parameters,
           let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
            request.httpBody = httpBody
        }

        let session = URLSession.shared

        do {
            let (data, _) = try await session.data(for: request)
            let object = try T(jsonData: data)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }


//    /// Will fetch from the disk but it assumes that the `file` that is being fetched is `json`
//    /// - parameter url: URL?
//    /// - parameter completion: Result<T, Error>) -> Void
//    static func readFromDisk<T: Codable>(from url: URL?, completion: @escaping (Result<T, Error>) -> Void) {
//        guard let url =  url else {
//            completion(.failure(RequestError.invalidUrl))
//            return
//        }
//        do {
//            let data = try Data(contentsOf: url, options: .mappedIfSafe)
//            let jsonData = try T(jsonData: data)
//            completion(.success(jsonData))
//        } catch {
//            completion(.failure(error))
//        }
//    }
}

private extension Decodable {
    /// Allows for decoding of data to be a bit more nicer and generic
    init(jsonData: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}
