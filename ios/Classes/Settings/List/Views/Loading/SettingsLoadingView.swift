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

//   SettingsLoadingView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SettingsLoadingView: View {
    private lazy var theme = SettingsLoadingViewTheme()

    private lazy var imageView = UIImageView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var loadingView = LoadingView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: SettingsLoadingViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImage()
        addTitle()
        addLoading()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }

    func startAnimating() {
        loadingView.startAnimating()
    }

    func stopAnimating() {
        loadingView.stopAnimating()
    }
}

extension SettingsLoadingView {
    private func addImage() {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addTitle() {
        titleView.customize(theme.title)
        addSubview(titleView)

        titleView.snp.makeConstraints {
            $0.top == theme.titleInset
            $0.bottom == theme.titleInset
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.titleOffset)
        }
    }

    private func addLoading() {
        loadingView.customize(theme)
        addSubview(loadingView)

        loadingView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension SettingsLoadingView {
    func bindData(_ viewModel: SettingsDetailViewModel) {
        titleView.bindData(viewModel)
        viewModel.image?.load(in: imageView)
    }
}
