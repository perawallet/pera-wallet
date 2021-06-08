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
//  MainHeaderView.swift

import UIKit

class MainHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: MainHeaderViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 28.0 * horizontalScale)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
    }()
    
    private lazy var testNetLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 10.0)))
            .withTextColor(Colors.ButtonText.primary)
            .withAlignment(.center)
            .withText("title-testnet".localized)
        label.backgroundColor = Colors.General.testNetBanner
        label.layer.cornerRadius = 12.0
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom).withImage(img("img-accounts-scan-qr"))
        button.contentMode = .scaleToFill
        return button
    }()
    
    private lazy var addButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-accounts-add"))
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        if !isDarkModeDisplay {
            qrButton.applyShadow(
                Shadow(color: Colors.MainHeader.shadowColor, offset: CGSize(width: 0.0, height: 4.0), radius: 12.0, opacity: 1.0)
            )
        }
    }
    
    override func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToScanQR), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAddButtonLayout()
        setupQRButtonLayout()
        setupTestNetLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            qrButton.layer.shadowPath = UIBezierPath(roundedRect: qrButton.bounds, cornerRadius: 20.0).cgPath
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            qrButton.removeShadow()
        } else {
            qrButton.applyShadow(
                Shadow(color: Colors.MainHeader.shadowColor, offset: CGSize(width: 0.0, height: 4.0), radius: 12.0, opacity: 1.0)
            )
        }
    }
}

extension MainHeaderView {
    @objc
    private func notifyDelegateToScanQR() {
        delegate?.mainHeaderViewDidTapQRButton(self)
    }
    
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.mainHeaderViewDidTapAddButton(self)
    }
}

extension MainHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupQRButtonLayout() {
        addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(layout.current.buttonOffset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupTestNetLabelLayout() {
        addSubview(testNetLabel)
        
        testNetLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.labelOffset)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(layout.current.testNetLabelSize)
        }
    }
}

extension MainHeaderView {
    func setTestNetLabelHidden(_ hidden: Bool) {
        testNetLabel.isHidden = hidden
    }
    
    func setQRButtonHidden(_ hidden: Bool) {
        qrButton.isHidden = hidden
    }
    
    func setAddButtonHidden(_ hidden: Bool) {
        addButton.isHidden = hidden
    }

    func setRightActionButtonImage(_ image: UIImage?) {
        addButton.setImage(image, for: .normal)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension MainHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonOffset: CGFloat = -16.0 * horizontalScale
        let labelOffset: CGFloat = 8.0 * horizontalScale
        let verticalInset: CGFloat = 18.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let testNetLabelSize = CGSize(width: 63.0, height: 24.0)
    }
}

extension Colors {
    fileprivate enum MainHeader {
        static let shadowColor = rgba(0.26, 0.26, 0.31, 0.07)
    }
}

protocol MainHeaderViewDelegate: class {
    func mainHeaderViewDidTapQRButton(_ mainHeaderView: MainHeaderView)
    func mainHeaderViewDidTapAddButton(_ mainHeaderView: MainHeaderView)
}
