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

import MessagePack
import XCTest

// MARK: - Test Models

/// A type that decodes a String through the generic `Decodable` path (`compoundValue` +
/// `reuseNestedDecoder`) rather than the specific `String` overload (`simpleValue`).
/// This mimics what happens when `KeyedDecodingContainer.decode(T.self, forKey:)` is called
/// with a generic `T: Decodable` that happens to be `String` at runtime — the compiler
/// dispatches to the generic overload.
private struct GenericStringField: Codable, Equatable {
   let value: String

   init(_ value: String) { self.value = value }

   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      value = try container.decode(String.self)
   }

   func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(value)
   }
}

/// A leaf struct decoded via keyed container at the deepest nesting level.
private struct Leaf: Codable, Equatable {
   let field: String
}

/// Mimics the real-world crash pattern: a keyed container that first decodes an Optional
/// compound type (which forces the singleValue → `compoundValue(for: nil)` path, shrinking
/// the reusable decoder's codingPath), then decodes a field through the generic Decodable
/// path at the same nesting level.
///
/// The custom `init(from:)` uses a helper method that forces generic dispatch, ensuring
/// String fields go through `compoundValue` → `reuseNestedDecoder` rather than `simpleValue`.
private struct ItemWithGenericDecode: Equatable {
   let optionalLeaf: Leaf?
   let name: String
}

extension ItemWithGenericDecode: Codable {
   private enum CodingKeys: String, CodingKey {
      case optionalLeaf, name
   }

   /// Decode an optional value through the generic Decodable path, forcing
   /// `compoundValue` + `reuseNestedDecoder`. This is equivalent to what
   /// `decodePermissive<T: Decodable>` does in production code — the generic type
   /// parameter causes Swift to dispatch to the generic `decode<T>` overload rather
   /// than the type-specific overload, which goes through `compoundValue`.
   private static func decodeIfPresentGeneric<T: Decodable>(
      _ type: T.Type,
      from container: KeyedDecodingContainer<CodingKeys>,
      forKey key: CodingKeys
   ) throws -> T? {
      return try container.decodeIfPresent(type, forKey: key)
   }

   private static func decodeGeneric<T: Decodable>(
      _ type: T.Type,
      from container: KeyedDecodingContainer<CodingKeys>,
      forKey key: CodingKeys
   ) throws -> T {
      return try container.decode(type, forKey: key)
   }

   init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      // This decodes Optional<Leaf> via the generic path:
      // 1. compoundValue(Leaf, .optionalLeaf) → reuseNestedDecoder(for: .optionalLeaf) → decoder H
      // 2. Leaf.init(from: H) → keyed container → decode fields
      // The generic dispatch ensures this goes through compoundValue, not simpleValue.
      optionalLeaf = try Self.decodeIfPresentGeneric(Leaf.self, from: container, forKey: .optionalLeaf)

      // This decodes String via the generic path:
      // compoundValue(String, .name) → reuseNestedDecoder(for: .name)
      // Reuses the same nested decoder that was used by optionalLeaf above
      name = try Self.decodeGeneric(String.self, from: container, forKey: .name)
   }
}

/// A deeply nested structure that mimics the real crash:
/// Page → [PageValue] → Order → OrderData → [Item] → Item → fields
/// Each level of nesting increases the codingPath depth. The reusable decoder chain
/// gets deeper with each level, and the nil-key shrinkage at a deep level can cause
/// a mismatch when the chain is reused across array elements.
private struct Page: Codable, Equatable {
   let values: [PageValue]
}

private struct PageValue: Codable, Equatable {
   let order: Order
}

private struct Order: Codable, Equatable {
   let data: OrderData?
}

private struct OrderData: Equatable {
   let items: [ItemWithGenericDecode]
}

extension OrderData: Codable {
   private enum CodingKeys: String, CodingKey {
      case items
   }

   init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      items = try container.decodeIfPresent([ItemWithGenericDecode].self, forKey: .items) ?? []
   }
}

// MARK: - Tests

/// Tests that the nested decoder reuse optimization handles codingPath depth mismatches
/// without crashing.
///
/// Regression test for: "Fatal error: Range requires lowerBound <= upperBound"
/// in `MessagePackValueToSwiftValueDecoder.reset()` when `codingPath.replaceSubrange(index...)`
/// is called with an index exceeding the reused decoder's codingPath.count.
class NestedDecoderReuseCodingPathTests: XCTestCase {

   /// Tests decoding an array of items where each item has an optional compound field
   /// followed by a string decoded through the generic Decodable path.
   func testNestedDecoderReuse_acrossArrayElements() throws {
      let encoder = MessagePackEncoder()
      let decoder = MessagePackDecoder()

      let original = [
         ItemWithGenericDecode(optionalLeaf: Leaf(field: "a"), name: "first"),
         ItemWithGenericDecode(optionalLeaf: Leaf(field: "b"), name: "second"),
         ItemWithGenericDecode(optionalLeaf: nil, name: "third"),
         ItemWithGenericDecode(optionalLeaf: Leaf(field: "c"), name: "fourth"),
      ]

      let data = try encoder.encode(original)
      let decoded = try decoder.decode([ItemWithGenericDecode].self, from: data)

      XCTAssertEqual(decoded, original)
   }

   /// Tests the deeply nested decode chain that mirrors the real-world crash:
   /// Page → [PageValue] → Order → OrderData → [Item] → Item → Optional<Leaf> + String
   ///
   /// This creates a reusable decoder chain 7+ levels deep. The Optional<Leaf> decode
   /// at the deepest level uses singleValue → compoundValue(for: nil), which can shrink
   /// a cached decoder's codingPath. When the array iterates to the next item, the
   /// reused decoder chain encounters the depth mismatch.
   func testNestedDecoderReuse_deepChainWithOptionalCompound() throws {
      let encoder = MessagePackEncoder()
      let decoder = MessagePackDecoder()

      let original = Page(values: [
         PageValue(order: Order(data: OrderData(items: [
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "deep1"), name: "alpha"),
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "deep2"), name: "beta"),
         ]))),
         PageValue(order: Order(data: OrderData(items: [
            ItemWithGenericDecode(optionalLeaf: nil, name: "gamma"),
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "deep3"), name: "delta"),
         ]))),
      ])

      let data = try encoder.encode(original)
      let decoded = try decoder.decode(Page.self, from: data)

      XCTAssertEqual(decoded, original)
   }

   /// Tests that mixed nil/non-nil optional compound fields across array elements don't
   /// cause depth mismatches in the reusable decoder chain.
   func testNestedDecoderReuse_mixedPresenceAcrossPages() throws {
      let encoder = MessagePackEncoder()
      let decoder = MessagePackDecoder()

      let original = Page(values: [
         PageValue(order: Order(data: OrderData(items: [
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "x"), name: "one"),
         ]))),
         PageValue(order: Order(data: nil)),
         PageValue(order: Order(data: OrderData(items: [
            ItemWithGenericDecode(optionalLeaf: nil, name: "two"),
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "y"), name: "three"),
            ItemWithGenericDecode(optionalLeaf: Leaf(field: "z"), name: "four"),
         ]))),
      ])

      let data = try encoder.encode(original)
      let decoded = try decoder.decode(Page.self, from: data)

      XCTAssertEqual(decoded, original)
   }

   /// Tests GenericStringField which forces String through compoundValue → reuseNestedDecoder,
   /// verifying the decoder reuse works for types that wrap simple values in a Decodable shell.
   func testNestedDecoderReuse_genericStringInArray() throws {
      let encoder = MessagePackEncoder()
      let decoder = MessagePackDecoder()

      let original = [
         GenericStringField("hello"),
         GenericStringField("world"),
         GenericStringField("test"),
      ]

      let data = try encoder.encode(original)
      let decoded = try decoder.decode([GenericStringField].self, from: data)

      XCTAssertEqual(decoded, original)
   }
}
