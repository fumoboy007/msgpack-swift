// Use ``MessagePackEncoder`` to serialize `Codable` values to MessagePack bytes.

// snippet.hide

import MessagePack

struct MyMessage: Encodable {
}

let myMessage = MyMessage()

// snippet.show

let encoder = MessagePackEncoder()
let serializedMessage = try encoder.encode(myMessage)
