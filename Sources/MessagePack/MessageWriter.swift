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

public struct MessageWriter: ~Copyable {
   // TODO: Manually manage an unsafe mutable buffer pointer instead of using `Data`
   // after Swift 5.8 support is dropped. `Data` is slow to append single bytes
   // because it always calls `memmove` rather than just storing the byte.
   //
   // We need to wait until Swift 5.8 support is dropped because we need the
   // noncopyable struct feature. A class is another alternative but it is slow
   // because it needs to perform runtime checks to enforce exclusivity.
   private(set) var message = Data()

   public mutating func write(byte: UInt8) {
      withUnsafePointer(to: byte) {
         message.append($0, count: 1)
      }
   }

   public mutating func write(_ bytes: UnsafeRawBufferPointer) {
      bytes.withMemoryRebound(to: UInt8.self) { bytes in
         guard let baseAddress = bytes.baseAddress else {
            return
         }
         message.append(baseAddress, count: bytes.count)
      }
   }

   mutating func expectingWrites(byteCount: Int, writeBytes: (inout Self) -> Void) {
      let byteCountBeforeWrites = message.count

      writeBytes(&self)

      let writtenByteCount = message.count - byteCountBeforeWrites
      precondition(writtenByteCount == byteCount, "Expected \(byteCount) byte(s) to be written but found \(writtenByteCount).")
   }
}
