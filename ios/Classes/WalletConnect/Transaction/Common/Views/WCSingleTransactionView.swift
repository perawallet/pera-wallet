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
//   WCSingleTransactionView.swift

import UIKit

class WCSingleTransactionView: BaseView {
    private let layout = Layout<LayoutConstants>()
    
    private lazy var mainStackView: VStackView = {
        let stackView = VStackView()
        stackView.backgroundColor = Colors.Defaults.background.uiColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var participantInformationStackView: WrappedStackView = {
        let participantInformationStackView = WrappedStackView()
        participantInformationStackView.backgroundColor = Colors.Defaults.background.uiColor
        participantInformationStackView.stackView.distribution = .equalSpacing
        participantInformationStackView.stackView.spacing = 20
        participantInformationStackView.stackView.isUserInteractionEnabled = true
        return participantInformationStackView
    }()

    private lazy var participantInformationSeparator = LineSeparatorView()

    private lazy var transactionInformationStackView: WrappedStackView = {
        let balanceInformationStackView = WrappedStackView()
        balanceInformationStackView.backgroundColor = Colors.Defaults.background.uiColor
        balanceInformationStackView.stackView.distribution = .equalSpacing
        balanceInformationStackView.stackView.spacing = 20
        return balanceInformationStackView
    }()

    private lazy var transactionInformationSeparator = LineSeparatorView()

    private lazy var detailedInformationStackView: WrappedStackView = {
        let detailedInformationStackView = WrappedStackView()
        detailedInformationStackView.backgroundColor = Colors.Defaults.background.uiColor
        detailedInformationStackView.stackView.distribution = .equalSpacing
        detailedInformationStackView.stackView.spacing = 20
        detailedInformationStackView.isUserInteractionEnabled = true
        detailedInformationStackView.stackView.isUserInteractionEnabled = true
        return detailedInformationStackView
    }()

    private lazy var detailInformationSeparator = LineSeparatorView()

    private lazy var buttonsStackView: WrappedStackView = {
        let buttonsStackView = WrappedStackView()
        buttonsStackView.backgroundColor = Colors.Defaults.background.uiColor
        buttonsStackView.stackView.distribution = .equalSpacing
        buttonsStackView.stackView.spacing = 20
        buttonsStackView.isUserInteractionEnabled = true
        buttonsStackView.stackView.isUserInteractionEnabled = true
        return buttonsStackView
    }()

    override func prepareLayout() {
        setupMainStackViewLayout()
    }
}

extension WCSingleTransactionView {
    private func setupMainStackViewLayout() {
        addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }

        mainStackView.addArrangedSubview(participantInformationStackView)
        mainStackView.addArrangedSubview(participantInformationSeparator)

        participantInformationSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        mainStackView.addArrangedSubview(transactionInformationStackView)
        mainStackView.addArrangedSubview(transactionInformationSeparator)

        transactionInformationSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        mainStackView.addArrangedSubview(detailedInformationStackView)
        mainStackView.addArrangedSubview(detailInformationSeparator)

        detailInformationSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        mainStackView.addArrangedSubview(buttonsStackView)
    }
}

extension WCSingleTransactionView {
    func addParticipantInformationView(_ view: UIView) {
        participantInformationStackView.addArrangedSubview(view)
    }

    func addTransactionInformationView(_ view: UIView) {
        transactionInformationStackView.addArrangedSubview(view)
    }

    func addDetailedInformationView(_ view: UIView) {
        detailedInformationStackView.addArrangedSubview(view)
    }

    func addButton(_ view: UIView) {
        buttonsStackView.addArrangedSubview(view)
    }

    func showTransactionInformationStackView(_ isShown: Bool) {
        if isShown {
            transactionInformationStackView.showViewInStack()
            transactionInformationSeparator.showViewInStack()
        } else {
            transactionInformationStackView.hideViewInStack()
            transactionInformationSeparator.hideViewInStack()
        }
    }

    func showNoteStackView(_ isShown: Bool) {
        if isShown {
            detailedInformationStackView.showViewInStack()
            detailInformationSeparator.showViewInStack()
        } else {
            detailedInformationStackView.hideViewInStack()
            detailInformationSeparator.hideViewInStack()
        }
    }
}

extension WCSingleTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let spacing: CGFloat = 24.0
        let horizontalInset: CGFloat = 24.0
    }
}
