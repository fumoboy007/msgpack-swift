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

#if HAS_REFERENCE_IMPLEMENTATION

import MessagePack

import MessagePackReferenceImplementation
import XCTest

class MessagePackEncoderTests: XCTestCase {
   func testNil() throws {
      try test(nil as Bool?, encodesAndThenDecodesTo: Nil())
   }

   func testBoolean_true() throws {
      try test(true)
   }

   func testBoolean_false() throws {
      try test(false)
   }

   func testInt() throws {
      try test(Int.self)
   }

   func testInt8() throws {
      try test(Int8.self)
   }

   func testInt16() throws {
      try test(Int16.self)
   }

   func testInt32() throws {
      try test(Int32.self)
   }

   func testInt64() throws {
      try test(Int64.self)
   }

   func testUInt() throws {
      try test(UInt.self)
   }

   func testUInt8() throws {
      try test(UInt8.self)
   }

   func testUInt16() throws {
      try test(UInt16.self)
   }

   func testUInt32() throws {
      try test(UInt32.self)
   }

   func testUInt64() throws {
      try test(UInt64.self)
   }

   private func test<T>(_ type: T.Type) throws where T: BinaryInteger & Encodable {
      var valuesToTest = [T]()

      let negativeValuesToTest = [
         0,
         -1,
         -32,
         -33,
         Int64(Int8.min),
         Int64(Int8.min) - 1,
         Int64(Int16.min),
         Int64(Int16.min) - 1,
         Int64(Int32.min),
         Int64(Int32.min) - 1,
         Int64.min
      ]
      for value in negativeValuesToTest {
         guard let value = T(exactly: value) else {
            continue
         }
         valuesToTest.append(value)
      }

      let positiveValuesToTest = [
         0,
         127,
         128,
         UInt64(UInt8.max),
         UInt64(UInt8.max) + 1,
         UInt64(UInt16.max),
         UInt64(UInt16.max) + 1,
         UInt64(UInt32.max),
         UInt64(UInt32.max) + 1,
         UInt64.max
      ]
      for value in positiveValuesToTest {
         guard let value = T(exactly: value) else {
            continue
         }
         valuesToTest.append(value)
      }

      for value in valuesToTest {
         try test(value)
      }
   }

   func testFloat32() throws {
      let valuesToTest: [Float32] = [
         .greatestFiniteMagnitude,
         .infinity,
         -.infinity,
         .leastNonzeroMagnitude,
         .leastNormalMagnitude,
         .pi,
         .ulpOfOne,
         .zero,
      ]

      for value in valuesToTest {
         try test(value)
      }
   }

   func testFloat32_nan() throws {
      let value = Float32(nan: 1, signaling: true)

      let encoder = MessagePackEncoder()
      let message = try encoder.encode(value)

      let decodedValue = try unpack(message)
      let decodedFloat32 = try XCTUnwrap(decodedValue as? Float32, "\(decodedValue) is not `Float32`.)")

      XCTAssertTrue(decodedFloat32.isNaN)
      // TODO: Change this to `XCTAssertTrue` when the following issue in the reference implementation is resolved:
      // https://github.com/msgpack/msgpack-c/issues/1087
      XCTAssertFalse(decodedFloat32.isSignalingNaN)
      XCTAssertEqual(decodedFloat32.nanPayload, value.nanPayload)
   }

   func testFloat64() throws {
      let valuesToTest: [Float64] = [
         .greatestFiniteMagnitude,
         .infinity,
         -.infinity,
         .leastNonzeroMagnitude,
         .leastNormalMagnitude,
         .pi,
         .ulpOfOne,
         .zero,
      ]

      for value in valuesToTest {
         try test(value)
      }
   }

   func testFloat64_nan() throws {
      let value = Float64(nan: 1, signaling: true)

      let encoder = MessagePackEncoder()
      let message = try encoder.encode(value)

      let decodedValue = try unpack(message)
      let decodedFloat64 = try XCTUnwrap(decodedValue as? Float64)

      XCTAssertTrue(decodedFloat64.isNaN)
      XCTAssertTrue(decodedFloat64.isSignalingNaN)
      XCTAssertEqual(decodedFloat64.significandBitPattern, value.significandBitPattern)
   }

   func testString() throws {
      let valuesToTest: [String] = [
         "",
         "𐀀",  // U+10000 LINEAR B SYLLABLE B008 A
         .init(repeatingASCII: "a", count: 31),
         .init(repeatingASCII: "a", count: 32),
         .init(repeatingASCII: "a", count: Int(UInt8.max)),
         .init(repeatingASCII: "a", count: Int(UInt8.max) + 1),
         .init(repeatingASCII: "a", count: Int(UInt16.max)),
         .init(repeatingASCII: "a", count: Int(UInt16.max) + 1)
      ]

      for value in valuesToTest {
         try test(value)
      }
   }

   func testString_maxLength() throws {
      try RuntimeEnvironment.skipTestIfAvailableMemoryLessThan(gib: 12)

      var string = String(repeatingASCII: "a", count: Int(UInt32.max))

      let encoder = MessagePackEncoder()
      let message = try encoder.encode(string)

      // Pack and compare bytes instead of unpacking message because the unpacker
      // reference implementation is too inefficient.
      let expectedMessage = try packIntoPacker(minimumBufferCapacity: 1 + 4 + string.utf8.count) { packer in
         let status = string.withUTF8 { bytes in
            return msgpack_pack_str_with_body(&packer, bytes.baseAddress!, bytes.count)
         }
         XCTAssertEqual(status, 0)
      }
      XCTAssertEqual(message, expectedMessage)
   }

   func testString_tooLong() throws {
      let value = String(repeatingASCII: "a", count: Int(UInt32.max) + 1)

      XCTAssertThrowsError(try test(value))
   }

   func testBinary() throws {
      let valuesToTest: [Data] = [
         .init(),
         .init([1]),
         .init([1, 2]),
         .init(repeating: 1, count: Int(UInt8.max)),
         .init(repeating: 1, count: Int(UInt8.max) + 1),
         .init(repeating: 1, count: Int(UInt16.max)),
         .init(repeating: 1, count: Int(UInt16.max) + 1)
      ]

      for value in valuesToTest {
         try test(value)
      }
   }

   func testBinary_maxLength() throws {
      try RuntimeEnvironment.skipTestIfAvailableMemoryLessThan(gib: 12)

      let data = Data(repeating: 1, count: Int(UInt32.max))

      let encoder = MessagePackEncoder()
      let message = try encoder.encode(data)

      // Pack and compare bytes instead of unpacking message because the unpacker
      // reference implementation is too inefficient.
      let expectedMessage = try packIntoPacker(minimumBufferCapacity: 1 + 4 + data.count) { packer in
         let status = data.withUnsafeBytes { bytes in
            return msgpack_pack_bin_with_body(&packer, bytes.baseAddress!, bytes.count)
         }
         XCTAssertEqual(status, 0)
      }
      XCTAssertEqual(message, expectedMessage)
   }

   func testBinary_tooLong() throws {
      let value = Data(repeating: 1, count: Int(UInt32.max) + 1)

      XCTAssertThrowsError(try test(value))
   }

   func testArray() throws {
      let arraysToTest: [[UInt8]] = [
         [UInt8](repeating: 1, count: 15),
         [UInt8](repeating: 1, count: 16),
         [UInt8](repeating: 1, count: Int(UInt16.max)),
         [UInt8](repeating: 1, count: Int(UInt16.max) + 1)
      ]

      for array in arraysToTest {
         try test(array)
      }
   }

   func testArray_maxLength() throws {
      try RuntimeEnvironment.skipTestIfAvailableMemoryLessThan(gib: 12)
      try RuntimeEnvironment.skipTestIfProgramNotOptimized()

      let array = [UInt8](repeating: 1, count: Int(UInt32.max))

      let encoder = MessagePackEncoder()
      let message = try encoder.encode(array)

      // Pack and compare bytes instead of unpacking message because the unpacker
      // reference implementation is too inefficient.
      let expectedMessage = try packIntoPacker(minimumBufferCapacity: 1 + 4 + array.count) { packer in
         var status = msgpack_pack_array(&packer, array.count)
         XCTAssertEqual(status, 0)

         for value in array {
            status = msgpack_pack_uint8(&packer, value)

            // Hack: Use this approach instead of `XCTAssertEqual`, which is not inlinable. The compiler
            // can inline and specialize the `Array.==` generic function to avoid slow `Equatable`
            // protocol witness table lookups per element.
            guard status == 0 else {
               XCTFail("`msgpack_pack_uint8` failed with status \(status).")
               break
            }
         }
      }
      XCTAssertEqual(message, expectedMessage)
   }

   func testArray_tooLong() throws {
      let array = [UInt8](repeating: 1, count: Int(UInt32.max) + 1)

      XCTAssertThrowsError(try test(array))
   }

   func testArray_hasNilElement() throws {
      try test([nil as Bool?], encodesAndThenDecodesTo: [Nil()])
   }

   func testArray_heterogeneous() throws {
      let array: [AnyHashable] = [
         0,
         1.0
      ]

      try test(array)
   }

   func testArray_asSet() throws {
      try test(Set([1]), encodesAndThenDecodesTo: [1])
   }

   func testMap() throws {
      let countsToTest = [
         15,
         16,
         Int(UInt16.max),
         Int(UInt16.max) + 1
      ].sorted()

      var dictionary = [Int: UInt8](minimumCapacity: countsToTest.last!)

      for count in countsToTest {
         let startKey = dictionary.count
         let endKey = startKey + count
         for key in startKey..<endKey {
            dictionary[key] = 1
         }

         try test(dictionary)
      }
   }

   func testMap_maxLength() throws {
      throw XCTSkip("""
         This test would use too much memory. \
         Dictionaries only encode into a keyed container when the key is `Int` or `String`. \
         Those types are much bigger than `UInt8`, which is used in the corresponding array test.
         """)
   }

   func testMap_tooLong() throws {
      throw XCTSkip("""
         This test would use too much memory. \
         Dictionaries only encode into a keyed container when the key is `Int` or `String`. \
         Those types are much bigger than `UInt8`, which is used in the corresponding array test.
         """)
   }

   func testMap_hasNilElement() throws {
      try test([1: nil as Bool?], encodesAndThenDecodesTo: [1: Nil()])
   }

   func testMap_intKeys() throws {
      try test([1: 1])
   }

   func testMap_stringKeys() throws {
      try test(["a": 1])
   }

   func testMap_heterogeneousValues() throws {
      let dictionary: [Int: AnyHashable] = [
         0: 1,
         1: 2.0,
         2: "3"
      ]

      try test(dictionary)
   }

   func testMap_heterogeneousKeys() throws {
      let dictionary: [AnyHashable: Int] = [
         0: 1,
         "1": 2
      ]

      let expectedValue = dictionary.flatMap { [$0.key, $0.value] as [AnyHashable] }
      try test(dictionary, encodesAndThenDecodesTo: expectedValue)
   }

   func testExtension() throws {
      let valuesToTest: [ApplicationSpecificExtensionFake] = [
            .init(data: Data(repeating: 1, count: 1)),
            .init(data: Data(repeating: 1, count: 2)),
            .init(data: Data(repeating: 1, count: 4)),
            .init(data: Data(repeating: 1, count: 8)),
            .init(data: Data(repeating: 1, count: 16)),
            .init(data: Data()),
            .init(data: Data(repeating: 1, count: 3)),
            .init(data: Data(repeating: 1, count: Int(UInt8.max))),
            .init(data: Data(repeating: 1, count: Int(UInt8.max) + 1)),
            .init(data: Data(repeating: 1, count: Int(UInt16.max))),
            .init(data: Data(repeating: 1, count: Int(UInt16.max) + 1))
      ]

      for value in valuesToTest {
         let expectedValue = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID,
                                                  data: value.data)
         try test(value, encodesAndThenDecodesTo: expectedValue)
      }
   }

   func testExtension_maxLength() throws {
      // TODO: Enable test after the following issue in the reference implementation is resolved:
      // https://github.com/msgpack/msgpack-c/issues/1086
      try XCTSkipIf(true, "Test fails because of an issue in the reference implementation.")

      let value = ApplicationSpecificExtensionFake(data: Data(repeating: 1, count: Int(UInt32.max)))

      let expectedValue = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID,
                                               data: value.data)
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testExtension_tooLong() throws {
      let value = ApplicationSpecificExtensionFake(data: Data(repeating: 1, count: Int(UInt32.max) + 1))

      let expectedValue = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID,
                                               data: value.data)
      XCTAssertThrowsError(try test(value, encodesAndThenDecodesTo: expectedValue))
   }

   func testTimestamp() throws {
      let valuesToTest = [
         MessagePackTimestamp(secondsComponent: 0, nanosecondsComponent: 0),
         MessagePackTimestamp(secondsComponent: Int64(UInt32.max), nanosecondsComponent: 0),
         MessagePackTimestamp(secondsComponent: -1, nanosecondsComponent: 0),
         MessagePackTimestamp(secondsComponent: Int64(UInt32.max) + 1, nanosecondsComponent: 0),
         MessagePackTimestamp(secondsComponent: 1 << 34 - 1, nanosecondsComponent: MessagePackTimestamp.nanosecondsComponentMax),
         MessagePackTimestamp(secondsComponent: 1 << 34, nanosecondsComponent: MessagePackTimestamp.nanosecondsComponentMax),
         MessagePackTimestamp(secondsComponent: Int64.max, nanosecondsComponent: MessagePackTimestamp.nanosecondsComponentMax),
      ]

      for value in valuesToTest {
         let expectedValue = msgpack_timestamp(value)
         try test(value, encodesAndThenDecodesTo: expectedValue)
      }
   }

   func testDate() throws {
      let value = Date(timeIntervalSince1970: 0)

      let expectedValue = msgpack_timestamp(tv_sec: 0, tv_nsec: 0)
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testURL() throws {
      let value = URL(string: "bar", relativeTo: URL(string: "http://foo"))

      let expectedValue = "http://foo/bar"
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal() throws {
      let value = Decimal(string: "1.230")!

      let expectedValue = "1.23"
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testUserInfo() throws {
      var encoder = MessagePackEncoder()
      encoder.userInfo[.fake] = "fakeUserInfoValue"

      try test([
         [
            "typeThatChecksUserInfo": TypeThatChecksUserInfo()
         ]
      ], encodesAndThenDecodesTo: [
         [
            "typeThatChecksUserInfo": Nil()
         ]
      ], using: encoder)
   }

   func testNestedType_encodingAsNested() throws {
      let value = NestedTypeEncodingAsNested(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      let expectedValue: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsNestedUnkeyed() throws {
      let value = NestedTypeEncodingAsNestedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      let expectedValue: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsFlattened() throws {
      let value = NestedTypeEncodingAsFlattened(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      let expectedValue = [
         "outerTypeProperty": "outerTypeValue",
         "innerTypeProperty": "innerTypeValue"
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsFlattenedUnkeyed() throws {
      let value = NestedTypeEncodingAsFlattenedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      let expectedValue = [
         "outerTypeValue",
         "innerTypeValue"
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested() throws {
      let value = FlattenedTypeEncodingAsNested(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      let expectedValue: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNestedUnkeyed() throws {
      let value = FlattenedTypeEncodingAsNestedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      let expectedValue: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested_innerMessageUnkeyed() throws {
      let value = FlattenedTypeEncodingAsNestedWithInnerMessageUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      let expectedValue: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested_outerMessageUnkeyed() throws {
      let value = FlattenedTypeEncodingAsNestedWithOuterMessageUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      let expectedValue: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testTypeWithSuperclass_encodingAsNested() throws {
      let value = TypeWithSuperclassEncodingAsNested(
         subclassProperty: "subclassValue",
         superclassProperty: "superclassValue"
      )

      let expectedValue: [String: AnyHashable] = [
         "super": [
            "superclassProperty": "superclassValue"
         ],
         "subclassProperty": "subclassValue"
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testTypeWithSuperclass_encodingAsNestedUnkeyed() throws {
      let value = TypeWithSuperclassEncodingAsNestedUnkeyed(
         subclassProperty: "subclassValue",
         superclassProperty: "superclassValue"
      )

      let expectedValue: [AnyHashable] = [
         [
            "superclassProperty": "superclassValue"
         ],
         "subclassValue"
      ]
      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   private func test<T>(_ value: T) throws where T: Encodable & Hashable {
      try test(value, encodesAndThenDecodesTo: value)
   }

   private func test<ValueToEncode, DecodedValue>(
      _ value: ValueToEncode,
      encodesAndThenDecodesTo expectedValue: DecodedValue,
      using encoder: MessagePackEncoder = MessagePackEncoder()
   ) throws where ValueToEncode: Encodable, DecodedValue: Hashable {
      let message = try encoder.encode(value)

      let decodedValue = try unpack(message)
      XCTAssertEqual(decodedValue, expectedValue)
   }
}

#endif
