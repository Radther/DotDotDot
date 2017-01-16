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

The protocol has a few different things you can implement such as `httpMethod`, `body`, and `headers`. It also supports basic auth by implementing `authentication`. If the thing you want to implement isn't provided then there are two functions you can use. The first is `editComponents` where you are given the current `URLComponents` before the request is built and can return updated components. The second is `editRequest` where you are given the current `URLRequest` object that you can change and return an updated version of.

## License

This framework is released under MIT license.