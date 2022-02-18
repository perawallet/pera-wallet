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
//   Array+View.swift

import UIKit

extension Array where Element: UIView {
    func previousView(of view: Element) -> UIView? {
        if isFirstView(view) {
            return nil
        }

        guard let index = index(of: view) else {
            return nil
        }

        let previousViewIndex = index - 1
        return self[safe: previousViewIndex]
    }

    func nextView(of view: Element) -> UIView? {
        if isLastView(view) {
            return nil
        }

        guard let index = index(of: view) else {
            return nil
        }

        let nextViewIndex = index + 1
        return self[safe: nextViewIndex]
    }

    func isFirstView(_ view: UIView) -> Bool {
        return first == view
    }

    func isLastView(_ view: UIView) -> Bool {
        return last == view
    }

    func index(of view: Element) -> Int? {
        return firstIndex(of: view)
    }
}
