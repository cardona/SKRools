# SKRools

A toolbox for Swift iOS projects.

Here you can find:
* AntiDebbuger
* Networking 
* Binding
* Logger
* Cryptology
* more things


## Binding (Boxing)
`Box` is a generic class that enables the binding of a value and allows listeners to react to changes in this value.
It's typically used in MVVM architectural patterns to synchronize views with view models.
### Usage:
1. Initialize `Box` with an initial value.
2. Bind a listener to react to changes in the value.
3. Update the `value` as needed. The listener will be notified of these changes.
### Example:
```swift
var myValue: Box<Int> = Box(0)
myValue.bind { newValue in
    print("Value changed to \(newValue)")
}
myValue.value = 10 // Prints: Value changed to 10
```

ViewModel   
```swift
import SKRools

var itemsListModel: Box<CoinsListModel?> = Box(nil)

func coinsList() {
    itemsListModel.value = model
}
```

View   
```swift
import SKRools

viewModel.itemsListModel.bind { [weak self] model in
    guard let model = model else { return }
    DispatchQueue.main.async {
      // Do something 
    }
}
```


## Crypto (Only works on device)
SKCrypto implements everything needed to work with the secure enclave.

The Secure Enclave is a dedicated secure subsystem integrated into Apple systems on chip (SoCs). The Secure Enclave is isolated from the main processor to provide an extra layer of security and is designed to keep sensitive user data secure even when the Application Processor kernel becomes compromised.

More info [here](https://support.apple.com/en-gb/guide/security/sec59b0b31ff/web).

`DefaultSKCrypto` is a class that implements the `SKCrypto` protocol, providing encryption and decryption functionalities using the Secure Enclave on compatible Apple devices. It leverages the Secure Enclave to generate and store a private key securely. This key is then used to create a symmetric key for encryption and decryption processes.

### Usage

To use `DefaultSKCrypto`, follow these steps:

1. **Create an instance of `DefaultSKCrypto`.**
   - Instantiate `DefaultSKCrypto` to begin using its functionalities.

2. **Generate a Private Key:**
   - Use the `createPrivateKey()` method to generate a new private key in the Secure Enclave.

3. **Retrieve Symmetric Key:**
   - Call `symmetricKey()` to get the symmetric key derived from the private key.

4. **Encrypt or Decrypt Data:**
   - Encrypt data with `encrypt(text:key:)` and decrypt using `decrypt(data:key:)`.

### Note

- **Secure Enclave Availability:**
  - `DefaultSKCrypto` checks if the Secure Enclave is available on the device. If it's not available, the class falls back to using a hardcoded key.

- **Simulator Check:**
  - The class includes a check to determine if it is running on a simulator, where the Secure Enclave is not available. This is important for ensuring compatibility and correct functionality across different execution environments.


```swift
import SKRools

private let crypto: SKCrypto = DefaultSKCrypto()

// Encrypt
let encrypted = try crypto?.encrypt(text: text, key: key)

// Decrypt
let text = try? crypto?.decrypt(data: data, key: key) as? String
```



## Networking
SKRools offers a comprehensive networking module designed to simplify interactions with APIs in your Swift projects. This module encompasses everything needed for making HTTP requests, handling responses, and managing data transfer efficiently.

### Key Features
- HTTP Method Support: Easily perform GET, POST, PUT, DELETE, and other HTTP methods.
- Request and Response Handling: Utilize the Endpoint and Requestable protocols to define custom request/response patterns.
- Error Handling: Robust error handling for various network and data transfer scenarios.
- Local and Remote Data Fetching: Support for both local (offline) and remote (online) data fetching.
- Response Decoding: JSON and PLIST decoding capabilities for handling different response formats.

### Getting Started
To use the networking functionalities of SKRools, ensure your Swift project is set up with the necessary configurations and dependencies.

### Making Network Requests
You can make network requests by creating instances of repositories that conform to specific protocols for data fetching. For instance, using DefaultLocalitiesListRepository:
```swift
let repository = LocalitiesListRepository()
repository.localitiesList { result in
    switch result {
    case .success(let localities):
        // Handle successful response
    case .failure(let error):
        // Handle error scenario
    }
}
```

### Custom Endpoint Creation
Define custom endpoints by conforming to the ResponseRequestable protocol. This allows for greater flexibility and control over the request and response format.

```swift
struct MyEndpoint: ResponseRequestable {
    typealias Response = MyDecodableModel
    // Define other required properties and methods as per your API's specification
}
```

### Network Configuration
Configure your network settings using ApiDataNetworkConfig or similar structures to specify base URL, headers, and query parameters.

```swift
let networkConfig = ApiDataNetworkConfig(
    baseURL: "https://api.example.com",
    headers: ["Authorization": "Bearer your-api-token"],
    queryParameters: ["param": "value"]
)
```
### Error Handling
SKRools networking module provides a comprehensive error handling mechanism, enabling you to gracefully handle different error types, such as connectivity issues, data transfer errors, and response parsing failures.

### Usage
```swift
import Foundation
import SKRools

// Defines a protocol for a repository responsible for fetching a list of localities.
protocol LocalitiesListRepository {
    // Function declaration that fetches the localities list. The function returns a Cancellable object to optionally cancel the request.
    // The completion handler is a closure that takes a Result type, which can be either a success with an array of LocalityDecodable or a failure with DataTransferError.
    @discardableResult
    func localitiesList(completion: @escaping (Result<[LocalityDecodable], DataTransferError>) -> Void) -> Cancellable?
}

// Concrete implementation of the LocalitiesListRepository protocol.
final class DefaultLocalitiesListRepository: LocalitiesListRepository {
    
    // A private property to hold the DataTransferService instance.
    private let dataTransferService: DataTransferService
    
    // Initializer for the repository. It takes a DataTransferService object as a parameter with a default value of DefaultDataTransferService.
    // This design allows for dependency injection, making it easier to test by injecting mock services.
    init(dataTransferService: DataTransferService = DefaultDataTransferService()) {
        self.dataTransferService = dataTransferService
    }
    
    // Static function to create an Endpoint object specific to fetching localities list. This function constructs the endpoint URL using the current language setting.
    static func localitiesListEndpoint() -> Endpoint<[LocalityDecodable]> {
        let language = ApplicationManager.sharedInstance.currentLanguage()
        return Endpoint(path: "/en/rest/\(language)/towns")
    }
    
    // Function to fetch the localities list. It constructs the endpoint, sets the HTTP method and query parameters, then makes a network request.
    // The completion handler is called with the result of the network request.
    // The function returns a Cancellable object, which can be used to cancel the network request if needed.
    func localitiesList(completion: @escaping (Result<[LocalityDecodable], DataTransferError>) -> Void) -> Cancellable? {
        let url = DefaultLocalitiesListRepository.localitiesListEndpoint()
        url.method = .get
        url.queryParameters = [ "_format" : "json" ]
        
        // Performs the network request using the dataTransferService and passes the completion handler.
        let networkTask = self.dataTransferService.request(with: url, completion: completion)
        
        // Wraps the returned network task in a RepositoryTask to adhere to the Cancellable protocol.
        return RepositoryTask(networkTask: networkTask)
    }
}
```
```swift
// Final class representing a use case for fetching a list of localities.
final class LocalitiesListUseCase {
    // A private property to hold the LocalitiesListRepository instance.
    private let repository: LocalitiesListRepository
    
    // Initializer for the use case. It accepts a LocalitiesListRepository object as a parameter with a default value of DefaultLocalitiesListRepository.
    // This allows for dependency injection, enabling easier testing and flexibility in providing different repository implementations.
    init(repository: LocalitiesListRepository = DefaultLocalitiesListRepository()) {
        self.repository = repository
    }
    
    // Function to execute the use case. It fetches the list of localities from the repository and handles the response.
    // The completion handler is a closure that takes a Result type, which can be either a success with an array of LocalityEntity or a failure with an Error.
    func execute(completion: @escaping (Result<[LocalityEntity], Error>) -> Void) {
        repository.localitiesList(completion: { [weak self] result in
            switch result {
            case .failure(let error):
                // In case of failure, the completion handler is called with the error.
                completion(.failure(error))

            case .success(let decodable):
                // TODO: Implement success handling logic. For example, transforming the `decodable` to `LocalityEntity` and then calling the completion handler.
                // Example:
                // let entities = decodable.map { LocalityEntity(decodable: $0) }
                // completion(.success(entities))
                break
            }
        })
    }
}
```

## Logger

A logging utility for Swift applications, SKLogger offers a centralized and configurable logging system. It enables developers to log messages, errors, and HTTP traffic with enhanced formatting, categorization, and severity levels. Ideal for both development and debugging, SKLogger assists in efficiently analyzing and tracking application behavior.

### Usage
```swift
Copy code
// Access the shared instance
SKLogger.shared
// Set custom log output (if needed)
logger.logOutput = CustomLogOutput()
// Log messages, errors, and HTTP requests/responses with appropriate group and severity
```

### Example
```swift
Copy code
SKLogger.shared.log(msg: "User logged in", group: .system, severity: .info)
```

# SKRoolsConfig

`SKRoolsConfig` is a singleton class designed to manage and provide centralized access to application-wide configurations. It offers separate modules for network and logger configurations. Use the shared instance to configure and retrieve settings throughout the application.

## Usage

To configure and use `SKRoolsConfig`, access its shared instance and set the necessary properties. For example:

```swift
AppConfiguration.shared.networkBaseURL = "https://api.example.com"
AppConfiguration.shared.loggerDebugGroups = [.networking, .secureEnclave, .system, ...]
```
This allows you to define settings like the base URL for network requests and the debug groups for logging, ensuring that these configurations are consistent and easily accessible across the entire application.

## Keychain
Store and load data from keychain more easy.   


```swift
import SKRools

private let keychain: SKKeychain = DefaultSKKeychain()


// Save Data
try keychain?.save(data, forKey: "yourKey")

// Load Data
try keychain?.loadData(withKey: "yourKey")
```

## Coordinator
The definition of a basic coordinator protocol    
Allows the management of the navigation of the views


```swift
import SKRools

final class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var imagesCache = NSCache<NSString, NSData>()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
}
```

## AntiDebugging / AntiJailbreak
Try to detect debug mode
Incorporates a lot of techniques to try to determine if an app is running on a jailbreak device or is being debugged.

```swift
import SKRools

if AntiJailbreak.shared.isJailbreakActiveOnDevice() { exit(-1) }
if AntiJailbreak.shared.isJailbreakActive() { exit(-1) }
```
