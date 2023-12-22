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

class MessagePackDecoderTests: XCTestCase {
   func testNotEnoughBytes() throws {
      let message = try packIntoPacker { packer in
         let status = msgpack_pack_array(&packer, 1)
         XCTAssertEqual(status, 0)
      }

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Int].self, from: message))
   }

   func testExtraBytesAtEndOfMessage() throws {
      let message = try packIntoPacker { packer in
         var status = msgpack_pack_true(&packer)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_true(&packer)
         XCTAssertEqual(status, 0)
      }

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode(Bool.self, from: message))
   }

   func testNil() throws {
      try test(Nil(), encodesAndThenDecodesTo: nil as Bool?)
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

   private func test<T>(_ type: T.Type) throws where T: BinaryInteger & Decodable {
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

      try testIntegerValues(decodeAs: Float32.self)
   }

   func testFloat32_nan() throws {
      let value = Float32(nan: 1, signaling: true)

      let message = try pack(value)

      let decoder = MessagePackDecoder()
      let decodedValue = try decoder.decode(Float32.self, from: message)

      XCTAssertTrue(decodedValue.isNaN)
      XCTAssertTrue(decodedValue.isSignalingNaN)
      XCTAssertEqual(decodedValue.significandBitPattern, value.significandBitPattern)
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

      try testIntegerValues(decodeAs: Float64.self)
   }

   func testFloat64_nan() throws {
      let value = Float64(nan: 1, signaling: true)

      let message = try pack(value)

      let decoder = MessagePackDecoder()
      let decodedValue = try decoder.decode(Float64.self, from: message)

      XCTAssertTrue(decodedValue.isNaN)
      XCTAssertTrue(decodedValue.isSignalingNaN)
      XCTAssertEqual(decodedValue.significandBitPattern, value.significandBitPattern)
   }

   private func testIntegerValues<FloatingPointType>(
      decodeAs floatingPointType: FloatingPointType.Type
   ) throws where FloatingPointType: BinaryFloatingPoint & Decodable {
      try testValues(of: Int.self, decodeAs: floatingPointType)
      try testValues(of: Int8.self, decodeAs: floatingPointType)
      try testValues(of: Int16.self, decodeAs: floatingPointType)
      try testValues(of: Int32.self, decodeAs: floatingPointType)
      try testValues(of: Int64.self, decodeAs: floatingPointType)
      try testValues(of: UInt.self, decodeAs: floatingPointType)
      try testValues(of: UInt8.self, decodeAs: floatingPointType)
      try testValues(of: UInt16.self, decodeAs: floatingPointType)
      try testValues(of: UInt32.self, decodeAs: floatingPointType)
      try testValues(of: UInt64.self, decodeAs: floatingPointType)
   }

   private func testValues<IntegerType, FloatingPointType>(
      of integerType: IntegerType.Type,
      decodeAs floatingPointType: FloatingPointType.Type
   ) throws where IntegerType: BinaryInteger, FloatingPointType: BinaryFloatingPoint & Decodable {
      // Only test integers up to 16 bits so that the test does not take forever.
      let valuesToTest = (Int16.min...Int16.max).compactMap { IntegerType(exactly: $0) }

      for value in valuesToTest {
         guard let floatingPointValue = FloatingPointType(exactly: value) else {
            continue
         }

         try test(value, encodesAndThenDecodesTo: floatingPointValue)
      }
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

      let value = String(repeatingASCII: "a", count: Int(UInt32.max))

      try test(value)
   }

   func testString_invalidUTF8Bytes() throws {
      let message = try packIntoPacker { packer in
         [0xff].withUnsafeBytes { bytes in
            let status = msgpack_pack_str_with_body(&packer, bytes.baseAddress!, bytes.count)
            XCTAssertEqual(status, 0)
         }
      }

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode(String.self, from: message))
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

      let value = Data(repeating: 1, count: Int(UInt32.max))

      try test(value)
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
      try RuntimeEnvironment.skipTestIfAvailableMemoryLessThan(gib: 40)
      try RuntimeEnvironment.skipTestIfProgramNotOptimized()

      let array = [UInt8](repeating: 1, count: Int(UInt32.max))

      let message = try packIntoPacker(minimumBufferCapacity: 1 + 4 + array.count) { packer in
         msgpack_pack_array(&packer, array.count)

         for value in array {
            msgpack_pack_uint8(&packer, value)
         }
      }

      let decoder = MessagePackDecoder()
      let decodedArray = try decoder.decode(type(of: array), from: message)

      // Hack: Use this approach instead of `XCTAssertEqual`, which is not inlinable. The compiler
      // can inline and specialize the `Array.==` generic function to avoid slow `Equatable`
      // protocol witness table lookups per element.
      XCTAssertTrue(decodedArray == array, "Decoded array is not equal to original array.")
   }

   func testArray_hasNilElement() throws {
      try test([Nil()], encodesAndThenDecodesTo: [nil as Bool?])
   }

   func testArray_heterogeneous() throws {
      try test([0, 1.0], encodesAndThenDecodesTo: [0, 1.0])
   }

   func testArray_asSet() throws {
      try test([1], encodesAndThenDecodesTo: Set([1]))
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
      try test([1: Nil()], encodesAndThenDecodesTo: [1: nil as Bool?])
   }

   func testMap_intKeys() throws {
      try test([1: 1])
   }

   func testMap_stringKeys() throws {
      try test(["a": 1])
   }

   func testMap_unsupportedKeyType() throws {
      let message = try packIntoPacker { packer in
         var status = msgpack_pack_map(&packer, 1)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_true(&packer)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_true(&packer)
         XCTAssertEqual(status, 0)
      }

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Bool: Bool].self, from: message))
   }

   func testMap_heterogeneousValues() throws {
      struct TypeWithHeterogeneousCodingValues: Decodable, Equatable {
         let intValue: Int
         let doubleValue: Double
         let stringValue: String
      }

      let dictionary: [String: AnyHashable] = [
         "intValue": 1,
         "doubleValue": 2.0,
         "stringValue": "3"
      ]

      let expectedValue = TypeWithHeterogeneousCodingValues(intValue: 1,
                                                            doubleValue: 2.0,
                                                            stringValue: "3")
      try test(dictionary, encodesAndThenDecodesTo: expectedValue)
   }

   func testMap_heterogeneousKeys() throws {
      struct TypeWithHeterogeneousCodingKeys: Decodable, Equatable {
         let valueForIntKey: Int
         let valueForStringKey: Int

         init(valueForIntKey: Int, valueForStringKey: Int) {
            self.valueForIntKey = valueForIntKey
            self.valueForStringKey = valueForStringKey
         }

         enum IntCodingKeys: Int, CodingKey {
            case intKey = 0
         }

         enum StringCodingKeys: String, CodingKey {
            case stringKey = "1"
         }

         init(from decoder: Decoder) throws {
            let intKeyedContainer = try decoder.container(keyedBy: IntCodingKeys.self)
            self.valueForIntKey = try intKeyedContainer.decode(Int.self, forKey: .intKey)

            let stringKeyedContainer = try decoder.container(keyedBy: StringCodingKeys.self)
            self.valueForStringKey = try stringKeyedContainer.decode(Int.self, forKey: .stringKey)
         }
      }

      let dictionary: [AnyHashable: AnyHashable] = [
         0: 1,
         "1": 2
      ]

      let expectedValue = TypeWithHeterogeneousCodingKeys(valueForIntKey: 1,
                                                          valueForStringKey: 2)
      try test(dictionary, encodesAndThenDecodesTo: expectedValue)
   }

   func testMap_duplicateKey() throws {
      let message = try packIntoPacker { packer in
         var status = msgpack_pack_map(&packer, 2)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_int(&packer, 0)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_int(&packer, 1)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_int(&packer, 0)
         XCTAssertEqual(status, 0)

         status = msgpack_pack_int(&packer, 2)
         XCTAssertEqual(status, 0)
      }

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Int: Int].self, from: message))
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

      var decoder = MessagePackDecoder()
      decoder.applicationSpecificExtensionTypes = [ApplicationSpecificExtensionFake.self]

      for expectedValue in valuesToTest {
         let valueToEncode = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID,
                                                  data: expectedValue.data)
         try test(valueToEncode, encodesAndThenDecodesTo: expectedValue, using: decoder)
      }
   }

   func testExtension_maxLength() throws {
      try RuntimeEnvironment.skipTestIfAvailableMemoryLessThan(gib: 12)

      let expectedValue = ApplicationSpecificExtensionFake(data: Data(repeating: 1, count: Int(UInt32.max)))

      var decoder = MessagePackDecoder()
      decoder.applicationSpecificExtensionTypes = [ApplicationSpecificExtensionFake.self]

      let valueToEncode = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID,
                                               data: expectedValue.data)
      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue, using: decoder)
   }

   func testExtension_unknown() throws {
      let value = MessagePackExtension(typeID: ApplicationSpecificExtensionFake.extensionTypeID, data: Data())

      let message = try pack(value)

      var decoder = MessagePackDecoder()
      decoder.applicationSpecificExtensionTypes.removeAll()

      XCTAssertThrowsError(try decoder.decode(ApplicationSpecificExtensionFake.self, from: message))
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

      for expectedValue in valuesToTest {
         let valueToEncode = msgpack_timestamp(expectedValue)
         try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
      }
   }

   func testDate_fromTimestamp() throws {
      let valueToEncode = msgpack_timestamp(tv_sec: 0, tv_nsec: 0)

      let expectedValue = Date(timeIntervalSince1970: 0)

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDate_fromInternetDateTime() throws {
      let valuesToEncode = [
         "1970-01-01T00:00:00Z",
         "1970-01-01T00:00:00.0Z"
      ]

      let expectedValue = Date(timeIntervalSince1970: 0)

      for valueToEncode in valuesToEncode {
         try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
      }
   }

   func testURL() throws {
      let valueToEncode = "http://foo/bar"

      let expectedValue = URL(string: valueToEncode)

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal_fromSignedInteger() throws {
      let valueToEncode = -1

      let expectedValue = Decimal(valueToEncode)

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal_fromUnsignedInteger() throws {
      let valueToEncode = 1

      let expectedValue = Decimal(valueToEncode)

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal_fromFloat32() throws {
      let valueToEncode: Float32 = 1.23

      let expectedValue = Decimal(Float64(valueToEncode))

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal_fromFloat64() throws {
      let valueToEncode: Float64 = 1.23

      let expectedValue = Decimal(valueToEncode)

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testDecimal_fromString() throws {
      let valueToEncode = "1.230"

      let expectedValue = Decimal(string: "1.23")!

      try test(valueToEncode, encodesAndThenDecodesTo: expectedValue)
   }

   func testUserInfo() throws {
      var decoder = MessagePackDecoder()
      decoder.userInfo[.fake] = "fakeUserInfoValue"

      try test([
         [
            "typeThatChecksUserInfo": Nil()
         ]
      ], encodesAndThenDecodesTo: [
         [
            "typeThatChecksUserInfo": TypeThatChecksUserInfo()
         ]
      ], using: decoder)
   }

   func testKeyedContainer_valueNotMap() throws {
      let message = try pack(true)

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Int: Int].self, from: message))
   }

   func testKeyedContainer_keyNotFound() throws {
      let message = try pack(["nonexistentKey": 0])

      let decoder = MessagePackDecoder()

      struct KeyedContainerType: Decodable {
         let key: Int
      }
      XCTAssertThrowsError(try decoder.decode(KeyedContainerType.self, from: message))
   }

   func testKeyedContainer_valueTypeMismatch() throws {
      let message = try pack(["key": true])

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([String: Int].self, from: message))
   }

   func testKeyedContainer_valueIsUnexpectedlyNil() throws {
      let message = try pack(["key": Nil()])

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([String: String].self, from: message))
   }

   func testUnkeyedContainer_valueNotArray() throws {
      let message = try pack(true)

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Int].self, from: message))
   }

   func testUnkeyedContainer_notEnoughElements() throws {
      let message = try pack([Int]())

      let decoder = MessagePackDecoder()

      struct UnkeyedContainerType: Decodable {
         let value: Int

         init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()

            self.value = try container.decode(Int.self)
         }
      }
      XCTAssertThrowsError(try decoder.decode(UnkeyedContainerType.self, from: message))
   }

   func testUnkeyedContainer_elementTypeMismatch() throws {
      let message = try pack([true])

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([Int].self, from: message))
   }

   func testUnkeyedContainer_elementIsUnexpectedlyNil() throws {
      let message = try pack([Nil()])

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode([String].self, from: message))
   }

   func testSingleValueContainer_typeMismatch() throws {
      let message = try pack(true)

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode(Int.self, from: message))
   }

   func testSingleValueContainer_unexpectedlyNil() throws {
      let message = try pack(Nil())

      let decoder = MessagePackDecoder()

      XCTAssertThrowsError(try decoder.decode(Int.self, from: message))
   }

   func testNestedType_encodingAsNested() throws {
      let value: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]

      let expectedValue = NestedTypeEncodingAsNested(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsNestedUnkeyed() throws {
      let value: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeValue"
         ]
      ]

      let expectedValue = NestedTypeEncodingAsNestedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsFlattened() throws {
      let value = [
         "outerTypeProperty": "outerTypeValue",
         "innerTypeProperty": "innerTypeValue"
      ]

      let expectedValue = NestedTypeEncodingAsFlattened(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testNestedType_encodingAsFlattenedUnkeyed() throws {
      let value = [
         "outerTypeValue",
         "innerTypeValue"
      ]

      let expectedValue = NestedTypeEncodingAsFlattenedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerType: .init(innerTypeProperty: "innerTypeValue")
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested() throws {
      let value: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]

      let expectedValue = FlattenedTypeEncodingAsNested(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNestedUnkeyed() throws {
      let value: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeValue"
         ]
      ]

      let expectedValue = FlattenedTypeEncodingAsNestedUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested_innerMessageUnkeyed() throws {
      let value: [String: AnyHashable] = [
         "outerTypeProperty": "outerTypeValue",
         "innerType": [
            "innerTypeValue"
         ]
      ]

      let expectedValue = FlattenedTypeEncodingAsNestedWithInnerMessageUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testFlattenedType_encodingAsNested_outerMessageUnkeyed() throws {
      let value: [AnyHashable] = [
         "outerTypeValue",
         [
            "innerTypeProperty": "innerTypeValue"
         ]
      ]

      let expectedValue = FlattenedTypeEncodingAsNestedWithOuterMessageUnkeyed(
         outerTypeProperty: "outerTypeValue",
         innerTypeProperty: "innerTypeValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testTypeWithSuperclass_encodingAsNested() throws {
      let value: [String: AnyHashable] = [
         "super": [
            "superclassProperty": "superclassValue"
         ],
         "subclassProperty": "subclassValue"
      ]

      let expectedValue = TypeWithSuperclassEncodingAsNested(
         subclassProperty: "subclassValue",
         superclassProperty: "superclassValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   func testTypeWithSuperclass_encodingAsNestedUnkeyed() throws {
      let value: [AnyHashable] = [
         [
            "superclassProperty": "superclassValue"
         ],
         "subclassValue"
      ]

      let expectedValue = TypeWithSuperclassEncodingAsNestedUnkeyed(
         subclassProperty: "subclassValue",
         superclassProperty: "superclassValue"
      )

      try test(value, encodesAndThenDecodesTo: expectedValue)
   }

   private func test<T>(_ value: T) throws where T: Equatable & Decodable {
      try test(value, encodesAndThenDecodesTo: value)
   }

   private func test<ValueToEncode, DecodedValue>(
      _ valueToEncode: ValueToEncode,
      encodesAndThenDecodesTo expectedValue: DecodedValue,
      using decoder: MessagePackDecoder = MessagePackDecoder()
   ) throws where ValueToEncode: Equatable, DecodedValue: Decodable & Equatable {
      let message = try pack(valueToEncode)

      let decodedValue = try decoder.decode(type(of: expectedValue), from: message)

      XCTAssertEqual(decodedValue, expectedValue)
   }
}

#endif  // HAS_REFERENCE_IMPLEMENTATION
