//
// Created by Tom Sinlgeton on 13/01/2017.
// Copyright (c) 2017 Tom Sinlgeton. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Any {
    var hasValue: Bool {
        return self != nil
    }
}
