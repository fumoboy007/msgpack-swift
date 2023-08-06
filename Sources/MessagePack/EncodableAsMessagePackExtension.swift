// MIT License
//
// Copyright © 2023 Darren Mo.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// Conform a type to this protocol to enable ``MessagePackEncoder`` to serialize values of the type
/// as a MessagePack extension.
public protocol EncodableAsMessagePackExtension {
   /// The extension type ID.
   ///
   /// Application-specific extensions may use type IDs from `0` to `127`.
   static var extensionTypeID: Int8 { get }

   /// Validates that the value is able to be encoded.
   func validateForEncoding() throws

   /// The number of bytes that ``encode(to:)`` will write.
   var encodedByteCount: UInt32 { get }

   /// Encodes the value as a MessagePack extension payload.
   ///
   /// - Postcondition: The number of bytes that this method writes must be the same as ``encodedByteCount``.
   func encode(to messageWriter: inout MessageWriter)
}
