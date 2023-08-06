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

import Foundation
import MessagePack

struct ApplicationSpecificExtensionFake {
   let data: Data

   init(data: Data) {
      self.data = data
   }
}

extension ApplicationSpecificExtensionFake: CodableAsMessagePackExtension {
   static let extensionTypeID: Int8 = .max

   init(decoding bytes: UnsafeRawBufferPointer) throws {
      self.data = bytes.withMemoryRebound(to: UInt8.self) {
         return Data(buffer: $0)
      }

      try validateForEncoding()
   }

   enum ValidationError: Error {
      case dataTooLong(Int)
   }

   func validateForEncoding() throws {
      let byteCount = data.count
      guard UInt32(exactly: byteCount) != nil else {
         throw ValidationError.dataTooLong(byteCount)
      }
   }

   var encodedByteCount: UInt32 {
      return UInt32(data.count)
   }

   func encode(to messageWriter: inout MessagePack.MessageWriter) {
      data.withUnsafeBytes {
         messageWriter.write($0)
      }
   }
}

extension ApplicationSpecificExtensionFake: Codable {
}

extension ApplicationSpecificExtensionFake: Equatable {
}
