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

//   SendCollectibleViewController+Layout.swift

import Foundation
import CoreGraphics
import MacaroonUIKit

extension SendCollectibleViewController {
    func addBackground() {
        backgroundStartStyle = theme.backgroundStart
        backgroundEndStyle = theme.backgroundEnd

        updateBackground(for: .start)
    }

    func addContext()  {
        sendCollectibleView.customize(theme.sendCollectibleViewTheme)

        contentView.addSubview(sendCollectibleView)
        sendCollectibleView.snp.makeConstraints {
            $0.top <= view.safeAreaLayoutGuide.snp.top
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }
    }
}

extension SendCollectibleViewController {
    func updateImageBeforeAnimations(
        for layout: ImageLayout
    ) {
        switch layout {
        case .initial:
            let imageHorizontalPaddings = 2 * theme.horizontalPadding
            let initialImageHeight = sendCollectibleView.contextViewContainer.frame.width - imageHorizontalPaddings
            let currentImageHeight = imageView.frame.height

            let isUpdateNeeded = currentImageHeight != initialImageHeight

            guard isUpdateNeeded else {
                return
            }

            imageView.snp.remakeConstraints {
                $0.centerX == 0
                $0.top == 0
                $0.leading == theme.horizontalPadding
                $0.trailing == theme.horizontalPadding
                $0.height == imageView.snp.width
            }
        case .custom(let height):
            imageView.snp.remakeConstraints {
                $0.centerX == 0
                $0.top == 0
                $0.leading >= theme.horizontalPadding
                $0.trailing <= theme.horizontalPadding
                $0.fitToSize(
                    (
                        height,
                        height
                    )
                )
            }
        }
    }
}

extension SendCollectibleViewController {
    func updateAlongsideAnimations(
        for position: SendCollectibleActionView.Position
    ) {
        updateBackground(for: position)
        sendCollectibleActionView.updateContentAlongsideAnimations(for: position)
    }
}

extension SendCollectibleViewController {
    enum ImageLayout {
        case initial
        case custom(height: CGFloat)
    }
}
