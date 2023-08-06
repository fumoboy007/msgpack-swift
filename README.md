# msgpack-swift

An efficient, full-featured, and compliant [MessagePack](https://msgpack.org) implementation for Swift.

![Swift 5.8](https://img.shields.io/badge/swift-v5.8-%23F05138)
![Linux, macOS 13, iOS 16, tvOS 16, watchOS 9](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%2013%20%7C%20iOS%2016%20%7C%20tvOS%2016%20%7C%20watchOS%209-blue)
![MIT License](https://img.shields.io/github/license/fumoboy007/msgpack-swift)
![Automated Tests Workflow Status](https://img.shields.io/github/actions/workflow/status/fumoboy007/msgpack-swift/tests.yml?event=push&label=tests)

## Features

- Full integration with Swift’s `Codable` serialization system.
- Support for standard `Foundation` value types such as `Date`, `URL`, `Data`, and `Decimal`.
- Support for MessagePack extension types like timestamp and application-specific extension types.
- Automated tests verify compliance with the MessagePack [specification](https://github.com/msgpack/msgpack/blob/8aa09e2a6a9180a49fc62ecfefe149f063cc5e4b/spec.md) by testing against the `msgpack-c` [reference implementation](https://github.com/fumoboy007/MessagePackReferenceImplementation).
- Highly optimized for performance.

## Compared to the Competition

(As of September 2023.)

### Functionality

| Other Library | Remarks |
| --- | --- |
| [`nnabeyang/swift-msgpack`](https://github.com/nnabeyang/swift-msgpack) | ⚠️ No tailored support for `Date`, `URL`, or `Decimal`. |
| [`hirotakan/MessagePacker`](https://github.com/hirotakan/MessagePacker) | ⚠️ [Does not support](https://github.com/hirotakan/MessagePacker/pull/54) complex nested container setups.<br />⚠️ [Missing](https://github.com/hirotakan/MessagePacker/pull/57) some validation logic.<br />⚠️ No tailored support for `Decimal`. |
| [`Flight-School/MessagePack`](https://github.com/Flight-School/MessagePack) | ⚠️ Does not support complex nested container setups.<br />⚠️ Does not have a timestamp type to preserve precision.<br />⚠️ No tailored support for `URL` or `Decimal`.<br />⚠️ Does not support application-specific MessagePack extension types. |
| [`swiftstack/messagepack`](https://github.com/swiftstack/messagepack) | ❌ Timestamp type is not `Codable`. |
| [`malcommac/SwiftMsgPack`](https://github.com/malcommac/SwiftMsgPack) | ❌ Does not support `Codable`. |
| [`a2/MessagePack.swift`](https://github.com/a2/MessagePack.swift) | ❌ Does not support `Codable`. |
| [`michael-yuji/YSMessagePack`](https://github.com/michael-yuji/YSMessagePack) | ❌ Does not support `Codable`. |
| [`briandw/SwiftPack`](https://github.com/briandw/SwiftPack) | ❌ Does not have a Swift package manifest. |

### Performance

| Other Library | Compared to This Library |
| --- | --- |
| [`nnabeyang/swift-msgpack`](https://github.com/nnabeyang/swift-msgpack) | Up to 3× slower. |
| [`hirotakan/MessagePacker`](https://github.com/hirotakan/MessagePacker) | Up to 2× slower. |
| [`Flight-School/MessagePack`](https://github.com/Flight-School/MessagePack) | Up to 6× slower. |

Tested using real-world messages that are involved in high throughput or low latency use cases. Pull requests to [`Benchmarks.swift`](Tests/Benchmarks/Benchmarks.swift) are welcome if you know of similar use cases!

## Usage

Below is a basic example. See the [documentation](https://fumoboy007.github.io/msgpack-swift/documentation/messagepack/) for more details.

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
