// snippet.hide

import Foundation

// snippet.show

import MessagePack

struct MyMessage: Codable {
   let myBool: Bool
   let myOptionalDecimal: Decimal?
   let myStringArray: [String]
   let myTimestamp: MessagePackTimestamp
}
let myMessage = MyMessage(
   myBool: true,
   myOptionalDecimal: nil,
   myStringArray: ["hello", "world"],
   myTimestamp: MessagePackTimestamp(internetDateTime: "2023-09-10T19:19:59.123456789-07:00")!
)

let encoder = MessagePackEncoder()
let myMessageBytes = try encoder.encode(myMessage)

let decoder = MessagePackDecoder()
let myMessageDecoded = try decoder.decode(MyMessage.self, from: myMessageBytes)

// snippet.hide

print(myMessageDecoded)
