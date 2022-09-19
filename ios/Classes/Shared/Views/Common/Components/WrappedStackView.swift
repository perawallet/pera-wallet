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
//  WrappedStackView.swift

import UIKit

class WrappedStackView: BaseView {
    
    private(set) lazy var containerView = UIView()
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Defaults.background.uiColor
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupStackViewLayout()
    }
}

extension WrappedStackView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupStackViewLayout() {
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
}

extension WrappedStackView {
    func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    func clear() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
