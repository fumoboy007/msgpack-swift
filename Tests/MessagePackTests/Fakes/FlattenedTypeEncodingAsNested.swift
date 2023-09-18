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

struct FlattenedTypeEncodingAsNested: Equatable {
   var outerTypeProperty: String
   var innerTypeProperty: String
}

extension FlattenedTypeEncodingAsNested: Codable {
   enum OuterTypeCodingKeys: String, CodingKey {
      case outerTypeProperty
      case innerType
   }

   enum InnerTypeCodingKeys: String, CodingKey {
      case innerTypeProperty
   }

   init(from decoder: Decoder) throws {
      let outerContainer = try decoder.container(keyedBy: OuterTypeCodingKeys.self)
      self.outerTypeProperty = try outerContainer.decode(String.self, forKey: .outerTypeProperty)

      let innerContainer = try outerContainer.nestedContainer(keyedBy: InnerTypeCodingKeys.self, forKey: .innerType)
      self.innerTypeProperty = try innerContainer.decode(String.self, forKey: .innerTypeProperty)
   }

   func encode(to encoder: Encoder) throws {
      var outerContainer = encoder.container(keyedBy: OuterTypeCodingKeys.self)
      try outerContainer.encode(outerTypeProperty, forKey: .outerTypeProperty)

      var innerContainer = outerContainer.nestedContainer(keyedBy: InnerTypeCodingKeys.self, forKey: .innerType)
      try innerContainer.encode(innerTypeProperty, forKey: .innerTypeProperty)
   }
}
