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

