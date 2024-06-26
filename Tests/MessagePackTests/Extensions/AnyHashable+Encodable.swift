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

// This retroactive conformance of the external `AnyHashable` type should be safe.
//
// First, the conformance does not make much sense in general since it is not
// guaranteed that the base value is `Encodable`, so it is unlikely that the Swift
// standard library would add the conformance.
//
// Second, even if the standard library did add the conformance, the implementation
// would be similar.
//
// TODO: Replace `Swift.Encodable` with `@retroactive Encodable` when the minimum
// Swift version has been increased to version 6.
extension AnyHashable: Swift.Encodable {
   private enum EncodeError: Error {
      case baseNotEncodable(Any.Type)
   }

   public func encode(to encoder: Encoder) throws {
      guard let base = base as? any Encodable else {
         throw EncodeError.baseNotEncodable(type(of: base))
      }

      try base.encode(to: encoder)
   }
}
