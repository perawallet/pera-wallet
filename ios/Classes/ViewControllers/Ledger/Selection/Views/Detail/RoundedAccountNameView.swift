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
//  RoundedAccountNameView.swift

import UIKit

class RoundedAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountNameView = ImageWithTitleView()
    
    override func configureAppearance() {
        layer.cornerRadius = 12.0
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupAccountNameViewLayout()
    }
}

extension RoundedAccountNameView {
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension RoundedAccountNameView {
    func bind(_ viewModel: AccountNameViewModel) {
        accountNameView.bindData(viewModel)
    }
}

extension RoundedAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
    }
}
