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
//  SettingsToggleContextView.swift

import UIKit

class SettingsToggleContextView: BaseView {
    
    let layout = Layout<LayoutConstants>()
    
    weak var delegate: SettingsToggleContextViewDelegate?
    
    private lazy var imageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    private lazy var toggle = Toggle()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func setListeners() {
        toggle.addTarget(self, action: #selector(didChangeToggle(_:)), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
        setupToggleLayout()
        setupSeparatorViewLayout()
    }
}

extension SettingsToggleContextView {
    @objc
    private func didChangeToggle(_ toggle: Toggle) {
        delegate?.settingsToggleContextView(self, didChangeValue: toggle.isOn)
    }
}

extension SettingsToggleContextView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.nameOffset)
        }
    }
    
    private func setupToggleLayout() {
        addSubview(toggle)
        
        toggle.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(12.0)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SettingsToggleContextView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setToggleOn(_ isOn: Bool, animated: Bool) {
        toggle.setOn(isOn, animated: animated)
    }
    
    func setSeparatorHidden(_ isHidden: Bool) {
        separatorView.isHidden = isHidden
    }
    
    var isToggleOn: Bool {
        return toggle.isOn
    }
}

extension SettingsToggleContextView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let nameOffset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}

protocol SettingsToggleContextViewDelegate: class {
    func settingsToggleContextView(_ settingsToggleContextView: SettingsToggleContextView, didChangeValue value: Bool)
}
