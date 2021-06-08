// Copyright 2019 Algorand, Inc.

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
//  Optional+Nil.swift

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let strongSelf = self else {
            return true
        }
        return strongSelf.isEmptyOrBlank
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var nonEmpty: Wrapped? {
        isNilOrEmpty ? nil : self
    }
}

extension Optional {
    func unwrap(or someValue: Wrapped) -> Wrapped {
        return self ?? someValue
    }

    func unwrap<T>(either transform: (Wrapped) -> T, or someValue: T) -> T {
        return map(transform) ?? someValue
    }

    func unwrap<T>(either keyPath: KeyPath<Wrapped, T>, or someValue: T) -> T {
        return unwrap(either: { $0[keyPath: keyPath] }, or: someValue)
    }

    func unwrap<T>(either keyPath: KeyPath<Wrapped, T?>, or someValue: T) -> T {
        return unwrap(either: { $0[keyPath: keyPath] ?? someValue }, or: someValue)
    }

    func unwrapIfPresent<T>(either transform: (Wrapped) -> T, or someValue: T? = nil) -> T? {
        return map(transform) ?? someValue
    }

    func unwrapIfPresent<T>(either transform: (Wrapped) -> T?, or someValue: T? = nil) -> T? {
        return map(transform) ?? someValue
    }

    func unwrapConditionally(where predicate: (Wrapped) -> Bool) -> Wrapped? {
        return unwrap(either: { predicate($0) ? $0 : nil }, or: nil)
    }
}

extension Optional {
    func `continue`(ifPresent operation: (Wrapped) -> Void, else elseOperation: (() -> Void)? = nil) {
        if let value = self {
            operation(value)
        } else {
            elseOperation?()
        }
    }
}
