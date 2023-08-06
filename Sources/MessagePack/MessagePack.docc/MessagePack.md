# ``MessagePack``

Serialize `Codable` values to MessagePack bytes and deserialize `Codable` values from MessagePack bytes.

## Overview

Use ``MessagePackEncoder`` to serialize `Codable` values to MessagePack bytes. Use ``MessagePackDecoder`` to deserialize `Codable` values from MessagePack bytes.

```swift
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
   myTimestamp: MessagePackTimestamp(secondsComponent: 1694398799,
                                     nanosecondsComponent: 123)
)

let encoder = MessagePackEncoder()
let myMessageBytes = try encoder.encode(myMessage)

let decoder = MessagePackDecoder()
let myMessageDecoded = try decoder.decode(MyMessage.self, from: myMessageBytes)
```

## Topics

### Serialization

- ``MessagePackEncoder``
- ``MessagePackDecoder``

### Predefined MessagePack Extension Types

- ``MessagePackTimestamp``

### Implementing Application-Specific MessagePack Extension Types

- ``CodableAsMessagePackExtension``
- ``EncodableAsMessagePackExtension``
- ``DecodableAsMessagePackExtension``
- ``MessageWriter``
