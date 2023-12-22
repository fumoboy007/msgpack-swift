# ``MessagePack``

Serialize `Codable` values to MessagePack bytes and deserialize `Codable` values from MessagePack bytes.

## Overview

Use ``MessagePackEncoder`` to serialize `Codable` values to MessagePack bytes. Use ``MessagePackDecoder`` to deserialize `Codable` values from MessagePack bytes.

@Snippet(path: "msgpack-swift/Snippets/Overview")

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
