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
//  LedgerTutorialInstructionView.swift

import UIKit

class LedgerTutorialInstructionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var tutorialNumberView = TutorialNumberView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))

    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupTutorialNumberViewLayout()
        setupArrowImageViewLayout()
        setupTitleLabelLayout()
    }
}

extension LedgerTutorialInstructionView {
    private func setupTutorialNumberViewLayout() {
        addSubview(tutorialNumberView)
        
        tutorialNumberView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.numberSize)
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.iconSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(tutorialNumberView)
            make.leading.equalTo(tutorialNumberView.snp.trailing).offset(layout.current.horizontalInset)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(layout.current.titleHorizontalInset)
        }
    }
}

extension LedgerTutorialInstructionView {
    func bind(_ viewModel: LedgerTutorialInstructionViewModel) {
        if let number = viewModel.number {
            tutorialNumberView.bind(TutorialNumberViewModel(number: number))
        }
        titleLabel.text = viewModel.title
    }
}

extension LedgerTutorialInstructionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let numberSize = CGSize(width: 32.0, height: 32.0)
        let titleHorizontalInset: CGFloat = -12.0
    }
}
