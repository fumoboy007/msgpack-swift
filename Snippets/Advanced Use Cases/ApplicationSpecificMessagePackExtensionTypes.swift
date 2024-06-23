// Implement an application-specific MessagePack extension type by conforming a type to ``CodableAsMessagePackExtension``.

// snippet.hide

import MessagePack

// snippet.show

struct MyExtensionType: CodableAsMessagePackExtension {
   static var extensionTypeID: Int8 {
      // Return some integer in the range `0...127`.
      // snippet.hide
      return 0
      // snippet.show
   }

   // MARK: Serialization

   func validateForEncoding() throws {
      // Throw an error if the value is not able to be encoded.
   }

   var encodedByteCount: UInt32 {
      // Return the number of bytes that `encode(to:)` will write.
      // snippet.hide
      return 0
      // snippet.show
   }

   func encode(to messageWriter: inout MessageWriter) {
      // Encode the value and use `messageWriter` to append the bytes to the message.
   }

   // MARK: Deserialization

   init(decoding bytes: UnsafeRawBufferPointer) throws {
      // Decode the value from the given bytes.
   }
}
