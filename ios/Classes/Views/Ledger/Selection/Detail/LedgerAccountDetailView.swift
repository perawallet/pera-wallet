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
//  LedgerAccountDetailView.swift

import UIKit

class LedgerAccountDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withText("ledger-account-details-title".localized)
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var accountStackView = WrappedStackView()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var rekeyedAccountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 12.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAccountStackViewLayout()
        setupSubtitleLabelLayout()
        setupRekeyedAccountsStackViewLayout()
    }
}

extension LedgerAccountDetailView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAccountStackViewLayout() {
        addSubview(accountStackView)
        
        accountStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.stackTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(accountStackView.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupRekeyedAccountsStackViewLayout() {
        addSubview(rekeyedAccountsStackView)
        
        rekeyedAccountsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.stackTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension LedgerAccountDetailView {
    func bind(_ viewModel: LedgerAccountDetailViewModel) {
        viewModel.assetViews.forEach { view in
            accountStackView.addArrangedSubview(view)
        }
        
        guard let rekeyedAccountViews = viewModel.rekeyedAccountViews else {
            return
        }
        
        subtitleLabel.text = viewModel.subtitle
        
        rekeyedAccountViews.forEach { view in
            rekeyedAccountsStackView.addArrangedSubview(view)
        }
    }
}

extension LedgerAccountDetailView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let stackTopInset: CGFloat = 12.0
        let subtitleTopInset: CGFloat = 40.0
    }
}
