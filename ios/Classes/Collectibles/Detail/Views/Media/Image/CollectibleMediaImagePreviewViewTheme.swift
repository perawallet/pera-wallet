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

//   CollectibleMediaImagePreviewViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage

struct CollectibleMediaImagePreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    let image: URLImageViewStyleSheet
    let overlay: ViewStyle
    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        self.image = CollectibleDetailImageTheme()
        self.overlay = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        
        self.corner = Corner(radius: 4)
    }
}

struct CollectibleDetailImageTheme: URLImageViewStyleSheet {
    struct PlaceholderTheme: URLImagePlaceholderViewStyleSheet {
        let background: ViewStyle
        let image: ImageStyle
        let text: TextStyle

        init() {
            self.background = [
                .backgroundColor(AppColors.Shared.Layer.grayLighter)
            ]
            self.image = []
            self.text = [
                .textColor(AppColors.Components.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }

    let background: ViewStyle
    let content: ImageStyle
    let placeholder: URLImagePlaceholderViewStyleSheet?

    init() {
        self.background = []
        self.content = .aspectFit()
        self.placeholder = PlaceholderTheme()
    }
}
