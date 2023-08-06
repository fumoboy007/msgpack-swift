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

extension DecodedMessagePackValue {
   private enum DecodingError: Error {
      case unrecognizedFirstByte(UInt8)

      case failedToDecodeUTF8Bytes(Data)
      case duplicateMapKey(MessagePackKey)

      case extraBytesAtEndOfMessage(Int)
   }

   init(decoding message: Data,
        extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]) {
      var messageReader = MessageReader(message: message)
      self.init(decodingWithSilentFailuresFrom: &messageReader,
                extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      let remainingByteCount = messageReader.remainingByteCount
      guard remainingByteCount == 0 else {
         self = .invalid(DecodingError.extraBytesAtEndOfMessage(remainingByteCount))
         return
      }
   }

   private init(decodingWithSilentFailuresFrom messageReader: inout MessageReader,
                extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]) {
      do {
         try self.init(decodingFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)
      } catch {
         self = .invalid(error)
      }
   }

   private init(decodingFrom messageReader: inout MessageReader,
                extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]) throws {
      let firstByte = try messageReader.readByte()

      switch firstByte {
      case 0x00...0x7f:
         self.init(decodingFromPositiveFixint: firstByte)

      case 0x80...0x8f:
         let elementCount = firstByte & 0b1111
         try self.init(decodingMapFrom: &messageReader,
                       elementCount: elementCount,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0x90...0x9f:
         let elementCount = firstByte & 0b1111
         try self.init(decodingArrayFrom: &messageReader,
                       elementCount: elementCount,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0xa0...0xbf:
         let utf8ByteCount = firstByte & 0b11111
         try self.init(decodingStringFrom: &messageReader, utf8ByteCount: utf8ByteCount)

      case 0xc0:
         self = .nil

      case 0xc1:
         throw DecodingError.unrecognizedFirstByte(firstByte)

      case 0xc2:
         self = .boolean(false)

      case 0xc3:
         self = .boolean(true)

      case 0xc4:
         try self.init(decodingBinaryFrom: &messageReader, byteCountType: UInt8.self)

      case 0xc5:
         try self.init(decodingBinaryFrom: &messageReader, byteCountType: UInt16.self)

      case 0xc6:
         try self.init(decodingBinaryFrom: &messageReader, byteCountType: UInt32.self)

      case 0xc7:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       byteCountType: UInt8.self)

      case 0xc8:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       byteCountType: UInt16.self)

      case 0xc9:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       byteCountType: UInt32.self)

      case 0xca:
         try self.init(decodingFloat32From: &messageReader)

      case 0xcb:
         try self.init(decodingFloat64From: &messageReader)

      case 0xcc:
         try self.init(decoding: UInt8.self, from: &messageReader)

      case 0xcd:
         try self.init(decoding: UInt16.self, from: &messageReader)

      case 0xce:
         try self.init(decoding: UInt32.self, from: &messageReader)

      case 0xcf:
         try self.init(decoding: UInt64.self, from: &messageReader)

      case 0xd0:
         try self.init(decoding: Int8.self, from: &messageReader)

      case 0xd1:
         try self.init(decoding: Int16.self, from: &messageReader)

      case 0xd2:
         try self.init(decoding: Int32.self, from: &messageReader)

      case 0xd3:
         try self.init(decoding: Int64.self, from: &messageReader)

      case 0xd4:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       extensionDataByteCount: 1 as UInt8)

      case 0xd5:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       extensionDataByteCount: 2 as UInt8)

      case 0xd6:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       extensionDataByteCount: 4 as UInt8)

      case 0xd7:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       extensionDataByteCount: 8 as UInt8)

      case 0xd8:
         try self.init(decodingExtensionFrom: &messageReader,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                       extensionDataByteCount: 16 as UInt8)

      case 0xd9:
         try self.init(decodingStringFrom: &messageReader, byteCountType: UInt8.self)

      case 0xda:
         try self.init(decodingStringFrom: &messageReader, byteCountType: UInt16.self)

      case 0xdb:
         try self.init(decodingStringFrom: &messageReader, byteCountType: UInt32.self)

      case 0xdc:
         try self.init(decodingArrayFrom: &messageReader,
                       elementCountType: UInt16.self,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0xdd:
         try self.init(decodingArrayFrom: &messageReader,
                       elementCountType: UInt32.self,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0xde:
         try self.init(decodingMapFrom: &messageReader,
                       elementCountType: UInt16.self,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0xdf:
         try self.init(decodingMapFrom: &messageReader,
                       elementCountType: UInt32.self,
                       extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      case 0xe0...0xff:
         self.init(decodingFromNegativeFixint: firstByte)

      default:
         fatalError("First byte `0x\(String(firstByte, radix: 16))` not handled even though the switch statement is supposed to be exhaustive.")
      }
   }

   private init(decodingFromPositiveFixint firstByte: UInt8) {
      self = .unsignedInteger(UInt64(firstByte))
   }

   private init(decodingFromNegativeFixint firstByte: UInt8) {
      let value = Int8(bitPattern: firstByte)

      self = .signedInteger(Int64(value))
   }

   private init<T: FixedWidthInteger>(decoding type: T.Type,
                                      from messageReader: inout MessageReader) throws {
      let byteCount = MemoryLayout<T>.size

      let value = try messageReader.reading(byteCount: byteCount) { bytes in
         return T.init(bigEndian: bytes.loadUnaligned(as: type))
      }

      if let value = Int64(exactly: value) {
         self = .signedInteger(value)
      } else {
         self = .unsignedInteger(UInt64(value))
      }
   }

   private init(decodingFloat32From messageReader: inout MessageReader) throws {
      let value = try messageReader.reading(byteCount: MemoryLayout<Float32>.size) { bytes in
         return Float32(bitPattern: UInt32(bigEndian: bytes.loadUnaligned(as: UInt32.self)))
      }

      self = .float32(value)
   }

   private init(decodingFloat64From messageReader: inout MessageReader) throws {
      let value = try messageReader.reading(byteCount: MemoryLayout<Float64>.size) { bytes in
         return Float64(bitPattern: UInt64(bigEndian: bytes.loadUnaligned(as: UInt64.self)))
      }

      self = .float64(value)
   }

   private init<ByteCount>(
      decodingStringFrom messageReader: inout MessageReader,
      byteCountType: ByteCount.Type
   ) throws where ByteCount: UnsignedInteger & FixedWidthInteger {
      let byteCountSize = MemoryLayout<ByteCount>.size
      let byteCount = try messageReader.reading(byteCount: byteCountSize) { bytes in
         return ByteCount(bigEndian: bytes.loadUnaligned(as: byteCountType))
      }

      try self.init(decodingStringFrom: &messageReader, utf8ByteCount: byteCount)
   }

   private init<ByteCount: BinaryInteger>(decodingStringFrom messageReader: inout MessageReader,
                                          utf8ByteCount: ByteCount) throws {
      let string = try messageReader.reading(byteCount: utf8ByteCount) { bytes in
         // TODO: Provide an option to replace invalid characters with the Unicode replacement character.
         guard let string = String(utf8Bytes: bytes) else {
            throw DecodingError.failedToDecodeUTF8Bytes(Data(bytes))
         }
         return string
      }

      self = .string(string)
   }

   private init<ByteCount>(
      decodingBinaryFrom messageReader: inout MessageReader,
      byteCountType: ByteCount.Type
   ) throws where ByteCount: UnsignedInteger & FixedWidthInteger {
      let byteCountSize = MemoryLayout<ByteCount>.size
      let byteCount = try messageReader.reading(byteCount: byteCountSize) { bytes in
         return ByteCount(bigEndian: bytes.loadUnaligned(as: byteCountType))
      }

      let data = try messageReader.read(byteCount: byteCount)

      self = .binary(data)
   }

   private init<ElementCount>(
      decodingArrayFrom messageReader: inout MessageReader,
      elementCountType: ElementCount.Type,
      extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]
   ) throws where ElementCount: UnsignedInteger & FixedWidthInteger {
      let elementCountSize = MemoryLayout<ElementCount>.size
      let elementCount = try messageReader.reading(byteCount: elementCountSize) { bytes in
         return ElementCount(bigEndian: bytes.loadUnaligned(as: elementCountType))
      }

      try self.init(decodingArrayFrom: &messageReader,
                    elementCount: elementCount,
                    extensionTypeIDToMetatype: extensionTypeIDToMetatype)
   }

   private init<ElementCount: UnsignedInteger>(
      decodingArrayFrom messageReader: inout MessageReader,
      elementCount: ElementCount,
      extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]
   ) throws {
      let elementCount = Int(elementCount)

      let array = DecodedMessagePackArray(minimumCapacity: elementCount)
      for _ in 0..<elementCount {
         let element = DecodedMessagePackValue(decodingWithSilentFailuresFrom: &messageReader,
                                               extensionTypeIDToMetatype: extensionTypeIDToMetatype)
         array.append(element)
      }

      self = .array(array)
   }

   private init<ElementCount>(
      decodingMapFrom messageReader: inout MessageReader,
      elementCountType: ElementCount.Type,
      extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]
   ) throws where ElementCount: UnsignedInteger & FixedWidthInteger {
      let elementCountSize = MemoryLayout<ElementCount>.size
      let elementCount = try messageReader.reading(byteCount: elementCountSize) { bytes in
         return ElementCount(bigEndian: bytes.loadUnaligned(as: elementCountType))
      }

      try self.init(decodingMapFrom: &messageReader,
                    elementCount: elementCount,
                    extensionTypeIDToMetatype: extensionTypeIDToMetatype)
   }

   private init<ElementCount: UnsignedInteger>(
      decodingMapFrom messageReader: inout MessageReader,
      elementCount: ElementCount,
      extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type]
   ) throws {
      let elementCount = Int(elementCount)

      var dictionary = [MessagePackKey: DecodedMessagePackValue](minimumCapacity: elementCount)
      var elementDecodeError: (any Error)?
      for _ in 0..<elementCount {
         let key = try DecodedMessagePackValue(decodingFrom: &messageReader,
                                               extensionTypeIDToMetatype: extensionTypeIDToMetatype)
         var messagePackKey: MessagePackKey?
         do {
            messagePackKey = try MessagePackKey(key)
         } catch {
            elementDecodeError = error
         }

         let value = DecodedMessagePackValue(decodingWithSilentFailuresFrom: &messageReader,
                                             extensionTypeIDToMetatype: extensionTypeIDToMetatype)

         guard let messagePackKey else {
            continue
         }

         if dictionary[messagePackKey] != nil {
            // TODO: Allow application to choose what to do in the case of duplicate keys.
            elementDecodeError = DecodingError.duplicateMapKey(messagePackKey)
            continue
         }
         dictionary[messagePackKey] = value
      }

      if let elementDecodeError {
         throw elementDecodeError
      }

      self = .map(dictionary)
   }

   private init<ByteCount>(
      decodingExtensionFrom messageReader: inout MessageReader,
      extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type],
      byteCountType: ByteCount.Type
   ) throws where ByteCount: UnsignedInteger & FixedWidthInteger {
      let byteCountSize = MemoryLayout<ByteCount>.size
      let extensionDataByteCount = try messageReader.reading(byteCount: byteCountSize) { bytes in
         return ByteCount(bigEndian: bytes.loadUnaligned(as: byteCountType))
      }

      try self.init(decodingExtensionFrom: &messageReader,
                    extensionTypeIDToMetatype: extensionTypeIDToMetatype,
                    extensionDataByteCount: extensionDataByteCount)
   }

   private init<ByteCount: UnsignedInteger>(decodingExtensionFrom messageReader: inout MessageReader,
                                            extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type],
                                            extensionDataByteCount: ByteCount) throws {
      let typeID = Int8(bitPattern: try messageReader.readByte())
      guard let type = extensionTypeIDToMetatype[typeID] else {
         let extensionData = try messageReader.read(byteCount: extensionDataByteCount)
         self = .unknownExtension(typeID, extensionData)
         return
      }

      let decodableAsExtension = try messageReader.reading(byteCount: extensionDataByteCount) { bytes in
         return try type.init(decoding: bytes)
      }

      if type == MessagePackTimestamp.self {
         self = .messagePackTimestamp(decodableAsExtension as! MessagePackTimestamp)
      } else {
         precondition(!PredefinedExtensions.typeIDRange.contains(typeID))

         self = .applicationSpecificExtension(decodableAsExtension)
      }
   }
}
