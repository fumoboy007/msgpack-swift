# Common Use Cases

## Serialization

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/Serialization")

## Deserialization

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/Deserialization")

## MessagePack Timestamp Extension Type

The ``MessagePackTimestamp`` structure represents the MessagePack timestamp extension type. Prefer to use this type instead of `Date` when preserving precision is important. This type has nanosecond precision and uses integer values instead of floating-point values.

The type conforms to `Codable`, so it can be easily nested within other `Codable` types as expected:

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/MessagePackTimestamp", slice: "codable")

Initialize a timestamp with its component values:

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/MessagePackTimestamp", slice: "init-with-components")

Or, initialize a timestamp from a string that follows the RFC 3339 Internet date/time format:

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/MessagePackTimestamp", slice: "init-with-rfc3339")

Or, initialize a timestamp from a `Date` instance:

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/MessagePackTimestamp", slice: "init-with-date")

Similarly, a `Date` instance can be initialized from a timestamp:

@Snippet(path: "msgpack-swift/Snippets/Common Use Cases/MessagePackTimestamp", slice: "date-from-timestamp")
