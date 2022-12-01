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

//   Alert.swift

import Foundation
import MacaroonUIKit

final class Alert {
    let image: Image?
    let isNewBadgeVisible: Bool
    let title: TextProvider?
    let body: TextProvider?

    let theme: AlertScreenTheme

    private(set) var actions: [AlertAction] = []

    init(
        image: Image?,
        isNewBadgeVisible: Bool = false,
        title: TextProvider?,
        body: TextProvider?,
        theme: AlertScreenTheme = AlertScreenCommonTheme()
    ) {
        self.image = image
        self.isNewBadgeVisible = isNewBadgeVisible
        self.title = title
        self.body = body
        self.theme = theme
    }

    func addAction(
        _ action: AlertAction
    ) {
        actions.append(action)
    }
}
