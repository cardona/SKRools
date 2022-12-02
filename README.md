# SKRools

A toolbox for Swift iOS projects.

Here you can find:
* AntiDebbuger
* Networking 
* Binding
* Logger
* Cryptology
* more things


## AntiDebugging / AntiJailbreak
Try to detect debug mode
Incorporates a lot of techniques to try to determine if an app is running on a jailbreak device or is being debugged.

```swift
import SKRools

if AntiJailbreak.shared.isJailbreakActiveOnDevice() { exit(-1) }
if AntiJailbreak.shared.isJailbreakActive() { exit(-1) }
```

## Binding (Boxing)
A nice binding implementation for the view

Boxing allows you to easily add a weak connection between the view model and the view, using this type of connection makes it very easy to test your code.

In the viewModel we define the Box type properties and in the view we observe any change in its state.


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


## Crypto (Only works on device)
SKCrypto implements everything needed to work with the secure enclave.

The Secure Enclave is a dedicated secure subsystem integrated into Apple systems on chip (SoCs). The Secure Enclave is isolated from the main processor to provide an extra layer of security and is designed to keep sensitive user data secure even when the Application Processor kernel becomes compromised.

More info [here](https://support.apple.com/en-gb/guide/security/sec59b0b31ff/web).

```swift
import SKRools

private let crypto: SKCrypto = DefaultSKCrypto()

// Encrypt
let encrypted = try crypto?.encrypt(text: text, key: key)

// Decrypt
let text = try? crypto?.decrypt(data: data, key: key) as? String
```


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



## Networking
Everything you need to work with REST API.   
Simple, practical and easy to test.    

```swift
import SKRools

func request(parameters: CoinsListRepositoryParameters, completion: @escaping (Result<CoinsListDecodable, DataTransferError>) -> Void) -> Cancellable? {
    let url = DefaultCoinsListRepository.url()
    url.method = .get

    url.headerParamaters = ["authorization": "Apikey \(parameters.apiKey)"]

    if let summary = parameters.summary {
        url.queryParameters = ["summary": summary ? "true" : "false"]
    }

    let networkTask = self.dataTransferService.request(with: url, completion: completion)

    return RepositoryTask(networkTask: networkTask)
}
```


## Logger

Log in your app with groups, icons and severity.   
Disable or enable any log group when you want.


```swift
import SKRools

SKLogger.shared.log(msg: "Secure Enclave is available ", group: .secureEnclave, severity: .info)
```


### Example projects

#### Cryptocompare 
A clean architecture MVVM implementation using the SKRools package
It uses the cryptocompare.com api to download the list of coins without a price, more than 8,000, and through another endpoint it sets the price for the coins.
Use CoreData as cache
[Code here] (https://github.com/cardona/Cryptocompare)

#### MVVM 
Another clean architecture MVVM implementation using the SKRools package
Use marvel.com api to download marvel character list
[Code here] (https://github.com/cardona/MVVM)
