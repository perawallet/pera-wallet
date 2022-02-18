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
//   AnnouncementBannerView.swift

import UIKit
import MacaroonUIKit

final class AnnouncementBannerView: View {
    private lazy var containerView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var dismissButton = UIButton()
    private lazy var outerImageView = UIImageView()
    private lazy var innerImageView = UIImageView()

    func customize(_ theme: AnnouncementBannerViewTheme) {
        addContainerView(theme)
        addOuterImageView(theme)
        addInnerImageView(theme)
        addDismissButton(theme)
        addTitleLabel(theme)
        addDetailLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension AnnouncementBannerView {
    private func addContainerView(_ theme: AnnouncementBannerViewTheme) {
        containerView.customizeAppearance(theme.container)

        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addOuterImageView(_ theme: AnnouncementBannerViewTheme) {
        outerImageView.customizeAppearance(theme.outerImage)

        containerView.addSubview(outerImageView)
        outerImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(theme.outerImageSize))
            $0.trailing.equalToSuperview().inset(theme.imageTrailingPadding)
            $0.top.bottom.equalToSuperview().inset(theme.imageVerticalPadding)
        }
    }

    private func addInnerImageView(_ theme: AnnouncementBannerViewTheme) {
        innerImageView.customizeAppearance(theme.innerImage)

        outerImageView.addSubview(innerImageView)
        innerImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(theme.innerImageSize))
            $0.center.equalToSuperview()
        }
    }

    private func addDismissButton(_ theme: AnnouncementBannerViewTheme) {
        dismissButton.customizeAppearance(theme.dismiss)

        containerView.addSubview(dismissButton)
        dismissButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(theme.dismissButtonSize))
            $0.top.trailing.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: AnnouncementBannerViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.titleHorizontalPadding)
            $0.trailing.equalTo(outerImageView.snp.leading).offset(-theme.titleHorizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addDetailLabel(_ theme: AnnouncementBannerViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        containerView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(outerImageView.snp.leading).offset(-theme.titleHorizontalPadding)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.detailTopPadding)
            $0.bottom.equalToSuperview().inset(theme.detailBottomPadding)
        }
    }
}

extension AnnouncementBannerView: ViewModelBindable {
    func bindData(_ viewModel: AnnouncementBannerViewModel?) {

    }
}

final class AnnouncementBannerCell: BaseCollectionViewCell<AnnouncementBannerView> {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.customize(AnnouncementBannerViewTheme())
    }

    func bindData(_ viewModel: AnnouncementBannerViewModel?) {

    }
}
