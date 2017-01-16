//
//  GistPageRequest.swift
//  FireNetwork
//
//  Created by Tom Singleton on 12/01/2017.
//  Copyright © 2017 Tom Singleton. All rights reserved.
//

import Foundation
import DotDotDot

struct GistPageRequest: DotRequest {
    
    var url: String {
        return "https://api.github.com"
    }

    var path: String? {
        return "/gists/public"
    }

    private enum GistPageInternalError: Error {
        case parseError
    }

    enum GistPageError: Error {
        case failedRequest
    }
    
    func parseValue(response: URLResponse, data: Data?) throws -> Int {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data),
              let gists = json as? [[String:Any]] else {
            throw GistPageInternalError.parseError
        }

        return gists.count
    }
    
    func parseError(error: Error, response: URLResponse?, data: Data?) -> Error? {
        switch error {
        case GistPageInternalError.parseError:
            return GistPageError.failedRequest
        default:
            return nil
        }
    }
}
