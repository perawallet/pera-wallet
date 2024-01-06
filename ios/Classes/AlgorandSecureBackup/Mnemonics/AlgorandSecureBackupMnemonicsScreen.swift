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

//   AlgorandSecureBackupMnemonicsScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupMnemonicsScreen:
    BaseScrollViewController,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, AlgorandSecureBackupMnemonicsScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()
    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private lazy var transitionToNotifyForStoringKey = BottomSheetTransition(presentingViewController: self)

    private lazy var headerView = UILabel()
    private lazy var peraLearnView = ALGActiveLabel()
    private lazy var passphraseBackupView = PassphraseView()
    private lazy var actionsView = VStackView()
    private lazy var copyActionView = MacaroonUIKit.Button()
    private lazy var regeneratePassphraseActionView = MacaroonUIKit.Button()
    private lazy var storeActionView = MacaroonUIKit.Button()

    private lazy var theme: AlgorandSecureBackupMnemonicsScreenTheme = .init()

    private lazy var viewModel = AlgorandSecureBackupMnemonicViewModel(session: session!)

    private lazy var mnemonics = createMnemonics()

    private var isViewLayoutLoaded = false

    private let accounts: [Account]

    private lazy var copyToClipboardController = ALGCopyToClipboardController(toastPresentationController: toastPresentationController!)

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    init(accounts: [Account], configuration: ViewControllerConfiguration) {
        self.accounts = accounts
        super.init(configuration: configuration)
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()

        passphraseBackupView.setPassphraseCollectionViewDelegate(self)
        passphraseBackupView.setPassphraseCollectionViewDataSource(self)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = viewModel.title
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLayoutLoaded {
            return
        }

        updateUIWhenViewDidLayoutSubviews()

        isViewLayoutLoaded = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
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

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addHeader()
        addPeraLearn()
        addPassphrase()
        addActions()
        addStoreAction()
    }
}

// MARK: SDK Functions
extension AlgorandSecureBackupMnemonicsScreen {
    private func createMnemonics() -> [String]? {
        let privateKey = fetchPrivateKey() ?? generateBackupPrivateKey()

        guard let privateKey else {
            return nil
        }

        let mnemonics = generateMnemonics(from: privateKey)
        return mnemonics
    }

    private func fetchPrivateKey() -> Data? {
        session?.privateDataForBackup()
    }

    /// <note>: Returning Optional Data
    /// It returns optional data because of Go Bind functions converts the original go function
    /// Into Optional Function
    private func generateBackupPrivateKey() -> Data? {
        guard let data = AlgorandSDK().generateBackupPrivateKey() else {
            return nil
        }

        session?.saveBackupPrivateData(data)
        return data
    }

    private func generateMnemonics(from privateKey: Data) -> [String] {
        var error: NSError?
        let mnemonicsString = AlgorandSDK().backupMnemnoic(fromPrivateKey: privateKey, error: &error)

        guard error == nil else {
            // Error will be filled when wrong private key passed into `backupMnemonic` function
            return []
        }

        let mnemonics = mnemonicsString.components(separatedBy: " ")
        return mnemonics
    }
}

// MARK: UI functions
extension AlgorandSecureBackupMnemonicsScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func addHeader() {
        headerView.customizeAppearance(theme.header)

        contentView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == theme.defaultInset
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
        }

        bindHeader()
    }

    private func addPeraLearn() {
        peraLearnView.customizeAppearance(theme.header)

        contentView.addSubview(peraLearnView)
        peraLearnView.snp.makeConstraints {
            $0.top == headerView.snp.bottom + theme.peraLearnTopOffset
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
        }

        bindPeraLearn()
    }

    private func addPassphrase() {
        passphraseBackupView.customize(theme.passphraseBackUpViewTheme.passphraseViewTheme)

        contentView.addSubview(passphraseBackupView)
        passphraseBackupView.snp.makeConstraints {
            $0.top.equalTo(peraLearnView.snp.bottom).offset(theme.passphraseTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.passphraseHeight)
        }
    }

    private func addActions() {
        contentView.addSubview(actionsView)
        actionsView.spacing = theme.actionsPadding
        actionsView.snp.makeConstraints {
            $0.top.equalTo(passphraseBackupView.snp.bottom).offset(theme.actionsTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.bottom.greaterThanOrEqualToSuperview().inset(theme.defaultInset)
        }
        addCopyAction()
        addRegeneratePassphraseAction()
    }

    private func addCopyAction() {
        copyActionView.customizeAppearance(theme.copyAction)
        copyActionView.titleEdgeInsets = theme.copyActionTitleEdgeInsets

        copyActionView.addTouch(
            target: self,
            action: #selector(performCopyAction)
        )

        actionsView.addArrangedSubview(copyActionView)
        bindCopyAction()
    }

    private func addRegeneratePassphraseAction() {
        regeneratePassphraseActionView.customizeAppearance(theme.regenerateKeyAction)
        regeneratePassphraseActionView.titleEdgeInsets = theme.regenerateKeyActionTitleEdgeInsets

        regeneratePassphraseActionView.addTouch(
            target: self,
            action: #selector(performRegenerateKeyAction)
        )

        actionsView.addArrangedSubview(regeneratePassphraseActionView)
        bindRegeneratePassphraseAction()
    }

    private func addStoreAction() {
        storeActionView.customizeAppearance(theme.storeAction)
        storeActionView.contentEdgeInsets = theme.storeActionContentEdgeInsets

        footerView.addSubview(storeActionView)
        storeActionView.snp.makeConstraints {
            $0.top == theme.storeActionEdgeInsets.top
            $0.leading == theme.storeActionEdgeInsets.leading
            $0.trailing == theme.storeActionEdgeInsets.trailing
            $0.bottom == theme.storeActionEdgeInsets.bottom
        }

        storeActionView.addTouch(
            target: self,
            action: #selector(performStoreAction)
        )
    }
}

extension AlgorandSecureBackupMnemonicsScreen {
    private func bindHeader() {
        guard let header = viewModel.header else {
            headerView.text = nil
            headerView.attributedText = nil
            return
        }

        header.load(in: headerView)
    }

    private func bindPeraLearn() {
        guard let peraLearn = viewModel.peraLearn else {
            peraLearnView.text = nil
            peraLearnView.attributedText = nil
            return
        }

        let link: ALGActiveType = .word(peraLearn.highlihtedText.string)
        peraLearnView.attachHyperlink(link, to: peraLearn.text, attributes: peraLearn.highlightedTextAttributes) {
            [unowned self] in
            self.open(AlgorandWeb.algorandSecureBackup.link)
        }
    }

    private func bindCopyAction() {
    }

    private func bindRegeneratePassphraseAction() {
        regeneratePassphraseActionView.isHidden = !viewModel.isGenerationAvailable
    }
}

// MARK: UICollectionView
extension AlgorandSecureBackupMnemonicsScreen: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mnemonics?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PassphraseCell.self, at: indexPath)
        let passphrase = Passphrase(index: indexPath.item, mnemonics: mnemonics)
        cell.bindData(PassphraseCellViewModel(passphrase))
        return cell
    }
}

extension AlgorandSecureBackupMnemonicsScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: theme.cellHeight)
    }
}

// MARK: Helpers
extension AlgorandSecureBackupMnemonicsScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews() {
        scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension AlgorandSecureBackupMnemonicsScreen {
    @objc
    private func performCopyAction() {
        guard let mnemonics else { return }
        let copyText = mnemonics.joined(separator: " ")
        let copyInteraction = CopyToClipboardInteraction(title: "algorand-secure-backup-mnemonics-copy-action-message".localized, body: nil)
        let item = ClipboardItem(copy: copyText, interaction: copyInteraction)

        copyToClipboardController.copy(item)
    }

    @objc
    private func performRegenerateKeyAction() {
        let configurator = BottomWarningViewConfigurator(
            image: "algorand-secure-backup-big-key".uiImage,
            title: "algorand-secure-backup-mnemonics-regenerate-confirmation-title".localized,
            description: .plain("algorand-secure-backup-mnemonics-regenerate-confirmation-message".localized),
            primaryActionButtonTitle: "algorand-secure-backup-mnemonics-regenerate-confirmation-primary-action-title".localized,
            secondaryActionButtonTitle: "algorand-secure-backup-mnemonics-regenerate-confirmation-secondary-action-title".localized,
            primaryAction: { [weak self] in
                guard let self else { return }
                self.generateNewKey()
            }
        )

        transitionToNotifyForStoringKey.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func generateNewKey() {
        guard let generatedData = generateBackupPrivateKey() else {
            return
        }

        mnemonics = generateMnemonics(from: generatedData)
        passphraseBackupView.reloadData()
    }

    @objc
    private func performStoreAction() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: "algorand-secure-backup-mnemonics-confirmation-title".localized,
            description: .plain("algorand-secure-backup-mnemonics-confirmation-message".localized),
            primaryActionButtonTitle: "algorand-secure-backup-mnemonics-confirmation-primary-action-title".localized,
            secondaryActionButtonTitle: "algorand-secure-backup-mnemonics-confirmation-secondary-action-title".localized,
            primaryAction: { [weak self] in
                guard let self else { return }
                self.generateBackup()
            }
        )

        transitionToNotifyForStoringKey.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func generateBackup() {
        let algorandSDK = AlgorandSDK()
        guard let privateKey = fetchPrivateKey(),
              let cipherText = algorandSDK.generateBackupCipherKey(data: privateKey)else {
            eventHandler?(.backupFailed(.missingData), self)
            return
        }

        let cryptor = Cryptor(data: cipherText)
        let backupParameters = BackupParameters(accounts: getAccountImportParameters())
        do {
            let encryptedData = try cryptor.encrypt(data: backupParameters.encoded())

            if let data = encryptedData.data {
                let secureBackup = SecureBackup(data: data)
                let secureBackupData = try secureBackup.encoded()
                eventHandler?(.backupCompleted(secureBackupData), self)
            } else {
                let error: Event.Error = encryptedData.error.unwrap { .encryption($0) } ?? .unknown
                eventHandler?(.backupFailed(error), self)
            }
        } catch {
            self.eventHandler?(.backupFailed(.other(error)), self)
        }
    }

    private func getAccountImportParameters() -> [AccountImportParameters] {
        accounts.map { account in
            let privateKey = session?.privateData(for: account.address)
            return .init(
                account: account,
                privateKey: privateKey
            )
        }
    }
}

extension AlgorandSecureBackupMnemonicsScreen {
    enum Event {
        case backupCompleted(Data)
        case backupFailed(Error)

        enum Error {
            case encryption(EncryptionError)
            case other(Swift.Error)
            case unknown
            case missingData
        }
    }
}

