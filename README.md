# TassVaporStudy
vapor를 한번 공부해보쟈


Server-side-swift

Route parameters

# 1. 파라미터 받는 방법
```
app.get("Hello", ":name") { (req) -> String in
    guard let name = try? req.parameters.get("name") else { throw Abort(.badRequest) }
    return "Hello, \(name)"
  }
```
# 2. json으로 받는방법
```
app.post("info") { (req) -> String in
    guard let data = try? req.content.decode(InfoData.self) else { throw Abort(.badRequest) }
    return "hello \(data.name)"
  }

struct InfoData: Content {
  let name: String
}
```
# 3. Json 으로 response 내보내기
```
app.post("test") { (req) -> InfoResponse in
    return InfoResponse(res: "response!")
  }

struct InfoResponse: Content {
  let res: String
}
```


# 4. Catchall
```
app.get("catchall", "**") { (req) -> String in
    let name = req.parameters.getCatchall().joined(separator: " ")
    return "Hello, \(name)"
  }
```
“**” 이거는 catchall뒤에 따라오는 모든 components를 가져오는것!
Ex) http://127.0.0.1:8080/catchall/test/tass/devy -> Hello, test tass devy

"*" 이건 아무거나 다 받아드린다는것
```
app.get("test", "*", "test2) { req -> String in 
    ...
}
```
.../test/aaa/test2 -> test, aaa, test2
.../test/bbb/test2 -> test, bbb, test2

HTTP method 
get, post, patch, put, delete
```
app.on(.OPTION, "test", "test2") { req -> String in 
    ...
}
```

# 5. Body 용량 제한
원래 vapor의 기본 body의 용량은 16kb인데, 
app.routes.defaultMaxBodySize = "500kb"
이걸 통해서 올려줄수있다!
만약 제한을 넘어버리면 413 Payload Too Large 이걸 리턴한다.


# 6. Body 의 data 긁어오기
Async 하게 동작한다.
```
app.on(.POST, "listings", body: .collect(maxSize: "1kb")) { (req) -> EventLoopFuture<String> in
    return req.body.collect().flatMap { (buffer) -> EventLoopFuture<String> in
      guard let buf = buffer else { return req.eventLoop.makeFailedFuture(ErrorType.noData) }
      guard let temp = try? JSONDecoder().decode(InfoResponse.self, from: buf) else { return req.eventLoop.makeFailedFuture(ErrorType.noData) }
      return req.eventLoop.makeSucceededFuture(temp.res)
    }
  }


app.on(.POST, "listings", body: .collect(maxSize: "100mb")) { (req) -> EventLoopFuture<String> in
    return req.body.collect().flatMap { (buffer) -> EventLoopFuture<String> in
      guard var buf = buffer else { return req.eventLoop.makeFailedFuture(ErrorType.noData) }
      guard let data = buf.readData(length: buf.capacity) else { return req.eventLoop.makeFailedFuture(ErrorType.noData) }
      return req.eventLoop.makeSucceededFuture("\(data.base32EncodedString())")
    }
  }
```

Return 은 eventloopfuture으로 해야하는데, 끝났을때는 끝났다고 명시를 해줘야함. Return 뒤에. 
위에 maxSize 를 1kb 로 했는데, request가 많으면 413 payload too large가 리턴된다. 
```
app.on(.POST, "upload", body: .stream) { req in
    ...
}
```
이런식으로 .stream을 하는경우도 있는데, 이러면 req.body.data 는 nil이다. 꼭!!! req.body.drain을 써야 한다. 


# 8. 모든 route확인하기?
```
func routes(_ app: Application) throws {
    ...
    print(app.routes.all)
    }
```
결과 -> [GET /, GET /hello, GET /Hello/:name, POST /info, POST /test, GET /catchall/**, POST /listings]


# 9. Apple Airport MDNS

[duiadns](https://www.duiadns.net)

여기에서 airport DNS를 할수있다. 설정방법은 잘 나와 있음!!! 따라하면 됨 ㅋㅋ


# 10. apple airport port 설정

Airport - 편집 - 네트워크 - 포트설정 - + 하고

![포트설정](https://user-images.githubusercontent.com/48010847/88486247-66ddd400-cfb7-11ea-87e8-0f3f0b647ddc.png)

설명에는 아무거나 넣고,
공용 TCP에 포트번호(보통은 8080), 개인 TCP에도 포트번호 넣어준다. 그리고 저장!
이걸 해야만 test.test:8080 에 접근 가능하다. :xxxx 는 입력한 포트번호!


# 11. HTTPS
이건 도통 방법을 모르겠다.. 알려주세요ㅜㅜ


# 12. redirect

```
app.get("redirect2") { (req) -> String in
    req.client.get(URI(string: "http://devy.tass.duia.us:1218/coffee"))
    return ""
  }
```
이런식으로 하는거 같다. 빌드하고 실험해봐야겠다.
