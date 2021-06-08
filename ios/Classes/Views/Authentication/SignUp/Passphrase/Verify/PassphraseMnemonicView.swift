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
//  PassPhraseMnemonicView.swift

import UIKit

class PassphraseMnemonicView: BaseView {

    var isSelected = false {
        didSet {
            recustomizeAppearanceWhenSelectedStateDidChange()
        }
    }

    private lazy var backgroundImageView = UIImageView(image: img("bg-passphrase-verify"))
    
    private lazy var phraseLabel: UILabel = {
        let label = UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupPhraseLabelLayout()
    }
}

extension PassphraseMnemonicView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupPhraseLabelLayout() {
        backgroundImageView.addSubview(phraseLabel)
        
        phraseLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension PassphraseMnemonicView {
    func bind(_ viewModel: PassphraseMnemonicViewModel) {
        phraseLabel.text = viewModel.phrase
    }

    private func recustomizeAppearanceWhenSelectedStateDidChange() {
        backgroundImageView.image = isSelected ? img("bg-passphrase-verify-selected") : img("bg-passphrase-verify")
    }
}
