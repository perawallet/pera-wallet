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
//  LedgerApprovalView.swift

import UIKit

class LedgerApprovalView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerApprovalViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var ledgerDeviceConnectionView = LedgerDeviceConnectionView()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-cancel".localized)
            .withTitleColor(Colors.ButtonText.secondary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancel), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupTitleLabelLayout()
        setupLedgerDeviceConnectionViewLayout()
        setupDetailLabelLayout()
        setupCancelButtonLayout()
    }
}

extension LedgerApprovalView {
    @objc
    private func notifyDelegateToCancel() {
        delegate?.ledgerApprovalViewDidTapCancelButton(self)
    }
}

extension LedgerApprovalView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
            
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupLedgerDeviceConnectionViewLayout() {
        addSubview(ledgerDeviceConnectionView)
            
        ledgerDeviceConnectionView.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.bluetoothTopInset)
            make.leading.trailing.equalToSuperview()
        }
    }
        
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
            
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(ledgerDeviceConnectionView.snp.bottom).offset(layout.current.detailLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
        
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
            
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonVerticalInset + safeAreaBottom)
        }
    }
}

extension LedgerApprovalView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }

    func startConnectionAnimation() {
        ledgerDeviceConnectionView.startAnimation()
    }

    func stopConnectionAnimation() {
        ledgerDeviceConnectionView.stopAnimation()
    }
}

extension LedgerApprovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleVerticalInset: CGFloat = 16.0
        let titleHorizontalInset: CGFloat = 25.0
        let bluetoothTopInset: CGFloat = 36.0
        let buttonVerticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 30.0
        let detailLabelTopInset: CGFloat = 20.0
    }
}

protocol LedgerApprovalViewDelegate: AnyObject {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView)
}
