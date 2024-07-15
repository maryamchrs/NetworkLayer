## Network layer 

# Overview

Welcome to the Network Layer project! This library is designed to offer robust and efficient network communication functionalities. 
It integrates modern concurrency features and utilizes the Combine framework to meet diverse user needs. Additionally, the framework includes built-in capabilities for checking network reachability, ensuring reliable connectivity for your applications.

# Features

Modern Concurrency: Leverage the power of modern concurrency tools to achieve efficient and scalable network operations.
Combine Framework Integration: Seamlessly incorporate Combine framework for reactive programming, providing a smooth and flexible user experience.
Network Reachability: Built-in support to monitor and check network reachability, allowing your applications to handle connectivity changes gracefully.

# Usage
You should follow these steps: 
- First Step:
  Import NetworkLayer wherever you want to create your NetworkManager.

- Second step:
  Create your own Endpoint that conforms to `Endpoint`, like this:
  
  ``` Swift
  enum ArtworkEndpoint {
    case getArtWork(number: Int)
  }

  extension ArtworkEndpoint: EndPoint {
    var path: String {
        switch self {
        case .getArtWork(let number):
            return "/" + String(number)
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var httpHeaders: [String: String]? {
        return nil
    }
    
    var httpBody: Encodable? {
        return nil
    }
  }
  ```
  
- Third step:
Initialize your NetworkManager.

- Fourth Step:
Choose between these options to use in your project.
``` Swift
    func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response
    func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error>
```
 If you choose the first option, follow this example:
``` Swift
  do {
     guard let network,
     let urlRequest = ArtworkEndpoint.getArtWork(number: 1).urlRequest else { return }
                
     let result: ArtDataModel = try await network.request(urlRequest)
        print(result)
     } catch {
        print(error)
     }
```
otherwise follow this one: 
``` Swift
guard let network,
      let urlRequest = ArtworkEndpoint.getArtWork(number: 1).urlRequest else { return }
 network.request(urlRequest)
.sink(receiveCompletion: { completion in
    switch completion {
       case .finished:
           print("Request completed successfully.")
       case .failure(let error):
           print("Request failed with error: \(error)")
 }
 }, receiveValue: { (response: ArtDataModel) in
           print("Received response: \(response)")
 }).store(in: &cancellable)
```

# Contributing

Contributions from the community are welcomed. If any suggestions, bug reports, or feature requests are identified, an issue can be opened or a pull request submitted.

# Acknowledgements

In the creation of this framework, the following links were utilized:

[How to create a Generic Networking Layer in iOS apps by Essential Developer](https://www.youtube.com/watch?v=Eo3WkbUV-fU&t=3403s)

[Networking by Paul Hadson]

# License

This project is licensed under the MIT License.
