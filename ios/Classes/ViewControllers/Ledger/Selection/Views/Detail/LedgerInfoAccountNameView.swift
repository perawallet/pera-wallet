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
//  LedgerInfoAccountNameView.swift

import UIKit

class LedgerInfoAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountNameView = ImageWithTitleView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension LedgerInfoAccountNameView {
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
        
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
            
        separatorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalTo(accountNameView)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerInfoAccountNameView {
    func bind(_ viewModel: AccountNameViewModel) {
        accountNameView.bindData(viewModel)
    }
}

extension LedgerInfoAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let verticalInset: CGFloat = 20.0
        let trailingInset: CGFloat = 8.0
        let accountNameInset: CGFloat = 24.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let separatorHeight: CGFloat = 1.0
    }
}
