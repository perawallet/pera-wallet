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
//  TestNetTitleView.swift

import UIKit
import MacaroonUIKit

final class TestNetTitleView: View {
    private lazy var titleLabel = Label()
    private lazy var testNetLabel = Label()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    func customize(_ theme: TestNetTitleViewTheme) {
        addTitleLabel(theme)
        addTestNetLabel(theme)
    }

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: ViewStyle
    ) {}
}

extension TestNetTitleView {
    private func addTitleLabel(_ theme: TestNetTitleViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)
        titleLabel.contentEdgeInsets = (0, 0 , 0, 8)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
        }
    }

    private func addTestNetLabel(_ theme: TestNetTitleViewTheme) {
        testNetLabel.customizeAppearance(theme.testNetLabel)
        testNetLabel.draw(corner: theme.testNetLabelCorner)

        addSubview(testNetLabel)
        testNetLabel.snp.makeConstraints {
            $0.leading == titleLabel.snp.trailing
            $0.trailing == 0
            $0.top == 0
            $0.bottom == 0
            $0.fitToSize(theme.testNetLabelSize)
        }
    }
}
