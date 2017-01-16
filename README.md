# DotDotDot

DotDotDot is a slightly different way to do network requests. Create an type (either a struct or class) that implements the `DotRequest` protocol, and then using the `createTask` method to make a network request. 

Here is an example of the implemented protocol:

``` swift
struct UsersGistsRequest: DotRequest {
    let username: String
    init(username: String) {
        self.username = username
    }

    var url: String { return "https://api.github.com" }

    var path: String? { return "/users/\(username)/gists" }

    var rejectionCodes: [Range<Int>]? { 
    	return [100..<200, 300..<600]
    }

    func parseValue(response: URLResponse, data: Data?) 
		throws -> Int {
        // parse json data here
    }
    
    func parseError(error: Error, response: URLResponse?, 
    	data: Data?) -> Error? {
        // Return view friendly error here
    }
}
```

Once the protocol is made you can make API requests very easily using the `createTask` method. With the task you can use a fluent API to add handlers based on the different outputs of the request. 

The finished product looks like this:

``` swift
let task = UsersGistsRequest(username: "radther").create()
	.before {
		// Code to run before the request starts
	}
	.onCompletion { value in
		// Code to be run when/if the request is successful
	}
	.onError { error in
		// Code to be run if an error occurs
	}
	.onCancel {
		// Code to run if the request cancels
	}
	.finally {
		// Code to run after everything isover
        // This is called regardless of whether the request errors or is canceled
	}
```

## License

This framework is released under MIT license.