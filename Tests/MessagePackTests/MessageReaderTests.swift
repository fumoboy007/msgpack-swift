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

class MessageReaderTests: XCTestCase {
   func testReadByte() {
      let message = Self.makeMessage(containing: [0, 1])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 2)

      XCTAssertEqual(try reader.readByte(), 0)
      XCTAssertEqual(reader.remainingByteCount, 1)

      XCTAssertEqual(try reader.readByte(), 1)
      XCTAssertEqual(reader.remainingByteCount, 0)

      XCTAssertThrowsError(try reader.readByte())
      XCTAssertEqual(reader.remainingByteCount, 0)
   }

   func testReadBytesIntoUnsafeRawBuffer_exactlyEnoughBytes() throws {
      let message = Self.makeMessage(containing: [0, 1, 2])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 3)

      try readBytesIntoUnsafeRawBuffer(byteCount: 1,
                                       from: &reader,
                                       assertEqualTo: [0])
      XCTAssertEqual(reader.remainingByteCount, 2)

      try readBytesIntoUnsafeRawBuffer(byteCount: 2,
                                       from: &reader,
                                       assertEqualTo: [1, 2])
      XCTAssertEqual(reader.remainingByteCount, 0)

      XCTAssertThrowsError(try reader.reading(byteCount: 1, perform: { _ in }))
      XCTAssertEqual(reader.remainingByteCount, 0)
   }

   func testReadBytesIntoUnsafeRawBuffer_requestedByteCountExceedsMax() {
      let message = Self.makeMessage(containing: [0])
      var reader = MessageReader(message: message)

      XCTAssertThrowsError(try reader.reading(byteCount: UInt64.max, perform: { _ in }))
   }

   func testReadBytesIntoUnsafeRawBuffer_requestedByteCountExceedsAvailableByteCount() throws {
      let message = Self.makeMessage(containing: [0, 1])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 2)

      try readBytesIntoUnsafeRawBuffer(byteCount: 1,
                                       from: &reader,
                                       assertEqualTo: [0])
      XCTAssertEqual(reader.remainingByteCount, 1)

      XCTAssertThrowsError(try reader.reading(byteCount: 2) { _ in })
      XCTAssertEqual(reader.remainingByteCount, 1)
   }

   func testReadBytesIntoUnsafeRawBuffer_rethrowsBytesHandlerError() {
      let message = Self.makeMessage(containing: [0])
      var reader = MessageReader(message: message)

      XCTAssertThrowsError(try reader.reading(byteCount: 1) { _ in throw ErrorFake() })
   }

   func testReadBytesIntoData_exactlyEnoughBytes() throws {
      let message = Self.makeMessage(containing: [0, 1, 2])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 3)

      XCTAssertEqual(try reader.read(byteCount: 1), Data([0]))
      XCTAssertEqual(reader.remainingByteCount, 2)

      XCTAssertEqual(try reader.read(byteCount: 2), Data([1, 2]))
      XCTAssertEqual(reader.remainingByteCount, 0)

      XCTAssertThrowsError(try reader.read(byteCount: 1))
      XCTAssertEqual(reader.remainingByteCount, 0)
   }

   func testReadBytesIntoData_requestedByteCountExceedsMax() {
      let message = Self.makeMessage(containing: [0])
      var reader = MessageReader(message: message)

      XCTAssertThrowsError(try reader.read(byteCount: UInt64.max))
   }

   func testReadBytesIntoData_requestedByteCountExceedsAvailableByteCount() throws {
      let message = Self.makeMessage(containing: [0, 1])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 2)

      XCTAssertEqual(try reader.read(byteCount: 1), Data([0]))
      XCTAssertEqual(reader.remainingByteCount, 1)

      XCTAssertThrowsError(try reader.read(byteCount: 2))
      XCTAssertEqual(reader.remainingByteCount, 1)
   }

   func testReadBytes_allMethods() throws {
      let message = Self.makeMessage(containing: [0, 1, 2])
      var reader = MessageReader(message: message)

      XCTAssertEqual(reader.remainingByteCount, 3)

      XCTAssertEqual(try reader.readByte(), 0)
      XCTAssertEqual(reader.remainingByteCount, 2)

      try readBytesIntoUnsafeRawBuffer(byteCount: 1,
                                       from: &reader,
                                       assertEqualTo: [1])
      XCTAssertEqual(reader.remainingByteCount, 1)

      XCTAssertEqual(try reader.read(byteCount: 1), Data([2]))
      XCTAssertEqual(reader.remainingByteCount, 0)
   }

   // MARK: - Private

   private static func makeMessage(containing bytes: [UInt8]) -> Data {
      let fillerByteCount = Int.random(in: 1...100)

      var messageWithFillerBytes = Data(repeating: 0, count: fillerByteCount)
      messageWithFillerBytes.append(contentsOf: bytes)

      // Return a slice to verify that the implementation supports a non-zero start index.
      return messageWithFillerBytes[fillerByteCount...]
   }

   private func readBytesIntoUnsafeRawBuffer(byteCount: Int,
                                             from reader: inout MessageReader,
                                             assertEqualTo expectedBytes: [UInt8]) throws {
      var wasBytesHandlerCalled = false

      let expectedReturnValue = ProcessInfo.processInfo.globallyUniqueString
      let returnValue = try reader.reading(byteCount: byteCount) { bytes in
         wasBytesHandlerCalled = true

         XCTAssertEqual(Array(bytes), expectedBytes)

         return expectedReturnValue
      }
      XCTAssertEqual(returnValue, expectedReturnValue)

      XCTAssertTrue(wasBytesHandlerCalled)
   }
}
