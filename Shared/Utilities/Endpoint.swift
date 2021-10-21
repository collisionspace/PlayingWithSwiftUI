//
//  Endpoint.swift
//  Endpoint
//
//  Created by Daniel Slone on 4/9/21.
//

import Foundation

@propertyWrapper
struct Endpoint {
    var wrappedValue: URLComponents

    init(_ wrappedValue: String, path: String) {
        self.wrappedValue = Endpoint.construct(endpoint: wrappedValue, path: path)
    }

    private static func construct(endpoint: String, path: String) -> URLComponents {
        guard var urlComponents = URLComponents(string: endpoint) else {
            return URLComponents()
        }
        urlComponents.path = path
        return urlComponents
    }
}
