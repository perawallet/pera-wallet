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

//   MoonPayIntroductionScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class MoonPayIntroductionScreen: ScrollScreen {
    weak var delegate: MoonPayIntroductionScreenDelegate?

    private lazy var illustrationView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var bodyView = UILabel()
    private lazy var securedByPaymentOptionsView = SecuredByPaymentOptionsView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private lazy var theme = MoonPayIntroductionScreenTheme()

    private let moonPayDraft: MoonPayDraft
    private let target: ALGAppTarget
    private let analytics: ALGAnalytics
    private let loadingController: LoadingController

    init(
        draft: MoonPayDraft,
        api: ALGAPI,
        target: ALGAppTarget,
        analytics: ALGAnalytics,
        loadingController: LoadingController
    ) {
        self.moonPayDraft = draft
        self.target = target
        self.analytics = analytics
        self.loadingController = loadingController
        
        super.init(api: api)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        stopObservingNotifications()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        hidesCloseBarButtonItem = true

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "moonpay-introduction-title".localized

        addNavigationBarButtonItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switchToTransparentNavigationBarAppearanceIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        switchToDefaultNavigationBarAppearanceIfNeeded()
    }

    override func startObservingNotifications() {
        super.startObservingNotifications()

        observe(notification: .didRedirectFromMoonPay) {
            [unowned self] notification in
            self.didRedirectFromMoonPay(notification)
        }
    }

    override func setListeners() {
        super.setListeners()

        observe(notification: .didRedirectFromMoonPay) {
            [unowned self] notification in
            self.didRedirectFromMoonPay(notification)
        }
    }

    override func addScroll() {
        super.addScroll()

        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? .zero
        scrollView.contentInset.top = theme.illustrationMaxHeight - navigationBarHeight
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        updateUIWhenViewDidScroll()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateUIWhenViewDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateUIWhenViewDidScroll()
    }
}

extension MoonPayIntroductionScreen {
    private func updateUIWhenViewDidScroll() {
        updateIllustrationWhenViewDidScroll()
    }

    private func updateIllustrationWhenViewDidScroll() {
        let contentY = scrollView.contentOffset.y
        let preferredHeight = -contentY

        illustrationView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, theme.illustrationMinHeight))
        }
    }
}

extension MoonPayIntroductionScreen {
    private func switchToTransparentNavigationBarAppearanceIfNeeded() {
        guard let navigationController else { return }

        if !navigationController.isBeingPresented || isViewFirstAppeared {
            switchToTransparentNavigationBarAppearance()
        }
    }

    private func switchToDefaultNavigationBarAppearanceIfNeeded() {
        guard let navigationController else { return }

        if !navigationController.isBeingDismissed {
            switchToDefaultNavigationBarAppearance()
        }
    }
}

extension MoonPayIntroductionScreen {
    private func addNavigationBarButtonItems() {
        leftBarButtonItems = [ makeCloseNavigationBarButtonItem() ]
    }

    private func makeCloseNavigationBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .close(UIColor.white)) {
            [unowned self] in
            self.dismissScreen()
        }
    }
}

extension MoonPayIntroductionScreen {
    private func addUI() {
        addIllustration()
        addTitle()
        addBody()
        addSecuredByPaymentOptions()
        addPrimaryAction()
    }

    private func addIllustration() {
        illustrationView.customizeAppearance(theme.illustration)
        illustrationView.clipsToBounds = true
        illustrationView.isUserInteractionEnabled = false

        view.addSubview(illustrationView)
        illustrationView.snp.makeConstraints {
            $0.fitToHeight(theme.illustrationMaxHeight)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIllustrationLogo()
        addIllustrationBackground()
    }

    private func addIllustrationLogo() {
        let canvasView = UIView()
        let logoView = UIImageView()
        logoView.customizeAppearance(theme.illustrationLogo)

        illustrationView.addSubview(canvasView)
        canvasView.snp.makeConstraints {
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? .zero
            $0.top == navigationBarHeight
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
        canvasView.addSubview(logoView)
        logoView.snp.makeConstraints {
            $0.center == 0
        }
    }
    
    private func addIllustrationBackground() {
        let backgroundView = GradientView()
        backgroundView.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]
        backgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            backgroundView,
            belowSubview: illustrationView
        )
        backgroundView.snp.makeConstraints {
            let height = theme.titleTopInset
            $0.fitToHeight(height)

            $0.top == illustrationView.snp.bottom
            $0.leading == illustrationView
            $0.trailing == illustrationView
        }
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopInset
            $0.leading == theme.titleHorizontalEdgeInsets.leading
            $0.trailing == theme.titleHorizontalEdgeInsets.trailing
        }

        bindTitle()
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addSecuredByPaymentOptions() {
        securedByPaymentOptionsView.customize(theme.securedByPaymentOptions)

        contentView.addSubview(securedByPaymentOptionsView)
        securedByPaymentOptionsView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndSecuredByPaymentOptions
            $0.leading == theme.securedByPaymentOptionsHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.securedByPaymentOptionsHorizontalEdgeInsets.trailing
        }

        bindSecuredByPaymentOptions()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        footerView.addSubview(primaryActionView)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets
        primaryActionView.snp.makeConstraints {
            $0.top == theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.bottom == theme.primaryActionEdgeInsets.bottom
            $0.trailing == theme.primaryActionEdgeInsets.trailing
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }
}

extension MoonPayIntroductionScreen {
    private func bindTitle() {
        titleView.attributedText =
            "moonpay-buy-button-title"
                .localized
                .titleMedium()
    }

    private func bindBody() {
        bodyView.attributedText =
            "moonpay-introduction-description"
                .localized
                .bodyRegular()
    }

    private func bindSecuredByPaymentOptions() {
        let options: [PaymentOption] = [.mastercard, .visa, .apple]
        let viewModel = SecuredByPaymentOptionsViewModel(options)
        securedByPaymentOptionsView.bindData(viewModel)
    }
}

extension MoonPayIntroductionScreen {
    private func didRedirectFromMoonPay(_ notification: Notification) {
        guard
            let moonPayParams = notification.userInfo?[MoonPayParams.notificationObjectKey] as? MoonPayParams
        else {
            delegate?.moonPayIntroductionScreenDidFailedTransaction(self)
            return
        }

        analytics.track(.moonPay(type: .completed))
        delegate?.moonPayIntroductionScreen(self, didCompletedTransaction: moonPayParams)
    }
}

extension MoonPayIntroductionScreen {
    @objc
    private func performPrimaryAction() {
        if api.isTestNet {
            presentTestNetAlert()
            return
        }

        analytics.track(.moonPay(type: .tapBuy))

        if moonPayDraft.hasValidAddress() {
            openMoonPay(for: moonPayDraft)
            return
        }

        openAccountSelection()
    }

    private func openAccountSelection() {
        let screen = Screen.transakAccountSelection {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let account):
                let moonPayDraft = MoonPayDraft()
                moonPayDraft.address = account.value.address
                self.openMoonPay(for: moonPayDraft)
            default:
                break
            }
        }

        open(
            screen,
            by: .push
        )
    }
}

extension MoonPayIntroductionScreen {
    private func openMoonPay(for draft: MoonPayDraft) {
        guard let address = draft.address else {
            return
        }

        let deeplinkURL = "\(target.deeplinkConfig.moonpay.scheme)://\(address)"
        let moonPaySignDraft = MoonPaySignDraft(walletAddress: address, redirectUrl: deeplinkURL)

        loadingController.startLoadingWithMessage("title-loading".localized)

        api?.getSignedMoonPayURL(moonPaySignDraft) {
            [weak self] response in
            guard let self else {
                return
            }

            self.loadingController.stopLoading()

            switch response {
            case .success(let response):
                self.open(response.url.toURL())
            case .failure:
                break
            }
        }
    }
}

extension MoonPayIntroductionScreen {
    private func presentTestNetAlert() {
        displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "moonpay-transaction-testnet-not-available-description".localized
        )
    }
}

protocol MoonPayIntroductionScreenDelegate: AnyObject {
    func moonPayIntroductionScreen(
        _ screen: MoonPayIntroductionScreen,
        didCompletedTransaction params: MoonPayParams
    )
    func moonPayIntroductionScreenDidFailedTransaction(
        _ screen: MoonPayIntroductionScreen
    )
}
