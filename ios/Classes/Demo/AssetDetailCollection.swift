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
//   AssetDetailCollection.swift


import Foundation
import MacaroonUtils

struct AssetDetailCollection:
    Collection,
    ExpressibleByArrayLiteral,
    Printable {
    typealias Key = AssetID
    typealias Index = AssetDetailCollectionIndex
    typealias Element = AssetDecoration
    
    fileprivate typealias Table = [Key: Element]

    var startIndex: Index {
        return Index(table.startIndex)
    }
    var endIndex: Index {
        return Index(table.endIndex)
    }
    
    var debugDescription: String {
        return table.debugDescription
    }
    
    @Atomic(identifier: "assetDetailCollection.table")
    private var table = Table()
    
    init(
        _ collection: AssetDetailCollection
    ) {
        $table.mutate { $0 = collection.table }
    }
    
    init(
        _ elements: [Element]
    ) {
        let keysAndValues = elements.map { ($0.id, $0) }
        let aTable = Table(keysAndValues, uniquingKeysWith: { $1 })
        $table.mutate { $0 = aTable }
    }

    init(
        arrayLiteral elements: Element...
    ) {
        self.init(elements)
    }
}

extension AssetDetailCollection {
    subscript (position: Index) -> Element {
        return table[position.wrapped].value
    }
    
    subscript (key: Key) -> Element? {
        get { table[key] }
        set { $table.mutate { $0[key] = newValue } }
    }
}

extension AssetDetailCollection {
    func index(
        after i: Index
    ) -> Index {
        return Index(table.index(after: i.wrapped))
    }
}

struct AssetDetailCollectionIndex: Comparable {
    fileprivate typealias InternalIndex = AssetDetailCollection.Table.Index
    
    fileprivate let wrapped: InternalIndex
    
    fileprivate init(
        _ wrapped: InternalIndex
    ) {
        self.wrapped = wrapped
    }
    
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.wrapped == rhs.wrapped
    }

    static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return  lhs.wrapped < rhs.wrapped
    }
}
