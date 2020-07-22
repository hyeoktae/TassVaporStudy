# TassVaporStudy
vapor를 한번 공부해보쟈


Server-side-swift

Route parameters

# 1. 파라미터 받는 방법

app.get("Hello", ":name") { (req) -> String in
    guard let name = try? req.parameters.get("name") else { throw Abort(.badRequest) }
    return "Hello, \(name)"
  }

# 2. json으로 받는방법

app.post("info") { (req) -> String in
    guard let data = try? req.content.decode(InfoData.self) else { throw Abort(.badRequest) }
    return "hello \(data.name)"
  }

struct InfoData: Content {
  let name: String
}

# 3. Json 으로 response 내보내기

app.post("test") { (req) -> InfoResponse in
    return InfoResponse(res: "response!")
  }

struct InfoResponse: Content {
  let res: String
}



# 4. Catchall

app.get("catchall", "**") { (req) -> String in
    let name = req.parameters.getCatchall().joined(separator: " ")
    return "Hello, \(name)"
  }

“**” 이거는 catchall뒤에 따라오는 모든 components를 가져오는것!
Ex) http://127.0.0.1:8080/catchall/test/tass/devy -> Hello, test tass devy


# 5. Body 용량 제한
원래 vapor의 기본 body의 용량은 16kb인데, 
app.routes.defaultMaxBodySize = "500kb"
이걸 통해서 올려줄수있다!
만약 제한을 넘어버리면 413 Payload Too Large 이걸 리턴한다.


# 6. Body 의 data 긁어오기
Async 하게 동작한다.

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


Return 은 eventloopfuture으로 해야하는데, 끝났을때는 끝났다고 명시를 해줘야함. Return 뒤에. 
위에 maxSize 를 1kb 로 했는데, request가 많으면 413 payload too large가 리턴된다. 

