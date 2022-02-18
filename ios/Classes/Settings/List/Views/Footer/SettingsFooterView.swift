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
//  SettingsFooterView.swift

import UIKit
import MacaroonUIKit

final class SettingsFooterView: View {
    weak var delegate: SettingsFooterViewDelegate?
    
    private lazy var theme = SettingsFooterViewTheme()
    private lazy var logoutButton = UIButton()
    private lazy var versionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func setListeners() {
        logoutButton.addTarget(self, action: #selector(notifyDelegateToLogout), for: .touchUpInside)
    }
    
    func customize(_ theme: SettingsFooterViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addLogoutButton()
        addVersionLabel()
    }
    
    func customizeAppearance(_ styleSheet: StyleSheet) {}
    
    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension SettingsFooterView {
    @objc
    private func notifyDelegateToLogout() {
        delegate?.settingsFooterViewDidTapLogoutButton(self)
    }
}

extension SettingsFooterView {
    private func addLogoutButton() {
        logoutButton.customizeAppearance(theme.button)
        logoutButton.layer.cornerRadius = theme.buttonCornerRadius
        addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints {
            $0.fitToHeight(theme.buttonHeight)
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addVersionLabel() {
        versionLabel.customizeAppearance(theme.subTitle)
        addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(theme.subTitleTopInset)
            $0.centerX.equalToSuperview()
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "settings-app-version".localized(params: version)
        }
    }
}

protocol SettingsFooterViewDelegate: AnyObject {
    func settingsFooterViewDidTapLogoutButton(_ settingsFooterView: SettingsFooterView)
}
