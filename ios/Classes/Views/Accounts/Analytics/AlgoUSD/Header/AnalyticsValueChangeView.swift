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
//   AnalyticsValueChangeView.swift

import UIKit

class AnalyticsValueChangeView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var changeImageView = UIImageView()

    private lazy var changeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withLine(.single)
            .withAlignment(.left)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupChangeImageViewLayout()
        setupChangeLabelLayout()
    }
}

extension AnalyticsValueChangeView {
    private func setupChangeImageViewLayout() {
        addSubview(changeImageView)

        changeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupChangeLabelLayout() {
        addSubview(changeLabel)

        changeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(changeImageView.snp.trailing).offset(layout.current.horizontalInset)
            make.centerY.equalTo(changeImageView)
        }
    }
}

extension AnalyticsValueChangeView {
    func bind(_ viewModel: AnalyticsValueChangeViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        
        changeImageView.image = viewModel.image
        changeLabel.textColor = viewModel.valueColor
        changeLabel.text = viewModel.value
    }
}

extension AnalyticsValueChangeView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let horizontalInset: CGFloat = 2.0
    }
}
