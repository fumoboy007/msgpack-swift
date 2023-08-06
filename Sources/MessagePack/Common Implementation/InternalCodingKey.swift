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

enum InternalCodingKey {
   case string(String)
   case int(Int)
   case arrayIndex(Int)

   static let `super` = Self.string("super")
}

extension InternalCodingKey: CodingKey {
   var stringValue: String {
      switch self {
      case .string(let value):
         return value

      case .int(let value):
         return "\(value)"

      case .arrayIndex(let index):
         return "Index \(index)"
      }
   }

   var intValue: Int? {
      switch self {
      case .string:
         return nil

      case .int(let value),
            .arrayIndex(let value):
         return value
      }
   }

   init?(stringValue: String) {
      self = .string(stringValue)
   }

   init?(intValue: Int) {
      self = .int(intValue)
   }
}
