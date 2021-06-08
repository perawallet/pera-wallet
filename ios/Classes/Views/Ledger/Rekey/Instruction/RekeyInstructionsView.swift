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
//  RekeyInstructionsView.swift

import UIKit

class RekeyInstructionsView: BaseView {
    
    weak var delegate: RekeyInstructionsViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .bold(size: 28.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.primary)
            .withText("rekey-instruction-title".localized)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.tertiary)
    }()
    
    private lazy var instructionHeaderLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.tertiary)
            .withText("rekey-instruction-header".localized)
    }()
    
    private lazy var firstInstructionView = RekeyInstructionItemView()
   
    private lazy var secondInstructionView = RekeyInstructionItemView()
    
    private lazy var thirdInstructionView = RekeyInstructionItemView()
    
    private lazy var startButton = MainButton(title: "rekey-instruction-start".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        firstInstructionView.setTitle("rekey-instruction-first".localized)
        thirdInstructionView.setTitle("rekey-instruction-third".localized)
    }
    
    override func setListeners() {
        startButton.addTarget(self, action: #selector(notifyDelegateToStartRekeying), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubitleLabelLayout()
        setupInstructionHeaderLabelLayout()
        setupFirstInstructionViewLayout()
        setupSecondInstructionViewLayout()
        setupThirdInstructionViewLayout()
        setupStartButtonLayout()
    }
}

extension RekeyInstructionsView {
    @objc
    private func notifyDelegateToStartRekeying() {
        delegate?.rekeyInstructionsViewDidStartRekeying(self)
    }
}

extension RekeyInstructionsView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleInset)
        }
    }
    
    private func setupSubitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.titleInset)
        }
    }
    
    private func setupInstructionHeaderLabelLayout() {
        addSubview(instructionHeaderLabel)
        
        instructionHeaderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.headerTopInset)
        }
    }
    
    private func setupFirstInstructionViewLayout() {
        addSubview(firstInstructionView)
        
        firstInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(instructionHeaderLabel.snp.bottom).offset(layout.current.titleInset)
        }
    }
    
    private func setupSecondInstructionViewLayout() {
        addSubview(secondInstructionView)
        
        secondInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(firstInstructionView)
            make.top.equalTo(firstInstructionView.snp.bottom).offset(layout.current.instructionInset)
        }
    }
    
    private func setupThirdInstructionViewLayout() {
        addSubview(thirdInstructionView)
        
        thirdInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(firstInstructionView)
            make.top.equalTo(secondInstructionView.snp.bottom).offset(layout.current.instructionInset)
        }
    }
    
    private func setupStartButtonLayout() {
        addSubview(startButton)
        
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.greaterThanOrEqualTo(thirdInstructionView.snp.bottom).offset(layout.current.buttonInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.buttonInset)
        }
    }
}

extension RekeyInstructionsView {
    func setSubtitleText(_ text: String) {
        subtitleLabel.text = text
    }
    
    func setSecondInstructionViewTitle(_ title: String) {
        secondInstructionView.setTitle(title)
    }
}

extension RekeyInstructionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let titleInset: CGFloat = 16.0
        let headerTopInset: CGFloat = 60.0
        let instructionInset: CGFloat = 12.0
        let buttonInset: CGFloat = 16.0
    }
}

protocol RekeyInstructionsViewDelegate: class {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView)
}
