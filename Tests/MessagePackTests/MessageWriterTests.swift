// MIT License
//
// Copyright © 2024 Darren Mo.
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

@testable import MessagePack

import XCTest

class MessageWriterTests: XCTestCase {
   func testNoWrites() {
      let writer = MessageWriter()

      XCTAssertEqual(writer.message, Data())
   }

   func testWriteByte() {
      var writer = MessageWriter()

      let byte = UInt8.random(in: .min...(.max))
      Self.write(byte, to: &writer)

      XCTAssertEqual(writer.message, Data([byte]))
   }

   func testWriteByte_multiple() {
      var writer = MessageWriter()

      var bytes = [UInt8]()
      let byteCount = Int.random(in: 1...Int(UInt8.max))
      for _ in 0..<byteCount {
         let byte = UInt8.random(in: .min...(.max))
         bytes.append(byte)

         Self.write(byte, to: &writer)
      }

      XCTAssertEqual(writer.message, Data(bytes))
   }

   func testWriteBytes() {
      var writer = MessageWriter()

      var bytes = [UInt8]()
      let byteCount = Int.random(in: 1...Int(UInt8.max))
      for _ in 0..<byteCount {
         bytes.append(.random(in: .min...(.max)))
      }

      Self.write(bytes, to: &writer)

      XCTAssertEqual(writer.message, Data(bytes))
   }

   func testWriteBytes_empty() {
      var writer = MessageWriter()

      Self.write([], to: &writer)

      XCTAssertEqual(writer.message, Data())
   }

   func testWriteBytes_multiple() {
      var writer = MessageWriter()

      var bytes = [UInt8]()
      let byteCount = Int.random(in: 1...Int(UInt8.max))
      for _ in 0..<byteCount {
         let byte = UInt8.random(in: .min...(.max))
         bytes.append(byte)

         Self.write([byte], to: &writer)
      }

      XCTAssertEqual(writer.message, Data(bytes))
   }

   func testWriteByteAndWriteBytes() {
      var writer = MessageWriter()

      let byte = UInt8.random(in: .min...(.max))
      Self.write(byte, to: &writer)

      var bytes = [UInt8]()
      let byteCount = Int.random(in: 1...Int(UInt8.max))
      for _ in 0..<byteCount {
         bytes.append(.random(in: .min...(.max)))
      }

      Self.write(bytes, to: &writer)

      XCTAssertEqual(writer.message, Data([byte]) + Data(bytes))
   }

   // MARK: - Private

   private static func write(_ byte: UInt8, to writer: inout MessageWriter) {
      writer.expectingWrites(byteCount: 1) { writer in
         writer.write(byte: byte)
      }
   }

   private static func write(_ bytes: [UInt8], to writer: inout MessageWriter) {
      let byteCount = bytes.count

      let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: byteCount)
      defer {
         buffer.deallocate()
      }

      _ = buffer.initialize(fromContentsOf: bytes)

      writer.expectingWrites(byteCount: byteCount) { writer in
         writer.write(UnsafeRawBufferPointer(buffer))
      }
   }
}
