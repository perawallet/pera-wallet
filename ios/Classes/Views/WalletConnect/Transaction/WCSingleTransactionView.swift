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
//   WCSingleTransactionView.swift

import UIKit

class WCSingleTransactionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var mainDelegate: WCSingleTransactionViewDelegate?

    private lazy var mainStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var participantInformationStackView: WrappedStackView = {
        let participantInformationStackView = WrappedStackView()
        participantInformationStackView.stackView.distribution = .equalSpacing
        return participantInformationStackView
    }()

    private lazy var transactionInformationStackView: WrappedStackView = {
        let balanceInformationStackView = WrappedStackView()
        balanceInformationStackView.stackView.distribution = .equalSpacing
        return balanceInformationStackView
    }()

    private lazy var detailedInformationStackView: WrappedStackView = {
        let detailedInformationStackView = WrappedStackView()
        detailedInformationStackView.stackView.distribution = .equalSpacing
        detailedInformationStackView.isUserInteractionEnabled = true
        detailedInformationStackView.stackView.isUserInteractionEnabled = true
        return detailedInformationStackView
    }()

    override func configureAppearance() {
        super.configureAppearance()

        if !isDarkModeDisplay {
            applyShadows()
        }
    }

    override func linkInteractors() {
        dappMessageView.delegate = self
    }

    override func prepareLayout() {
        setupMainStackViewLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            participantInformationStackView.containerView.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
            transactionInformationStackView.containerView.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
            detailedInformationStackView.containerView.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
        }
    }

    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            participantInformationStackView.containerView.removeShadows()
            transactionInformationStackView.containerView.removeShadows()
            detailedInformationStackView.containerView.removeShadows()
        } else {
            applyShadows()
        }
    }

    private func applyShadows() {
        participantInformationStackView.containerView.applyShadow(smallBottomShadow)
        transactionInformationStackView.containerView.applyShadow(smallBottomShadow)
        detailedInformationStackView.containerView.applyShadow(smallBottomShadow)
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

        mainStackView.addArrangedSubview(dappMessageView)
        mainStackView.addArrangedSubview(participantInformationStackView)
        mainStackView.addArrangedSubview(transactionInformationStackView)
        mainStackView.addArrangedSubview(detailedInformationStackView)
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
}

extension WCSingleTransactionView: WCTransactionDappMessageViewDelegate {
    func wcTransactionDappMessageViewDidTapped(_ WCTransactionDappMessageView: WCTransactionDappMessageView) {
        mainDelegate?.wcSingleTransactionViewDidOpenLongDappMessage(self)
    }
}

extension WCSingleTransactionView {
    func bind(_ viewModel: WCSingleTransactionViewModel) {
        if let transactionDappMessageViewModel = viewModel.transactionDappMessageViewModel {
            dappMessageView.bind(transactionDappMessageViewModel)
        }
    }
}

extension WCSingleTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let spacing: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol WCSingleTransactionViewDelegate: AnyObject {
    func wcSingleTransactionViewDidOpenLongDappMessage(_ wcSingleTransactionView: WCSingleTransactionView)
}
