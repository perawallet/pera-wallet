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

//   AssetAmountInputView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class AssetAmountInputView:
    View,
    UITextFieldDelegate {
    weak var delegate: AssetAmountInputViewDelegate?

    var currentAmount: String? {
        return amountInputView.text
    }

    private lazy var iconView = URLImageView()
    private lazy var inputContainerView = UIView()
    private lazy var amountInputView = TextField()
    private lazy var amountAnimatedView = ShimmerView()
    private lazy var detailView = UILabel()
    private lazy var detailAnimatedView = ShimmerView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: AssetAmountInputViewTheme
    ) {
        addIcon(theme)
        addInputContainer(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        amountInputView.delegate = self
    }

    func bindData(
        _ viewModel: AssetAmountInputViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        iconView.prepareForReuse()
        iconView.load(from: viewModel.imageSource)

        if let primaryValue = viewModel.primaryValue {
            primaryValue.load(in: amountInputView)
        }

        amountInputView.isUserInteractionEnabled = viewModel.isInputEditable

        if let detail = viewModel.detail {
            detail.load(in: detailView)
        } else {
            detailView.clearText()
        }
    }

    func beginEditing() {
        amountInputView.becomeFirstResponder()
    }

    func endEditing() {
        amountInputView.resignFirstResponder()
    }

    func startAnimating() {
        amountInputView.isHidden = true
        detailView.isHidden = true
        amountAnimatedView.isHidden = false
        detailAnimatedView.isHidden = false
        amountAnimatedView.startAnimating()
        detailAnimatedView.startAnimating()
    }

    func stopAnimating() {
        amountAnimatedView.stopAnimating()
        detailAnimatedView.stopAnimating()
        amountInputView.isHidden = false
        detailView.isHidden = false
        amountAnimatedView.isHidden = true
        detailAnimatedView.isHidden = true
    }
}

extension AssetAmountInputView {
    private func addIcon(
        _ theme: AssetAmountInputViewTheme
    ) {
        iconView.build(theme.icon)
        iconView.customizeAppearance(theme.icon)
        
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerY == 0
            $0.leading == 0
        }
    }

    private func addInputContainer(
        _ theme: AssetAmountInputViewTheme
    ) {
        addSubview(inputContainerView)
        inputContainerView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalOffset
            $0.bottom == 0
            $0.trailing == 0
        }

        addAmountAnimated(theme)
        addAmountInput(theme)
        addDetailAnimated(theme)
        addDetail(theme)
    }

    private func addAmountAnimated(
        _ theme: AssetAmountInputViewTheme
    ) {
        amountAnimatedView.draw(corner: theme.shimmerCorner)

        inputContainerView.addSubview(amountAnimatedView)
        amountAnimatedView.snp.makeConstraints {
            $0.fitToSize(theme.amountInputShimmerSize)
            $0.top == 0
            $0.leading == 0
        }

        amountAnimatedView.isHidden = true
    }

    private func addAmountInput(
        _ theme: AssetAmountInputViewTheme
    ) {
        amountInputView.customizeAppearance(theme.amountInput)
        
        inputContainerView.addSubview(amountInputView)
        amountInputView.contentEdgeInsets = theme.amountContentEdgeInsets
        amountInputView.textEdgeInsets = theme.amountTextEdgeInsets
        amountInputView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalOffset
            $0.trailing == 0
        }

        amountInputView.addTarget(
            self,
            action: #selector(didChangeText),
            for: .editingChanged
        )
    }

    private func addDetail(
        _ theme: AssetAmountInputViewTheme
    ) {
        detailView.customizeAppearance(theme.detail)

        inputContainerView.addSubview(detailView)
        detailView.fitToVerticalIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.top == amountInputView.snp.bottom
            $0.leading == amountInputView
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addDetailAnimated(
        _ theme: AssetAmountInputViewTheme
    ) {
        detailAnimatedView.draw(corner: theme.shimmerCorner)

        inputContainerView.addSubview(detailAnimatedView)
        detailAnimatedView.snp.makeConstraints {
            $0.fitToSize(theme.detailShimmerSize)
            $0.top == amountInputView.snp.bottom
            $0.leading == amountInputView
        }

        detailAnimatedView.isHidden = true
    }
}

extension AssetAmountInputView {
    @objc
    private func didChangeText() {
        delegate?.assetAmountInputView(
            self,
            didChangeTextIn: amountInputView
        )
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.assetAmountInputView(
            self,
            didBeginEditingIn: amountInputView
        )
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.assetAmountInputView(
            self,
            didEndEditingIn: amountInputView
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.assetAmountInputView(
            self,
            shouldChangeCharactersIn: amountInputView,
            with: range,
            replacementString: string
        )
    }
}

protocol AssetAmountInputViewDelegate: AnyObject {
    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didChangeTextIn textField: TextField
    )
    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didBeginEditingIn textField: TextField
    )
    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didEndEditingIn textField: TextField
    )
    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool
}
