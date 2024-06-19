// MIT License
//
// Copyright © 2023–2024 Darren Mo.
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
   static let initialCapacity = NSPageSize()

   // Manually manage an unsafe mutable buffer pointer instead of using `Data`.
   // `Data` is slow to append single bytes because it always calls `memmove`
   // rather than just storing the byte.
   private var buffer: UnsafeMutableBufferPointer<UInt8>! = .allocate(capacity: initialCapacity)
   private var totalByteCount = 0

   deinit {
      buffer?.deallocate()
   }

   // MARK: - Writing Bytes

   public mutating func write(byte: UInt8) {
      let writeIndex = totalByteCount

      totalByteCount += 1
      increaseCapacityIfNeeded()

      buffer.initializeElement(at: writeIndex, to: byte)
   }

   public mutating func write(_ bytes: UnsafeRawBufferPointer) {
      let writeStartIndex = totalByteCount

      totalByteCount += bytes.count
      increaseCapacityIfNeeded()

      bytes.withMemoryRebound(to: UInt8.self) { bytes in
         let writeEndIndex = buffer[writeStartIndex..<totalByteCount].initialize(fromContentsOf: bytes)
         precondition(writeEndIndex == totalByteCount)
      }
   }

   mutating func expectingWrites(byteCount: Int, writeBytes: (inout Self) -> Void) {
      let byteCountBeforeWrites = totalByteCount

      writeBytes(&self)

      let writtenByteCount = totalByteCount - byteCountBeforeWrites
      precondition(writtenByteCount == byteCount, "Expected \(byteCount) byte(s) to be written but found \(writtenByteCount).")
   }

   private mutating func increaseCapacityIfNeeded() {
      var capacity = buffer.count
      guard totalByteCount > capacity else {
         return
      }

      capacity = NSRoundUpToMultipleOfPageSize(totalByteCount)
      precondition(totalByteCount <= capacity)

      let newBaseAddress = realloc(buffer.baseAddress, capacity)!.assumingMemoryBound(to: UInt8.self)
      buffer = UnsafeMutableBufferPointer(start: newBaseAddress,
                                          count: capacity)
   }

   // MARK: - Getting the Message

   consuming func finish() -> Data {
      guard let baseAddress = buffer.baseAddress else {
         return Data()
      }

      // Set to `nil` so that `deinit` does not prematurely deallocate the buffer.
      // The buffer’s lifetime will be managed by the `Data` instance.
      buffer = nil

      return Data(bytesNoCopy: baseAddress,
                  count: totalByteCount,
                  deallocator: .custom({ (baseAddress, _) in baseAddress.deallocate() }))
   }
}
