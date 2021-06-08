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
//   VerificationStatusView.swift

import UIKit

class VerificationStatusView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var loadingView = LoadingSpinnerView()

    private lazy var imageView = UIImageView()

    private lazy var statusLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withLine(.single)
            .withAlignment(.left)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
        loadingView.updateColor(to: Colors.Main.yellow600)
    }

    override func prepareLayout() {
        setupLoadingViewLayout()
        setupImageViewLayout()
        setupStatusLabelLayout()
    }
}

extension VerificationStatusView {
    private func setupLoadingViewLayout() {
        addSubview(loadingView)

        loadingView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }

    private func setupImageViewLayout() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupStatusLabelLayout() {
        addSubview(statusLabel)

        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(loadingView)
            make.leading.equalTo(loadingView.snp.trailing).offset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension VerificationStatusView {
    func showLoading() {
        loadingView.show()
    }

    func stopLoading() {
        loadingView.stop()
    }
}

extension VerificationStatusView {
    func bind(_ viewModel: VerificationStatusViewModel) {
        loadingView.isHidden = !viewModel.isWaitingForVerification

        if viewModel.isWaitingForVerification {
            loadingView.show()
        } else {
            loadingView.stop()
        }

        imageView.isHidden = viewModel.isStatusImageHidden
        imageView.image = viewModel.statusImage
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.statusColor
    }
}

extension VerificationStatusView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset = 16.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
