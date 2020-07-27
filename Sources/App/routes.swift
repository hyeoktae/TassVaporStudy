import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req in
    return "아 드디어 된다앙"
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  app.get("devy") { req -> String in
    return "안눙 뎁데비데"
  }
  
  app.get("coffee") { req -> String in
    return "뎁데비서 커피좀 부 탁 해 요 ㅋㅋㅋ"
  }
  
  try app.register(collection: TodoController())
}
