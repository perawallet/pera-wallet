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
//  SettingsFooterView.swift

import UIKit

class SettingsFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SettingsFooterViewDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
            .withTitle("settings-logout-title".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withBackgroundColor(Colors.Background.secondary)
        button.layer.cornerRadius = 22.0
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "settings-app-version".localized(params: version)
        }
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
        if !isDarkModeDisplay {
            logoutButton.applySmallShadow()
        }
    }
    
    override func setListeners() {
        logoutButton.addTarget(self, action: #selector(notifyDelegateToLogout), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupLogoutButtonLayout()
        setupVersionLabelLayout()
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            logoutButton.removeShadows()
        } else {
            logoutButton.applySmallShadow()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            logoutButton.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 22.0)
        }
    }
}

extension SettingsFooterView {
    @objc
    private func notifyDelegateToLogout() {
        delegate?.settingsFooterViewDidTapLogoutButton(self)
    }
}

extension SettingsFooterView {
    private func setupLogoutButtonLayout() {
        addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.size.equalTo(layout.current.buttonSize)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupVersionLabelLayout() {
        addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(layout.current.labelTopInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension SettingsFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 28.0
        let buttonSize = CGSize(width: 146.0, height: 44.0)
        let labelTopInset: CGFloat = 12.0
    }
}

protocol SettingsFooterViewDelegate: class {
    func settingsFooterViewDidTapLogoutButton(_ settingsFooterView: SettingsFooterView)
}
