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

//   BuyAlgoHomeScreen.swift

import MacaroonUIKit
import UIKit
import SafariServices
import MacaroonUtils

final class BuyAlgoHomeScreen: BaseViewController, NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    weak var delegate: BuyAlgoHomeScreenDelegate?

    private lazy var contentView = BuyAlgoHomeView()

    private var buyAlgoDraft: BuyAlgoDraft

    init(draft: BuyAlgoDraft, configuration: ViewControllerConfiguration) {
        self.buyAlgoDraft = draft
        super.init(configuration: configuration)
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopObservingNotifications()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addContent()
    }
    
    override func setListeners() {
        super.setListeners()

        observe(notification: .didRedirectFromMoonPay) {
            [unowned self] notification in

            self.didRedirectFromMoonPay(notification)
        }
    }

    override func linkInteractors() {
        super.linkInteractors()

        contentView.startObserving(event: .close) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }

        contentView.startObserving(event: .buyAlgo) { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.api.isTestNet {
                self.presentTestNetAlert()
                return
            }

            self.analytics.track(.moonpay(type: .tapBuy))

            if self.buyAlgoDraft.hasValidAddress() {
                self.openMoonPay(for: self.buyAlgoDraft)
                return
            }

            let draft = SelectAccountDraft(
                transactionAction: .buyAlgo,
                requiresAssetSelection: false
            )

            self.open(
                .accountSelection(draft: draft, delegate: self),
                by: .push
            )
        }
    }
}

extension BuyAlgoHomeScreen {
    private func didRedirectFromMoonPay(_ notification: Notification) {
        guard
            let buyAlgoParams = notification.userInfo?[BuyAlgoParams.notificationObjectKey] as? BuyAlgoParams
        else {
            delegate?.buyAlgoHomeScreenDidFailedTransaction(self)
            return
        }

        analytics.track(.moonpay(type: .completed))
        delegate?.buyAlgoHomeScreen(self, didCompletedTransaction: buyAlgoParams)
    }
}

extension BuyAlgoHomeScreen {
    private func addContent() {
        contentView.customize(BuyAlgoHomeViewTheme())
        contentView.bindData(BuyAlgoHomeViewModel())
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension BuyAlgoHomeScreen: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        guard draft.transactionAction == .buyAlgo else {
            return
        }

        buyAlgoDraft.address = account.address

        openMoonPay(for: buyAlgoDraft)
    }

    private func openMoonPay(for draft: BuyAlgoDraft) {
        guard let address = draft.address else {
            return
        }

        let deeplinkURL = "\(target.deeplinkConfig.moonpay.scheme)://\(address)"
        let buyAlgoSignDraft = BuyAlgoSignDraft(walletAddress: address, redirectUrl: deeplinkURL)

        loadingController?.startLoadingWithMessage("title-loading".localized)

        api?.getSignedMoonpayURL(buyAlgoSignDraft) { [weak self] response in
            guard let self = self else {
                return
            }

            self.loadingController?.stopLoading()

            switch response {
            case .failure:
                break
            case let .success(response):
                if let url = response.url {
                    self.openMoonPay(url: url)
                }
            }
        }
    }

    private func openMoonPay(url: URL) {
        self.open(url)
    }
    
    private func presentTestNetAlert() {
        displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "moonpay-transaction-testnet-not-available-description".localized,
            handler: nil
        )
    }
}

protocol BuyAlgoHomeScreenDelegate: AnyObject {
    func buyAlgoHomeScreen(
        _ screen: BuyAlgoHomeScreen,
        didCompletedTransaction params: BuyAlgoParams
    )
    func buyAlgoHomeScreenDidFailedTransaction(
        _ screen: BuyAlgoHomeScreen
    )
}
