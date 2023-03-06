// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Array+Additions.swift

import Foundation

extension Array {
    var isNonEmpty: Bool {
        return !isEmpty
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array {
    public var firstIndex: Index? {
        return isEmpty ? nil : startIndex
    }

    public func firstIndex<T: Equatable>(of other: Element?, equals keyPath: KeyPath<Element, T>) -> Index? {
        if let other = other {
            return firstIndex { $0[keyPath: keyPath] == other[keyPath: keyPath] }
        }
        return nil
    }

    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (>)
    ) -> [Element] {
        return sorted { first, second in
            comparator(first[keyPath: keyPath], second[keyPath: keyPath])
        }
    }

    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T?>,
        using comparator: (T, T) -> Bool = (>)
    ) -> [Element] {
        return sorted { first, second in
            guard let firstValue = first[keyPath: keyPath], let secondValue = second[keyPath: keyPath] else {
                return false
            }

            return comparator(firstValue, secondValue)
        }
    }
}

extension Array {
    subscript (safe index: Index?) -> Element? {
        if let index = index, indices.contains(index) {
            return self[index]
        }
        return nil
    }

    func previousElement(beforeElementAt i: Index) -> Element? {
        return i > startIndex ? self[index(before: i)] : nil
    }

    func nextElement(afterElementAt i: Index) -> Element? {
        return i < index(before: endIndex) ? self[index(after: i)] : nil
    }
}

/// <todo>
/// Move it to `MacaroonUtils` later
extension Array {
    func chunked(
        by size: Int
    ) -> [[Element]] {
            return stride(
                from: startIndex,
                to: endIndex,
                by: size
            ).map {
                let lastIndex =
                    index(
                        $0,
                        offsetBy: size,
                        limitedBy: endIndex
                    ) ?? endIndex
                return Array(self[$0 ..< lastIndex])
            }
        }
}

extension Array where Element == Data? {
    func findEmptyElementIndexes() -> [Index] {
        var indexes = [Index]()

        for (index, item) in enumerated() where item == nil || item?.count == 0 {
            indexes.append(index)
        }

        return indexes
    }
}
