// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCMainArbitraryDataScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import MagpieHipo
import MacaroonBottomOverlay
import UIKit
import SnapKit

/// <todo>
/// Refactor.
/// <todo>
/// Fix the data management which blocks the main thread on too many data.
final class WCMainArbitraryDataScreen:
    BaseViewController,
    Container,
    WCArbitraryDataValidator {
    weak var delegate: WCMainArbitraryDataScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return api!.isTestNet ? .darkContent : .lightContent
    }

    private lazy var theme = Theme()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var transitionToRejectionReason = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var wcDataSigner = createDataSigner()
    private lazy var dataSignQueue = DispatchQueue.global(qos: .userInitiated)

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var dataSource = WCMainArbitraryDataDataSource(
        sharedDataController: sharedDataController,
        data: data,
        wcSession: wcSession,
        wcRequest: wcRequest,
        peraConnect: peraConnect,
        currencyFormatter: currencyFormatter
    )

    private lazy var initialDataLoadingQueue = DispatchQueue(
        label: "wcMainArbitraryDataScreen.initialDataLoadingQueue",
        qos: .userInitiated
    )

    private var signedData: [Data?] = []

    private var isRejected = false

    private var isViewLayoutLoaded = false

    private let data: [WCArbitraryData]
    private let wcRequest: WalletConnectRequestDraft
    private let wcSession: WCSessionDraft

    init(
        draft: WalletConnectArbitraryDataSignRequestDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.data = draft.arbitraryData
        self.wcRequest = draft.request
        self.wcSession = draft.session

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        setDataSigners()

        super.viewDidLoad()

        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            loadInitialData()

            isViewLayoutLoaded = true
        }
    }
}

extension WCMainArbitraryDataScreen {
    private func loadInitialData() {
        startLoading()

        initialDataLoadingQueue.async {
            [weak self] in
            guard let self else { return }

            validateArbitraryData(
                data: data,
                api: api!,
                session: session!
            )

            stopLoading()
        }
    }
}

extension WCMainArbitraryDataScreen {
    private func addUI() {
        addBackground()
        addDappInfo()
        addArbitraryDataFragment()
    }

    private func addBackground() {
        view.backgroundColor = theme.backgroundColor
    }

    private func addDappInfo() {
        view.addSubview(dappMessageView)
        dappMessageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.dappViewLeadingInset)
            $0.top.safeEqualToTop(of: self).offset(theme.dappViewTopInset)
        }

        bindDappInfo()
    }

    private func addArbitraryDataFragment() {
        let fragment = makeArbitraryDataFragment()

        let container = NavigationContainer(rootViewController: fragment)

        addFragment(container) { fragmentView in
            fragmentView.roundCorners(
                corners: [.topLeft, .topRight],
                radius: theme.fragmentRadius
            )

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.top.equalToSuperview().inset(theme.fragmentTopInset)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    private func makeArbitraryDataFragment() -> UIViewController {
        let isSingleData = data.isSingular
        let fragment =
            isSingleData
            ? makeSingleArbitraryDataRequestFragment()
            : makeUnsignedArbitraryDataRequestFragment()
        return fragment
    }

    private func makeSingleArbitraryDataRequestFragment() -> UIViewController {
        let fragment = WCSingleArbitraryDataRequestScreen(
            dataSource: dataSource,
            currencyFormatter: currencyFormatter, 
            configuration: configuration
        )
        fragment.delegate = self
        return fragment
    }

    private func makeUnsignedArbitraryDataRequestFragment() -> UIViewController {
        let fragment = WCUnsignedArbitrayDataRequestScreen(
            dataSource: dataSource,
            configuration: configuration
        )
        fragment.delegate = self
        return fragment
    }
}

extension WCMainArbitraryDataScreen {
    private func bindDappInfo() {
        let viewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            imageSize: CGSize(width: 48.0, height: 48.0)
        )
        dappMessageView.bind(viewModel)
    }
}

extension WCMainArbitraryDataScreen {
    private func createDataSigner() -> WCArbitraryDataSigner {
        let signer = WCArbitraryDataSigner(
            api: api!,
            analytics: analytics
        )
        signer.delegate = self
        return signer
    }
}

extension WCMainArbitraryDataScreen: WCArbitraryDataSignerDelegate {
    private func setDataSigners() {
        if let session {
            data.forEach {
                $0.findSignerAccount(
                    in: sharedDataController.accountCollection,
                    on: session
                )
            }
        }
    }

    private func confirmSigning() {
        startLoading()

        guard let signableData = getFirstSignableData(),
              let index = data.firstIndex(of: signableData) else {
            rejectSigning(reason: .unauthorized(.dataSignerNotFound))
            return
        }

        dataSignQueue.async {
            [weak self] in
            guard let self else { return }

            fillInitialUnsignedData(until: index)
            signData(signableData)
        }
    }

    private func getFirstSignableData() -> WCArbitraryData? {
        return data.first { data in
            data.requestedSigner.account != nil
        }
    }

    private func fillInitialUnsignedData(until index: Int) {
        for _ in 0..<index {
            signedData.append(nil)
        }
    }

    private func signData(_ data: WCArbitraryData) {
        if let signerAccount = data.requestedSigner.account {
            wcDataSigner.signData(
                data,
                for: signerAccount
            )
        } else {
            signedData.append(nil)
        }
    }

    func wcArbitraryDataSigner(
        _ wcArbitraryDataSigner: WCArbitraryDataSigner,
        didSign data: WCArbitraryData,
        signedData: Data
    ) {
        self.signedData.append(signedData)

        dataSignQueue.async {
            [weak self] in
            guard let self else { return }
            self.continueSigningData(after: data)
        }
    }

    private func continueSigningData(after unsignedData: WCArbitraryData) {
        if let index = data.firstIndex(of: unsignedData),
           let nextData = data.nextElement(afterElementAt: index) {
            if let signerAccount = nextData.requestedSigner.account {
                wcDataSigner.signData(
                    nextData,
                    for: signerAccount
                )
            } else {
                signedData.append(nil)
                continueSigningData(after: nextData)
            }
            return
        }

        if data.count != signedData.count {
            rejectSigning(reason: .invalidInput(.unsignable))
            return
        }

        sendSignedData()
    }

    private func sendSignedData() {
        dataSource.signTransactionRequest(signature: signedData)

        asyncMain {
            [weak self] in
            guard let self else { return }

            self.stopLoading()

            self.delegate?.wcMainArbitraryDataScreen(
                self,
                didSigned: wcRequest,
                in: wcSession
            )
        }
    }

    func wcArbitraryDataSigner(
        _ wcArbitraryDataSigner: WCArbitraryDataSigner,
        didFailedWith error: WCArbitraryDataSigner.WCSignError
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            stopLoading()

            switch error {
            case .api(let error):
                displaySigningError(error)

                rejectSigning(reason: .rejected(.unsignable))
            case .missingData:
                displayGenericError()
            }
        }
    }
}

extension WCMainArbitraryDataScreen {
    private func displaySigningError(_ error: HIPTransactionError) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
        )
    }

    private func displayGenericError() {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "title-generic-error".localized
        )
    }
}

extension WCMainArbitraryDataScreen: WCSingleArbitraryDataRequestScreenDelegate {
    func wcSingleArbitraryDataRequestScreenDidReject(_ wcSingleArbitraryDataRequestScreen: WCSingleArbitraryDataRequestScreen) {
        rejectSigning()
    }

    func wcSingleArbitraryDataRequestScreenDidConfirm(_ wcSingleArbitraryDataRequestScreen: WCSingleArbitraryDataRequestScreen) {
        confirmSigning()
    }
}

extension WCMainArbitraryDataScreen: WCUnsignedArbitraryDataRequestScreenDelegate {
    func wcUnsignedArbitraryDataRequestScreenDidReject(_ wcUnsignedArbitraryDataRequestScreen: WCUnsignedArbitrayDataRequestScreen) {
        rejectSigning()
    }

    func wcUnsignedArbitraryDataRequestScreenDidConfirm(_ wcUnsignedArbitraryDataRequestScreen: WCUnsignedArbitrayDataRequestScreen) {
        confirmSigning()
    }
}

extension WCMainArbitraryDataScreen {
    private func rejectSigning(reason: WCTransactionErrorResponse = .rejected(.user)) {
        if isRejected { return }

        switch reason {
        case .rejected(let rejection):
            if rejection == .user {
                rejectData(with: reason)
            }
        default:
            showRejectionReasonBottomSheet(reason)
        }

        self.isRejected = true
    }

    private func showRejectionReasonBottomSheet(_ reason: WCTransactionErrorResponse) {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "title-error".localized,
            description: .plain("wallet-connect-no-account-for-transaction".localized(params: reason.message)),
            secondaryActionButtonTitle: "title-ok".localized,
            secondaryAction: {
                [weak self] in
                guard let self else { return  }
                self.rejectData(with: reason)
            }
        )

        asyncMain {
            [weak self] in
            guard let self else { return }

            transitionToRejectionReason.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func rejectData(with reason: WCTransactionErrorResponse) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            dataSource.rejectTransaction(reason: reason)

            stopLoading()

            delegate?.wcMainArbitraryDataScreen(self, didRejected: wcRequest)
        }
    }
}

extension WCMainArbitraryDataScreen {
    func rejectArbitraryDataRequest(with error: WCTransactionErrorResponse) {
        rejectSigning(reason: error)
    }
}

extension WCMainArbitraryDataScreen {
    private func startLoading() {
        asyncMain {
            [weak self] in
            guard let self else { return }
            loadingController?.startLoadingWithMessage("title-loading".localized)
        }
    }

    private func stopLoading() {
        asyncMain {
            [weak self] in
            guard let self else { return }
            loadingController?.stopLoading()
        }
    }
}

protocol WCMainArbitraryDataScreenDelegate: AnyObject {
    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    )
    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didRejected request: WalletConnectRequestDraft
    )
}
