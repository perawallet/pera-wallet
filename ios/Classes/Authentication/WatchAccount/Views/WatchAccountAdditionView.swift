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
//  WatchAccountAdditionView.swift

import UIKit
import MacaroonUIKit

final class WatchAccountAdditionView: View {
    weak var delegate: WatchAccountAdditionViewDelegate?

    private lazy var theme = WatchAccountAdditionViewTheme()
    private(set) lazy var addressInputView = createAccountAddressTextInput(
        placeholder: "watch-account-input-explanation".localized,
        floatingPlaceholder: "watch-account-input-explanation".localized
    )
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var qrButton = Button()
    private(set) lazy var createWatchAccountButton = Button()
    private lazy var pasteButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func customize(_ theme: WatchAccountAdditionViewTheme) {
        addTitle(theme)
        addDescriptionLabel(theme)
        addAddressInputView(theme)
        addQrButton(theme)
        addPasteButton(theme)
        addCreateWatchAccountButton(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func setListeners() {
        createWatchAccountButton.addTarget(self, action: #selector(notifyDelegateToOpenNextScreen), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(notifyDelegateToOpenQrScanner), for: .touchUpInside)
        pasteButton.addTarget(self, action: #selector(didTapPaste), for: .touchUpInside)
    }
}

extension WatchAccountAdditionView: ViewModelBindable {
    func bindData(_ viewModel: WatchAccountAdditionViewModel?) {
        let isPasteButtonHidden = viewModel?.pasteButtonIsHidden ?? true

        updatePasteButtonVisibility(
            isVisible: !isPasteButtonHidden,
            animated: true
        )

        guard !isPasteButtonHidden else {
            return
        }

        let pasteText = "\("watch-account-paste".localized + " ")".attributed(theme.pasteTextAttributes)
        let copiedText = "(\((viewModel?.copiedString).emptyIfNil))".attributed(theme.copiedTextAttributes)
        pasteButton.setAttributedTitle(pasteText + copiedText, for: .normal)
    }
}

extension WatchAccountAdditionView {
    private func updatePasteButtonVisibility(
        isVisible: Bool,
        animated: Bool = false
    ) {
        if animated {
            let animator = UIViewPropertyAnimator(
                duration: 0.2,
                curve: .easeInOut
            ) {
                updateVisibility()
            }
            animator.startAnimation()

            return
        }

        updateVisibility()

        func updateVisibility() {
            pasteButton.alpha = isVisible ? 1: 0
        }
    }
}
extension WatchAccountAdditionView {
    @objc
    private func didTapPaste() {
        addressInputView.text = UIPasteboard.general.string
    }
}

extension WatchAccountAdditionView {
    private func addTitle(_ theme: WatchAccountAdditionViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }
    
    private func addDescriptionLabel(_ theme: WatchAccountAdditionViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.bottomInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addAddressInputView(_ theme: WatchAccountAdditionViewTheme) {
        addSubview(addressInputView)
        addressInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.textInputVerticalInset)
        }
    }

    private func addQrButton(_ theme: WatchAccountAdditionViewTheme) {
        qrButton.customizeAppearance(theme.qr)
        
        addressInputView.addRightAccessoryItem(qrButton)
    }

    private func addPasteButton(_ theme: WatchAccountAdditionViewTheme) {
        pasteButton.customizeAppearance(theme.pasteButton)
        pasteButton.draw(corner: theme.pasteButtonCorner)
        pasteButton.contentEdgeInsets = UIEdgeInsets(theme.pasteButtonContentEdgeInsets)

        addSubview(pasteButton)
        pasteButton.snp.makeConstraints {
            $0.top.equalTo(addressInputView.snp.bottom).offset(theme.pasteButtonTopInset)
            $0.leading.equalTo(addressInputView.snp.leading)
            $0.fitToSize(theme.pasteButtonSize)
        }

        updatePasteButtonVisibility(
            isVisible: false,
            animated: false
        )
    }
    
    private func addCreateWatchAccountButton(_ theme: WatchAccountAdditionViewTheme) {
        createWatchAccountButton.customize(theme.mainButtonTheme)
        createWatchAccountButton.bindData(ButtonCommonViewModel(title: "watch-account-button".localized))
        
        addSubview(createWatchAccountButton)
        createWatchAccountButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(addressInputView.snp.bottom).offset(theme.containerTopInset)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension WatchAccountAdditionView {
    func createAccountAddressTextInput(
        placeholder: String,
        floatingPlaceholder: String?
    ) -> MultilineTextInputFieldView {
        let view = MultilineTextInputFieldView()
        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15)),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .returnKeyType(.done)
        ]

        let theme =
            MultilineTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.delegate = self
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
}

extension WatchAccountAdditionView {
    @objc
    func notifyDelegateToOpenNextScreen() {
        delegate?.watchAccountAdditionViewDidAddAccount(self)
    }

    @objc
    func notifyDelegateToOpenQrScanner() {
        delegate?.watchAccountAdditionViewDidScanQR(self)
    }
}

extension WatchAccountAdditionView {
    func beginEditing() {
        addressInputView.beginEditing()
    }
}

extension WatchAccountAdditionView: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        view.endEditing()
        delegate?.watchAccountAdditionViewDidAddAccount(self)
    }
}

protocol WatchAccountAdditionViewDelegate: AnyObject {
    func watchAccountAdditionViewDidScanQR(_ watchAccountAdditionView: WatchAccountAdditionView)
    func watchAccountAdditionViewDidAddAccount(_ watchAccountAdditionView: WatchAccountAdditionView)
}
