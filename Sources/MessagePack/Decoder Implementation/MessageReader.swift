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

#if compiler(>=5.9)
struct MessageReader: ~Copyable {
   private let message: Data
   private var currentIndex: Int
}
#else
struct MessageReader {
   private let message: Data
   private var currentIndex: Int
}
#endif

extension MessageReader {
   enum ReadingError: Error {
      case notEnoughBytesRemainingForRequest(Int, UInt64)
   }

   init(message: Data) {
      self.message = message
      self.currentIndex = 0
   }

   var remainingByteCount: Int {
      return message.count - currentIndex
   }

   mutating func readByte() throws -> UInt8 {
      let currentIndex = currentIndex
      let nextIndex = currentIndex + 1
      guard nextIndex <= message.count else {
         throw ReadingError.notEnoughBytesRemainingForRequest(remainingByteCount, 1)
      }

      self.currentIndex = nextIndex

      return message[currentIndex]
   }

   mutating func reading<ByteCount, ReturnType>(
      byteCount: ByteCount,
      perform bytesHandler: (UnsafeRawBufferPointer) throws -> ReturnType
   ) throws -> ReturnType where ByteCount: BinaryInteger {
      guard let byteCount = Int(exactly: byteCount) else {
         throw ReadingError.notEnoughBytesRemainingForRequest(remainingByteCount, UInt64(byteCount))
      }

      return try message.withUnsafeBytes { bytes in
         let startIndex = currentIndex
         let endIndex = startIndex + byteCount
         guard endIndex <= bytes.count else {
            throw ReadingError.notEnoughBytesRemainingForRequest(remainingByteCount, UInt64(byteCount))
         }

         currentIndex = endIndex

         let requestedBytes = UnsafeRawBufferPointer(rebasing: bytes[startIndex..<endIndex])
         return try bytesHandler(requestedBytes)
      }
   }

   mutating func read<ByteCount: BinaryInteger>(byteCount: ByteCount) throws -> Data {
      guard let byteCount = Int(exactly: byteCount) else {
         throw ReadingError.notEnoughBytesRemainingForRequest(remainingByteCount, UInt64(byteCount))
      }

      let startIndex = currentIndex
      let endIndex = startIndex + byteCount
      guard endIndex <= message.count else {
         throw ReadingError.notEnoughBytesRemainingForRequest(remainingByteCount, UInt64(byteCount))
      }

      currentIndex = endIndex

      return message[startIndex..<endIndex]
   }
}
