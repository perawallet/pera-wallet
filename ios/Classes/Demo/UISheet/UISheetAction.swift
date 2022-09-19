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

//   UISheetAction.swift

import Foundation

final class UISheetAction {
    let title: String
    let style: Style
    let handler: Handler
    
    init(
        title: String,
        style: Style,
        handler: @escaping Handler
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    typealias Handler = () -> Void
}

extension UISheetAction {
    enum Style {
        case `default`
        case cancel
    }
}
