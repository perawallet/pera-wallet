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
//  TitledToggleView.swift

import UIKit
import MacaroonUIKit

final class TitledToggleView: View {
    var isOn: Bool {
        get {
            toggleView.isOn
        }
        set {
            toggleView.setOn(newValue, animated: true)
        }
    }

    weak var delegate: TitledToggleViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var toggleView = Toggle()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(_ theme: TitledToggleViewTheme) {
        addToggleView(theme)
        addTitleLabel(theme)
    }

    func setListeners() {
        toggleView.addTarget(self, action: #selector(notifyDelegateToToggleValueChanged), for: .valueChanged)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension TitledToggleView {
    @objc
    private func notifyDelegateToToggleValueChanged() {
        delegate?.titledToggleView(self, didChangeToggleValue: toggleView.isOn)
    }
}

extension TitledToggleView {
    private func addToggleView(_ theme: TitledToggleViewTheme) {
        toggleView.customize(theme.toggle)

        addSubview(toggleView)
        toggleView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: TitledToggleViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(toggleView.snp.leading).offset(-theme.horizontalPadding)
        }
    }
}

protocol TitledToggleViewDelegate: AnyObject {
    func titledToggleView(_ titledToggleView: TitledToggleView, didChangeToggleValue value: Bool)
}
