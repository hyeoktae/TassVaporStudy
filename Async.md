 # Async

`EventLoopFuture`  읽기 전용  / 참조값이 아직 사용 못할수도 있음

`EventLoopPromise` 읽기, 쓰기 / 어떤 값을 비동기적으로 처리한다는 약속? 

 ## Transforming 
 
method | argument | description
---|:---:|---
`map` | `(T) -> U` | Maps a future value to a different value.
`flatMapThrowing | `(T) throws -> U` | Maps a future value to a different value or an error.
`flatMap` | `(T) -> EventLoopFuture<U>` | Maps a future value to different future value.
`transform` | `U` | Maps a future to an already available value.



### map

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

/// Map the future string to an integer
let futureInt = futureString.map { string in
    print(string) // The actual String
    return Int(string) ?? 0
}

/// We now have a future integer
print(futureInt) // EventLoopFuture<Int>
```


### flatMapThrowing

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

/// Map the future string to an integer
let futureInt = futureString.flatMapThrowing { string in
    print(string) // The actual String
    // Convert the string to an integer or throw an error
    guard let int = Int(string) else {
        throw Abort(...)
    }
    return int
}

/// We now have a future integer
print(futureInt) // EventLoopFuture<Int>
```


### flatMap

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

/// Assume we have created an HTTP client
let client: Client = ... 

/// flatMap the future string to a future response
let futureResponse = futureString.flatMap { string in
    client.get(string) // EventLoopFuture<ClientResponse>
}

/// We now have a future response
print(futureResponse) // EventLoopFuture<ClientResponse>
```

```swift
/// Assume future string and client from previous example.
let futureResponse = futureString.flatMap { string in
    let url: URL
    do {
        // Some synchronous throwing method.
        url = try convertToURL(string)
    } catch {
        // Use event loop to make pre-completed future.
        return eventLoop.makeFailedFuture(error)
    }
    return client.get(url) // EventLoopFuture<ClientResponse>
}
```


### transform

```swift
/// Assume we get a void future back from some API
let userDidSave: EventLoopFuture<Void> = ...

/// Transform the void future to an HTTP status
let futureStatus = userDidSave.transform(to: HTTPStatus.ok)
print(futureStatus) // EventLoopFuture<HTTPStatus>
```

### Chaining

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

/// Assume we have created an HTTP client
let client: Client = ... 

/// Transform the string to a url, then to a response
let futureResponse = futureString.flatMapThrowing { string in
    guard let url = URL(string: string) else {
        throw Abort(.badRequest, reason: "Invalid URL string: \(string)")
    }
    return url
}.flatMap { url in
    client.get(url)
}

print(futureResponse) // EventLoopFuture<ClientResponse>
```


## Future


### makeFuture

```swift
// Create a pre-succeeded future.
let futureString: EventLoopFuture<String> = eventLoop.makeSucceededFuture("hello")

// Create a pre-failed future.
let futureString: EventLoopFuture<String> = eventLoop.makeFailedFuture(error)
```

pre-completed future


### whenComplete

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

futureString.whenComplete { result in
    switch result {
    case .success(let string):
        print(string) // The actual String
    case .failure(let error):
        print(error) // A Swift Error
    }
}
```


complete되면 뭐할래? 
많은 callback들을 추가할수 있다. 


### Wait

```swift
/// Assume we get a future string back from some API
let futureString: EventLoopFuture<String> = ...

/// Block until the string is ready
let string = try futureString.wait()
print(string) /// String
```
* wait 는 콜백을 동기화처리한다. 비동기아님! 
* wait 는 background or main thread 에서 실행해야한다. 
* wait를 event loop 에서 호출하면 assertion 오류 난다


### Promise

```swift
let eventLoop: EventLoop 

// Create a new promise for some string.
let promiseString = eventLoop.makePromise(of: String.self)
print(promiseString) // EventLoopPromise<String>
print(promiseString.futureResult) // EventLoopFuture<String>

// Completes the associated future.
promiseString.succeed("Hello")

// Fails the associated future.
promiseString.fail(...)
```

promise는 결과타입? ex..String, Int...를 미리 정해두는거 같음
한번만 successd할수있다. 나중에 들어오는 완료는 무시한다.



