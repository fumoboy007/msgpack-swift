// Use ``MessagePackDecoder`` to deserialize `Codable` values from MessagePack bytes.

// snippet.hide

import Foundation
import MessagePack

struct MyMessage: Decodable {
}

let mySerializedMessage = Data()

// snippet.show

let decoder = MessagePackDecoder()
let message = try decoder.decode(MyMessage.self, from: mySerializedMessage)
