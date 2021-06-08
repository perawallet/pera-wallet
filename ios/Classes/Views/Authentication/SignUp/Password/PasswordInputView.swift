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
//  PasswordInputView.swift

import UIKit

class PasswordInputView: BaseView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 220.0, height: 20.0)
    }
    
    private(set) var passwordInputCircleViews = [PasswordInputCircleView]()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupStackViewLayout()
        configureStackView()
    }
}

extension PasswordInputView {
    private func setupStackViewLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureStackView() {
        for _ in 1...6 {
            let circleView = PasswordInputCircleView()
            passwordInputCircleViews.append(circleView)
            stackView.addArrangedSubview(circleView)
        }
    }
}
