//
//  UsersGistsRequest.swift
//  FireNetwork
//
//  Created by Tom Singleton on 13/01/2017.
//  Copyright © 2017 Tom Singleton. All rights reserved.
//

import Foundation
import DotDotDot

struct UsersGistsRequest: DotRequest {

    let username: String

    init(username: String) {
        self.username = username
    }

    var url: String {
        return "https://api.github.com"
    }

    var path: String? {
        return "/users/\(username)/gists"
    }

    var rejectionCodes: [Range<Int>]? {
        return [100..<200, 300..<600]
    }

    private enum UserGistsInternalError: Error {
        case parseError
    }

    enum UserGistsError: Error {
        case failedRequest
    }

    func parseValue(response: URLResponse, data: Data?) throws -> Int {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data),
              let gists = json as? [[String:Any]] else {
            throw UserGistsInternalError.parseError
        }

        return gists.count
    }
    
    func parseError(error: Error, response: URLResponse?, data: Data?) -> Error? {
        switch error {
        case UserGistsInternalError.parseError:
            return UserGistsError.failedRequest
        default:
            return nil
        }
    }
    
}
