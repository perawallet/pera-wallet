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
//   BannerViewErrorStyleSheet.swift

import Foundation
import Macaroon
import UIKit

struct BannerViewErrorStyleSheet: BannerViewStyleSheet {
    let title: TextStyle
    let background: ViewStyle
    let backgroundShadow: Macaroon.Shadow?
    let message: TextStyle?
    let icon: ImageStyle?

    private let textColor = Colors.ButtonText.primary

    init() {
        self.title = [
            .font(UIFont.font(withWeight: .semiBold(size: 16.0))),
            .textAlignment(.left),
            .textOverflow(.fitting),
            .textColor(textColor)
        ]
        self.background = []
        self.backgroundShadow =
            Macaroon.Shadow(
                color: Colors.Shadow.error,
                opacity: 1.0,
                offset: (0, 8),
                radius: 6,
                fillColor: Colors.General.error,
                cornerRadii: (12, 12),
                corners: .allCorners
            )
        self.message = [
            .font(UIFont.font(withWeight: .regular(size: 14.0))),
            .textAlignment(.left),
            .textOverflow(.fitting),
            .textColor(textColor)
        ]
        self.icon = [
            .contentMode(.scaleAspectFill)
        ]
    }
}
