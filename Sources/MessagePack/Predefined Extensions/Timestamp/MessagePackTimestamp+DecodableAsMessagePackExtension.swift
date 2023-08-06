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

#if canImport(Darwin)
import Foundation
#else
// https://github.com/apple/swift-corelibs-foundation/issues/4687
@preconcurrency import Foundation
#endif

extension MessagePackTimestamp {
   private enum DecodingError: Error {
      case unknownFormat(Data)
      case nanosecondsComponentExceedsMax(UInt32)
   }

   public init(decoding bytes: UnsafeRawBufferPointer) throws {
      switch bytes.count {
      case 4:
         self.init(timestamp32: bytes)

      case 8:
         try self.init(timestamp64: bytes)

      case 12:
         try self.init(timestamp96: bytes)

      default:
         throw DecodingError.unknownFormat(Data(bytes))
      }
   }

   private init(timestamp32 bytes: UnsafeRawBufferPointer) {
      let secondsComponent = UInt32(bigEndian: bytes.loadUnaligned(as: UInt32.self))

      self.init(secondsComponent: Int64(secondsComponent),
                nanosecondsComponent: 0)
   }

   private init(timestamp64 bytes: UnsafeRawBufferPointer) throws {
      let mergedValue = UInt64(bigEndian: bytes.loadUnaligned(as: UInt64.self))

      let nanosecondsComponent = UInt32(mergedValue >> 34)
      guard nanosecondsComponent <= Self.nanosecondsComponentMax else {
         throw DecodingError.nanosecondsComponentExceedsMax(nanosecondsComponent)
      }

      self.init(secondsComponent: Int64(mergedValue & 0x3ffffffff),
                nanosecondsComponent: nanosecondsComponent)
   }

   private init(timestamp96 bytes: UnsafeRawBufferPointer) throws {
      let nanosecondsComponent = UInt32(bigEndian: bytes.loadUnaligned(as: UInt32.self))
      guard nanosecondsComponent <= Self.nanosecondsComponentMax else {
         throw DecodingError.nanosecondsComponentExceedsMax(nanosecondsComponent)
      }

      let secondsComponent = Int64(bigEndian: bytes.loadUnaligned(fromByteOffset: 4, as: Int64.self))

      self.init(secondsComponent: secondsComponent,
                nanosecondsComponent: nanosecondsComponent)
   }
}
