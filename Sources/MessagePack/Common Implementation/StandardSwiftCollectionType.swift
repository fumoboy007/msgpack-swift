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

enum StandardSwiftCollectionType {
   case array(Any.Type)
   case set(Any.Type)
   case dictionary(Any.Type, Any.Type)

   init?(reflecting type: Any.Type) {
      // TODO: Replace the following implementation with calls to an official type metadata reflection API when Swift has one.

      guard let metadataRecord = StructMetadataRecord.from(type) else {
         return nil
      }

      if metadataRecord.pointee.isArray {
         let firstGenericArgumentType = metadataRecord.withMemoryRebound(to: StructMetadataRecordWithOneGenericArgument.self, capacity: 1) {
            return $0.pointee.firstGenericArgumentType
         }
         self = .array(firstGenericArgumentType)
      } else if metadataRecord.pointee.isSet {
         let firstGenericArgumentType = metadataRecord.withMemoryRebound(to: StructMetadataRecordWithOneGenericArgument.self, capacity: 1) {
            return $0.pointee.firstGenericArgumentType
         }
         self = .set(firstGenericArgumentType)
      } else if metadataRecord.pointee.isDictionary {
         let (firstGenericArgumentType, secondGenericArgumentType) = metadataRecord.withMemoryRebound(to: StructMetadataRecordWithTwoGenericArguments.self, capacity: 1) {
            return ($0.pointee.firstGenericArgumentType, $0.pointee.secondGenericArgumentType)
         }
         self = .dictionary(firstGenericArgumentType, secondGenericArgumentType)
      } else {
         return nil
      }
   }
}

private enum TypeMetadataRecordKind: UInt {
   // https://github.com/apple/swift/blob/b10560f3f662e112725856d8624d871e013dbb0a/include/swift/ABI/MetadataKind.def#L44
   case structMetadata = 0x200
}

private struct StructMetadataRecord {
   // https://github.com/apple/swift/blob/68e1ba0a84b9ff65c71e70bf24ab1009ba872680/include/swift/ABI/Metadata.h#L266
   let kind: UInt

   // https://github.com/apple/swift/blob/68e1ba0a84b9ff65c71e70bf24ab1009ba872680/include/swift/ABI/Metadata.h#L1283
   let nominalTypeDescriptor: UnsafeRawPointer

   static func from(_ type: Any.Type) -> UnsafePointer<StructMetadataRecord>? {
      let metadataRecordPointer = unsafeBitCast(type, to: UnsafeRawPointer.self)

      let metadataRecordKind = metadataRecordPointer.loadUnaligned(as: TypeMetadataRecordKind.RawValue.self)
      guard metadataRecordKind == TypeMetadataRecordKind.structMetadata.rawValue else {
         return nil
      }

      return metadataRecordPointer.bindMemory(to: StructMetadataRecord.self, capacity: 1)
   }

   private static let arrayNominalTypeDescriptor = Self.from(Array<Never>.self)!.pointee.nominalTypeDescriptor
   var isArray: Bool {
      return nominalTypeDescriptor == Self.arrayNominalTypeDescriptor
   }

   private static let setNominalTypeDescriptor = Self.from(Set<Never>.self)!.pointee.nominalTypeDescriptor
   var isSet: Bool {
      return nominalTypeDescriptor == Self.setNominalTypeDescriptor
   }

   private static let dictionaryNominalTypeDescriptor = Self.from(Dictionary<Never, Never>.self)!.pointee.nominalTypeDescriptor
   var isDictionary: Bool {
      return nominalTypeDescriptor == Self.dictionaryNominalTypeDescriptor
   }
}

private struct StructMetadataRecordWithOneGenericArgument {
   let record: StructMetadataRecord

   // https://github.com/apple/swift/blob/68e1ba0a84b9ff65c71e70bf24ab1009ba872680/include/swift/ABI/Metadata.h#L1366
   let firstGenericArgumentType: Any.Type
}

private struct StructMetadataRecordWithTwoGenericArguments {
   let record: StructMetadataRecord

   // https://github.com/apple/swift/blob/68e1ba0a84b9ff65c71e70bf24ab1009ba872680/include/swift/ABI/Metadata.h#L1366
   let firstGenericArgumentType: Any.Type
   let secondGenericArgumentType: Any.Type
}
