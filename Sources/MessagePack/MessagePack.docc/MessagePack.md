# ``MessagePack``

An efficient, full-featured, and compliant MessagePack implementation.

## Overview

### Designed for Swift

- Full integration with the `Codable` serialization system.
- Support for standard `Foundation` value types such as `Date`, `URL`, `Data`, and `Decimal`.
- Highly optimized for performance.

### Fully Compliant with the MessagePack Specification

- Support for MessagePack extension types like timestamp and application-specific extension types.
- Automated tests verify compliance with the MessagePack [specification](https://github.com/msgpack/msgpack/blob/8aa09e2a6a9180a49fc62ecfefe149f063cc5e4b/spec.md) by testing against the `msgpack-c` [reference implementation](https://github.com/fumoboy007/MessagePackReferenceImplementation).

## Topics

### Examples

- <doc:Common-Use-Cases>
- <doc:Advanced-Use-Cases>

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
