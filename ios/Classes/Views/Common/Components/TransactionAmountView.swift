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
//  TransactionAmountView.swift

import UIKit

class TransactionAmountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    var mode: Mode = .normal(amount: 0.00) {
        didSet {
            updateAmountView()
        }
    }
    
    private lazy var amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 0.0
        return stackView
    }()
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.TransactionAmount.normal)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-gray", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(Colors.TransactionAmount.normal)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupAmountStackViewLayout()
    }
}

extension TransactionAmountView {
    private func setupAmountStackViewLayout() {
        addSubview(amountStackView)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        amountStackView.addArrangedSubview(signLabel)
        amountStackView.addArrangedSubview(algoIconImageView)
        amountStackView.addArrangedSubview(amountLabel)
    }
}

extension TransactionAmountView {
    private func updateAmountView() {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction):
            signLabel.isHidden = true
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = Colors.TransactionAmount.normal
            algoIconImageView.tintColor = Colors.TransactionAmount.normal
            setAlgoIconHidden(!isAlgos)
        case let .positive(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = Colors.TransactionAmount.positive
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = Colors.TransactionAmount.positive
            algoIconImageView.tintColor = Colors.TransactionAmount.positive
            setAlgoIconHidden(!isAlgos)
        case let .negative(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = Colors.TransactionAmount.negative
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = Colors.TransactionAmount.negative
            algoIconImageView.tintColor = Colors.TransactionAmount.negative
            setAlgoIconHidden(!isAlgos)
        }
    }
    
    private func setAmount(_ amount: Double, with assetFraction: Int?) {
        if let fraction = assetFraction {
            amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
        } else {
            amountLabel.text = amount.toAlgosStringForLabel
        }
    }
    
    private func setAlgoIconHidden(_ isHidden: Bool) {
        algoIconImageView.isHidden = isHidden
    }
}

extension TransactionAmountView {
    enum Mode {
        case normal(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
        case positive(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
        case negative(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
    }
}

extension Colors {
    fileprivate enum TransactionAmount {
        static let positive = Colors.Main.primary600
        static let negative = Colors.Main.red600
        static let normal = Colors.Text.primary
    }
}

extension TransactionAmountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 4.0
    }
}
