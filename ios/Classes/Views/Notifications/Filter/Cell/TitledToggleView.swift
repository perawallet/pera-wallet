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
//  TitledToggleView.swift

import UIKit

class TitledToggleView: BaseView {

    weak var delegate: TitledToggleViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("notification-filter-show-title".localized)
    }()
    
    private lazy var toggleView = Toggle()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        toggleView.addTarget(self, action: #selector(notifyDelegateToToggleValueChanged), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupToggleViewLayout()
        setupTitleLabelLayout()
    }
}

extension TitledToggleView {
    @objc
    private func notifyDelegateToToggleValueChanged() {
        delegate?.titledToggleView(self, didChangeToggleValue: toggleView.isOn)
    }
}

extension TitledToggleView {
    private func setupToggleViewLayout() {
        addSubview(toggleView)

        toggleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(toggleView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }
}

extension TitledToggleView {
    func bind(_ viewModel: TitledToggleViewModel) {
        titleLabel.text = viewModel.title
        toggleView.setOn(viewModel.isSelected, animated: true)
    }
}

extension TitledToggleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

protocol TitledToggleViewDelegate: AnyObject {
    func titledToggleView(_ titledToggleView: TitledToggleView, didChangeToggleValue value: Bool)
}
