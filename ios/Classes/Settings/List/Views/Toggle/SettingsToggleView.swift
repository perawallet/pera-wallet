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
//   SettingsToggleView.swift

import UIKit
import MacaroonUIKit

final class SettingsToggleView: View {
    weak var delegate: SettingsToggleContextViewDelegate?
    
    private lazy var theme = SettingsToggleViewTheme()
    
    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var toggle = Toggle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func setListeners() {
        toggle.addTarget(self, action: #selector(didChangeToggle(_:)), for: .touchUpInside)
    }
    
    func customize(_ theme: SettingsToggleViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addImageView()
        addNameLabel()
        addToggle()
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension SettingsToggleView {
    @objc
    private func didChangeToggle(_ toggle: Toggle) {
        delegate?.settingsToggleView(self, didChangeValue: toggle.isOn)
    }
}

extension SettingsToggleView {
    private func addImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addNameLabel() {
        nameLabel.customizeAppearance(theme.name)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.nameOffset)
        }
    }
    
    private func addToggle() {
        toggle.customize(theme.toggle)

        addSubview(toggle)
        toggle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension SettingsToggleView {
    func bindData(_ viewModel: SettingsToggleViewModel) {
        imageView.image = viewModel.image
        nameLabel.text = viewModel.title
        toggle.setOn(viewModel.isOn, animated: false)
    }
    
    func setToggleOn(_ isOn: Bool, animated: Bool) {
        toggle.setOn(isOn, animated: animated)
    }
    
    var isToggleOn: Bool {
        return toggle.isOn
    }
}

protocol SettingsToggleContextViewDelegate: AnyObject {
    func settingsToggleView(_ settingsToggleView: SettingsToggleView, didChangeValue value: Bool)
}
