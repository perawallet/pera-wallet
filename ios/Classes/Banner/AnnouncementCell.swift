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

//   AnnouncementCell.swift

import Foundation
import MacaroonUIKit
import UIKit

class AnnouncementCell:
    CollectionCell<AnnouncementView>,
    ViewModelBindable,
    UIInteractable {
    private lazy var topBackgroundView = UIView()

    override class var contextPaddings: LayoutPaddings {
        return (0, 24, 0, 24)
    }

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        addTopBackgroundView()
    }
}

extension AnnouncementCell {
    private func addTopBackgroundView() {
        topBackgroundView.backgroundColor = Colors.Helpers.heroBackground.uiColor

        contentView.insertSubview(
            topBackgroundView,
            at: 0
        )
        topBackgroundView.snp.makeConstraints {
            $0.matchToHeight(
                of: contentView,
                multiplier: 0.5
            )
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }
}

final class GenericAnnouncementCell: AnnouncementCell {
    static let theme = GenericAnnouncementViewTheme()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
    }
}

final class GovernanceAnnouncementCell: AnnouncementCell {
    static let theme = GovernanceAnnouncementViewTheme()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
    }
}
