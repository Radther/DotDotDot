//
//  DotTask.swift
//  DotDotDot
//
//  Created by Tom Singleton on 12/01/2017.
//  Copyright © 2017 Tom Singleton. All rights reserved.
//

import Foundation

/**
    DotTask errors

    - failedToCreateURL: The URL couldn't be created from the `DotRequest`
    - failedToCreateRequest: The `URLRequest` couldn't be created from the `DotRequest`
    - otherError: Another error has occurred that isn't handled by the `DotTask`
*/
public enum DotTaskError: Error {
    case failedToCreateURL(String?)
    case failedToCreateRequest(String?)
    case missingOrBadResponse(response: URLResponse?)
    case rejectedStatusCode(statusCode: Int)
    case otherError(Error)
}

/**
    # DotTask
    A DotTask (or simply task) instance is an object that can use a `DotRequest`. This is done by
    calling the `start` method. A task is reusable. `Start` can be called as many times as you like.
    This means if a request needs to be repeated (such as pull-to-refresh) the task can be started again.
    If a current task is already running this will be canceled and a new one will be started.
*/
public class DotTask<Value, Request: DotRequest> where Request.Value == Value {

    // MARK: - Event Blocks
    
    /// Closure to be called before before starting a task.
    public typealias BeforeDot = (() -> ())?
    /// Closure to be called when completing a task.
    public typealias CompletionDot = ((Value) -> ())?
    /// Closure to be called when a task errors.
    public typealias ErrorDot = ((Error) -> ())?
    /// Closure to be called after everything is over.
    public typealias FinallyDot = (() -> ())?
    /// Closure to be called when a task is canceled.
    public typealias CancelDot = (() -> ())?
    
    /// The before closure.
    private var _before: BeforeDot
    /// The completion closure.
    private var _completion: CompletionDot
    /// The error closure.
    private var _error: ErrorDot
    /// The cancel closure.
    private var _cancel: CancelDot
    /// The finally closure.
    private var _finally: FinallyDot

    // MARK: - Option Variables

    /// Bool representing whether finally should be called if task is canceled.
    private var _finallyOnCancel: Bool = true

    // MARK: - Instance Variables
    
    /// Current task
    private var _currentTask: URLSessionDataTask?

    /// The current request
    final public var DotRequest: Request
    
    // MARK: - Initializers

    /**
        Initializes a new `DotTask` with a `DotRequest`.
        
        - Parameter request: An object that conforms to the `DotRequest` protocol.
    */
    public init(request: Request) {
        self.DotRequest = request
    }
        
    // MARK: - Block setters

    /**
        Set the block to be called before starting a task.
        
        - Parameter beforeDot: A block to be called before the task starts.
        - Returns: Self.
    */
    public func before(_ beforeDot: BeforeDot) -> Self {
        self._before = beforeDot
        return self
    }

    /// Set the block to be called on completion of a request
    ///
    /// - Parameter completionDot: A block to be called when the request completes.
    /// - Returns: Self.
    public func onCompletion(_ completionDot: CompletionDot) -> Self {
        self._completion = completionDot
        return self
    }

    /// Set the block to be called if the request errors.
    ///
    /// - Parameter errorDot: A block to be called if the request errors.
    /// - Returns: Self.
    public func onError(_ errorDot: ErrorDot) -> Self {
        self._error = errorDot
        return self
    }
    
    /// Set the block to be called if the request is canceled.
    ///
    /// - Parameter cancelDot: A block to be called if the request is canceled.
    /// - Returns: Self.
    public func onCancel(_ cancelDot: CancelDot) -> Self {
        self._cancel = cancelDot
        return self
    }

    /// Set the block to be called at the end of a request, regardless of success.
    ///
    /// - Parameter finallyDot: A block to be called after the request has finished.
    /// - Returns: Self.
    public func finally(_ finallyDot: FinallyDot) -> Self {
        self._finally = finallyDot
        return self
    }

    // MARK: - Option Setters

    /// Set whether the finally block should be called when a task is cancelled.
    /// **Note:** This defaults to `true`.
    ///
    /// - Parameter shouldCall: Whether it should be called.
    /// - Returns: Self.
    public func shouldCallFinallyOnCancel(_ shouldCall: Bool) -> Self {
        self._finallyOnCancel = shouldCall
        return self
    }

    // MARK: - Task state methods

    /// Start the task.
    /// **Note:** If a task it will be canceled and the cancel block will be called.
    public func start() {
        runTask()
    }

    
    /// Pause the current task. If there is no current task this does nothing.
    public func pause() {
        pauseTask()
    }

    /// Resumes the current task. If there is no current task this does nothing.
    public func resume() {
        resumeTask()
    }

    /// Cancels the current task. If there is no current task this does nothing.
    public func cancel() {
        cancelTask()
    }

    // MARK: - Private task state methods
    
    /// Start a new Task.
    private func runTask() {
        cancelTask()
        
        _before?()

        do {
            let url = try buildURL()
            let request = try buildRequest(withURL: url)

            _currentTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                defer {
                    self._finally?()
                }
                
                guard error.hasValue.not else {
                    self.parseAndSendError(withError: error!, response: response, data: data)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.parseAndSendError(withError: DotTaskError.missingOrBadResponse(response: response), response: nil, data: nil)
                    return
                }

                if let rejectionCodes = self.DotRequest.rejectionCodes {
                    for rejectionRange in rejectionCodes {
                        if rejectionRange.contains(httpResponse.statusCode) {
                            self.parseAndSendError(withError: DotTaskError.rejectedStatusCode(statusCode: httpResponse.statusCode), response: httpResponse, data: data)
                            return
                        }
                    }
                }

                do {
                    try self.parseAndSendCompletion(response: httpResponse, data: data)
                } catch {
                    self.parseAndSendError(withError: error, response: httpResponse, data: data)
                    return
                }
            })

            _currentTask!.resume()
            
        } catch {
            parseAndSendError(withError: error, response: nil, data: nil)
            _finally?()
            return
        }
        
    }

    /// Pause the current task if it exists.
    private func pauseTask() {
        if _currentTask.hasValue {
            _currentTask!.suspend()
        }
    }

    /// Resume the current task if it exists.
    private func resumeTask() {
        if _currentTask.hasValue {
            _currentTask!.resume()
        }
    }

    /// Cancel the current task if it exists.
    /// **Note:** Sets the current task to `nil`.
    private func cancelTask() {
        if _currentTask.hasValue {
            _currentTask?.cancel()
            _currentTask = nil
            self._cancel?()
            if _finallyOnCancel {
                self._finally?()
            }
        }
    }
    
    // MARK: - Helper methods

    private func parseAndSendCompletion(response: URLResponse, data: Data?) throws {
        let parsedValue = try DotRequest.parseValue(response: response, data: data)
        _completion?(parsedValue)
    }
    
    /// Sends the given error to the `DotRequest` implementations `parseError` method, and
    /// then sends this error to the error block. If the error returned from `parseError`
    /// is `nil` then the error sent to the error block will be a `DotTaskError.otherError`
    /// with the given error as it's value.
    ///
    /// - Parameters:
    ///   - error: The error to be parsed.
    ///   - response: The response from the `URLRequest`.
    ///   - data: The data from the `URLRequest`.
    private func parseAndSendError(withError error: Error, response: URLResponse?, data: Data?) {
        let parsedError = self.DotRequest.parseError(error: error, response: response, data: data) ?? DotTaskError.otherError(error)
        _error?(parsedError)
    }
    
    // MARK: - Build items
    
    /// Build the url from the `DotRequest` implementation.
    ///
    /// - Returns: The build `URL`.
    /// - Throws: Error describing why the `URL` couldn't be built.
    private func buildURL() throws -> URL {
        guard var components = URLComponents(string: DotRequest.url) else {
            throw DotTaskError.failedToCreateURL("Request URL is not valid. URL: \(DotRequest.url)")
        }
        
        if let path = DotRequest.path {
            components.path = path
        }
        
        if let queryParams = DotRequest.queryParameters {
            components.queryItems = queryParams.map({ (name, value) -> URLQueryItem in
                URLQueryItem(name: name, value: value)
            })
        }
        
        components = DotRequest.editComponents(components)
        
        guard let url = components.url else {
            throw DotTaskError.failedToCreateURL("The URL couldn't be created from the given components \(components)")
        }
        
        return url
    }
    
    /// Build a `URLRequest` from the given `URL` using the `DotRequest` implementation.
    ///
    /// - Parameter url: The URL to build the request with.
    /// - Returns: The build `URLRequest`.
    /// - Throws: Error describing why the `URLRequest` couldn't be built.
    private func buildRequest(withURL url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = DotRequest.httpMethod
        urlRequest.httpBody = DotRequest.body

        DotRequest.headers?.forEach({ (header, value) in
            urlRequest.addValue(value, forHTTPHeaderField: header)
        })

        if let authDetails = DotRequest.authentication {
            let loginString = "\(authDetails.username):\(authDetails.password)"
            guard let base64String = loginString.data(using: .utf8)?.base64EncodedData() else {
                throw DotTaskError.failedToCreateRequest("couldn't create auth string")
            }
            
            urlRequest.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            
        }
        
        urlRequest = DotRequest.editRequest(urlRequest)
        
        return urlRequest
    }

}
