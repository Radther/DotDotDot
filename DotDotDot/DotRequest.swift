//
//  DotRequest.swift
//  DotDotDot
//
//  Created by Tom Singleton on 12/01/2017.
//  Copyright © 2017 Tom Singleton. All rights reserved.
//

import Foundation

// TODO: Add Marks
// TODO: Write description for `FireRequest`
/// Protocol to implement for making FireRequests.
public protocol DotRequest {
    
    /// The value to be returned from the request.
    associatedtype Value: Any
    
    /// Request base URL string.
    var url: String { get }
    /// Request path string.
    var path: String? { get }
    /// Request URL query parameters.
    var queryParameters: [String:String]? { get }
    /// Request basic auth username and password.
    var authentication: (username: String, password: String)? { get }
    /// Request headers.
    var headers: [String:String]? { get }
    /// Request HTTP method.
    var httpMethod: String { get }
    /// Request body data.
    var body: Data? { get }
    /// Request rejection codes.
    var rejectionCodes: [Range<Int>]? { get }

    /**
        Parse the data based from the given response and data.
        If the data or response isn't expected you can throw an error which will be passed
        to the `parseError` function.

        - Parameters:
            - response: The response from the request.
            - data: The data from the request.
            - Returns: The associated value.

        - Throws: Throws any custom error you wish to be passed to the `parseError` function.
    */
    func parseValue(response: URLResponse, data: Data?) throws -> Value

    /**
        Parse the error and return an error for the request handler.

        - Parameters:
            - error: Error from the request.
            - response: Response from the request.
            - data: Data from the request.

        - Returns: An error to be passed to the request handler.
    */
    func parseError(error: Error, response: URLResponse?, data: Data?) -> Error?

    /**
        Allows you to make any edits to the `URLComponents` object before the request URL
        is built.

        - Parameters:
            - components: The components for you to edit.

        - Returns: The updated components.
    */
    func editComponents(_ components: URLComponents) -> URLComponents

    /**
        Allows you to make any edits to the `URLRequest` before the request is run.

        - Parameters:
            - request: The request for you to edit.

        - Returns: The updated request.
    */
    func editRequest(_ request: URLRequest) -> URLRequest
    
}

// MARK: - Default implementation for certain parameters/functions.
public extension DotRequest {
    
    /// Default path (`nil`).
    public var path: String? {
        return nil
    }
    
    /// Default queryParameters (`nil`).
    public var queryParameters: [String:String]? {
        return nil
    }
    
    /// Default authentication (`nil`).
    public var authentication: (username: String, password: String)? {
        return nil
    }
    
    /// Default headers (`nil`).
    public var headers: [String:String]? {
        return nil
    }
    
    /// Default httpMethod (`GET`).
    public var httpMethod: String {
        return "GET"
    }
    
    /// Default body (`nil`).
    public var body: Data? {
        return nil
    }

    /// Default rejectionCodes (`nil`).
    public var rejectionCodes: [Range<Int>]? {
        return nil
    }

    /// Default editComponents implementation.
    public func editComponents(_ components: URLComponents) -> URLComponents {
        return components
    }

    /// Default editRequest implementation.
    public func editRequest(_ request: URLRequest) -> URLRequest {
        return request
    }

}

// TODO: Write comments
public extension DotRequest {
    public func createTask() -> DotTask<Value, Self> {
        return DotTask<Value, Self>(request: self)
    }
}
