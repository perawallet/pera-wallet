// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleMediaAudioPreviewViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleMediaAudioPreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    let placeholder: URLImagePlaceholderViewLayoutSheet & URLImagePlaceholderViewStyleSheet
    let audioPlayingState: ImageStyle
    let corner: Corner
    
    init(_ family: LayoutFamily) {
        self.placeholder =  PlaceholderViewTheme()
        self.audioPlayingState = [
            .image("audio-playing-state-icon"),
            .contentMode(.center),
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.corner = Corner(radius: 12)
    }
}

extension CollectibleMediaAudioPreviewViewTheme {
    struct PlaceholderViewTheme:
        URLImagePlaceholderViewLayoutSheet,
        URLImagePlaceholderViewStyleSheet {
        var textPaddings: LayoutPaddings
        var background: ViewStyle
        var image: ImageStyle
        var text: TextStyle

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (8, 8, 8, 8)
            background = [
                .backgroundColor(Colors.Layer.grayLighter)
            ]
            image = []
            text = [
                .textColor(Colors.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }
}
