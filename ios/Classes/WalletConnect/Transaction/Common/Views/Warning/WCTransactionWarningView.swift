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
//   WCTransactionWarningView.swift

import UIKit

final class WCTransactionWarningView: BaseView {
    private let layout = Layout<LayoutConstants>()

    private lazy var imageView = UIImageView(image: img("icon-red-warning"))

    private lazy var warningLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(Colors.Helpers.negative.uiColor)
            .withFont(Fonts.DMSans.medium.make(13).uiFont)
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Helpers.negativeLighter.uiColor
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupImageViewLayout()
        setupWarningLabelLayout()
    }
}

extension WCTransactionWarningView {
    private func setupImageViewLayout() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupWarningLabelLayout() {
        addSubview(warningLabel)

        warningLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.warningLabelInset)
            make.top.bottom.equalToSuperview().inset(layout.current.warningLabelInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension WCTransactionWarningView {
    func bind(_ viewModel: WCTransactionWarningViewModel) {
        warningLabel.text = viewModel.title
    }
}

extension WCTransactionWarningView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 16.0
        let warningLabelInset: CGFloat = 12.0
    }
}
