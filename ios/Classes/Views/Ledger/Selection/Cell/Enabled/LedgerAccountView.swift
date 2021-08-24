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
//  LedgerAccountView.swift

import UIKit

class LedgerAccountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountViewDelegate?
    
    var state: State = .unselected {
        didSet {
            switch state {
            case .selected:
                accountStackView.containerView.layer.borderWidth = 2.0
                accountStackView.containerView.layer.borderColor = Colors.General.selected.cgColor
            case .unselected:
                accountStackView.containerView.layer.borderWidth = 0.0
            }
        }
    }
    
    private lazy var accountStackView: WrappedStackView = {
        let accountStackView = WrappedStackView()
        accountStackView.stackView.isUserInteractionEnabled = true
        return accountStackView
    }()
    
    override func prepareLayout() {
        setupAccountStackViewLayout()
    }
}

extension LedgerAccountView {
    private func setupAccountStackViewLayout() {
        addSubview(accountStackView)
        
        accountStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension LedgerAccountView {
    func clear() {
        accountStackView.clear()
    }
    
    func bind(_ viewModel: LedgerAccountNameViewModel) {
        if let nameView = accountStackView.stackView.arrangedSubviews.first as? LedgerAccountNameView {
            nameView.bind(viewModel)
        }
    }
    
    func bind(_ viewModel: LedgerAccountViewModel) {
        state = viewModel.isSelected ? .selected : .unselected
        
        viewModel.subviews.forEach { view in
            if let ledgerAccountNameView = view as? LedgerAccountNameView {
                ledgerAccountNameView.delegate = self
            }
            accountStackView.addArrangedSubview(view)
        }
    }
}

extension LedgerAccountView: LedgerAccountNameViewDelegate {
    func ledgerAccountNameViewDidOpenInfo(_ ledgerAccountNameView: LedgerAccountNameView) {
        delegate?.ledgerAccountViewDidOpenMoreInfo(self)
    }
}

extension LedgerAccountView {
    enum State {
        case selected
        case unselected
    }
}

extension LedgerAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackInitialHeight: CGFloat = 118.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol LedgerAccountViewDelegate: AnyObject {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountView)
}
