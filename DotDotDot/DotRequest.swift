//
//  DotRequest.swift
//  DotDotDot
//
//  Created by Tom Singleton on 12/01/2017.
//  Copyright © 2017 Tom Singleton. All rights reserved.
//

import Foundation

/**
    # DotRequest protocol
    
    To use DotDotDot you must implement this protocol. You can then use the `createTask`
    method on object that implements the protocol to create a `DotTask`.
 
    The only required variable to implement is `url`. The rest are optional and 
    include things such as:
     - path: The path that comes after the url
     - queryParameters: The parameters placed at the end of the url
     - httpMethod: The HTTP Method to be used (GET, PUT, ETC.)
    
    To see the full list you can view the documentation in the `docs` folder
    of the project.
 
    If the option isn't provided you can implement the `editComponents` and `editRequest` 
    methods to make any changes before the request is made.
*/
public protocol DotRequest {
    
    /// The value to be returned from the request.
    associatedtype Value: Any
    
    // MARK: Variables
    
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
    
    // MARK: Methods

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

// MARK: - Extensions

// MARK: Default Implementation
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

// MARK: Create Task
public extension DotRequest {
    
    /** 
        Creates a `DotTask` object from the current request.
 
        - Returns: `DotTask` object.
    */
    public func createTask() -> DotTask<Value, Self> {
        return DotTask<Value, Self>(request: self)
    }
}
