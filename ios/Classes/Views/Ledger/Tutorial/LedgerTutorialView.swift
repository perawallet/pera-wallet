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
//  LedgerTutorialView.swift

import UIKit

class LedgerTutorialView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerTutorialViewDelegate?

    private lazy var animatedImageView: LottieImageView = {
        let animatedImageView = LottieImageView()
        animatedImageView.setAnimation("ledger_animation")
        return animatedImageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("ledger-tutorial-title-text".localized)
    }()
    
    private lazy var ledgerTutorialInstructionListView: LedgerTutorialInstructionListView = {
        let ledgerTutorialInstructionListView = LedgerTutorialInstructionListView()
        ledgerTutorialInstructionListView.backgroundColor = Colors.Background.tertiary
        return ledgerTutorialInstructionListView
    }()
    
    private lazy var searchButton = MainButton(title: "ledger-search-button-title".localized)
    
    override func setListeners() {
        searchButton.addTarget(self, action: #selector(notifyDelegateToSearchLedgerDevices), for: .touchUpInside)
    }

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func prepareLayout() {
        setupAnimatedImageViewLayout()
        setupTitleLabelLayout()
        setupLedgerTutorialInstructionListViewLayout()
        setupSearchButtonLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialInstructionListView.delegate = self
    }
}

extension LedgerTutorialView {
    @objc
    private func notifyDelegateToSearchLedgerDevices() {
        delegate?.ledgerTutorialViewDidTapSearchButton(self)
    }
}

extension LedgerTutorialView {
    private func setupAnimatedImageViewLayout() {
        addSubview(animatedImageView)
        
        animatedImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.imageTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
            make.top.equalTo(animatedImageView.snp.bottom).offset(layout.current.titleTopInset)
        }
    }
    
    private func setupLedgerTutorialInstructionListViewLayout() {
        addSubview(ledgerTutorialInstructionListView)
        
        ledgerTutorialInstructionListView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.listTopInset)
        }
    }
    
    private func setupSearchButtonLayout() {
        addSubview(searchButton)
        
        searchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(ledgerTutorialInstructionListView.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}

extension LedgerTutorialView: LedgerTutorialInstructionListViewDelegate {
    func ledgerTutorialInstructionListViewDidTapOpenApp(_ view: LedgerTutorialInstructionListView) {
        delegate?.ledgerTutorialView(self, didTap: .openApp)
    }
    
    func ledgerTutorialInstructionListViewDidTapInstallApp(_ view: LedgerTutorialInstructionListView) {
        delegate?.ledgerTutorialView(self, didTap: .installApp)
    }
    
    func ledgerTutorialInstructionListViewDidTapBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        delegate?.ledgerTutorialView(self, didTap: .bluetoothConnection)
    }
    
    func ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        delegate?.ledgerTutorialView(self, didTap: .ledgerBluetoothConnection)
    }
}

extension LedgerTutorialView {
    func startAnimating() {
        animatedImageView.show(with: LottieConfiguration())
    }

    func stopAnimating() {
        animatedImageView.stop()
    }
}

extension LedgerTutorialView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let imageTopInset: CGFloat = 40.0
        let listTopInset: CGFloat = 32.0
        let buttonHorizontalInset: CGFloat = 32.0
        let buttonBottomInset: CGFloat = 40.0
        let titleTopInset: CGFloat = 16.0
        let buttonMinimumTopInset: CGFloat = 20.0
    }
}

protocol LedgerTutorialViewDelegate: AnyObject {
    func ledgerTutorialViewDidTapSearchButton(_ ledgerTutorialView: LedgerTutorialView)
    func ledgerTutorialView(_ ledgerTutorialView: LedgerTutorialView, didTap section: LedgerTutorialSection)
}

enum LedgerTutorialSection {
    case ledgerBluetoothConnection
    case openApp
    case installApp
    case bluetoothConnection
}
