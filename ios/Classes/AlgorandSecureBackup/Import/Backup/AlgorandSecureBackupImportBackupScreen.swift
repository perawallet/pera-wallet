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

//   AlgorandSecureBackupImportBackupScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupImportBackupScreen:
    BaseScrollViewController,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, AlgorandSecureBackupImportBackupScreen) -> Void

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

    private lazy var headerView = UILabel()
    private lazy var fileView = AlgorandSecureBackupFileView()
    private lazy var actionsView = VStackView()
    private lazy var pasteActionView = MacaroonUIKit.Button()
    private lazy var nextActionView = MacaroonUIKit.Button()

    private lazy var theme: AlgorandSecureBackupImportBackupScreenTheme = .init()

    private var isViewLayoutLoaded = false

    private var selectedSecureBackup: SecureBackup?

    private let backupValidator = BackupValidator()

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = theme.navigationTitle
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
        bindData()
    }

    override func linkInteractors() {
        super.linkInteractors()

        fileView.startObserving(event: .performClickContent) { [weak self] in
            guard let self else { return }

            // It prevents opening document picker if there is already a selected backup
            // In this state, action will be only tappable.
            if self.selectedSecureBackup != nil {
                return
            }

            self.open(.importTextDocumentPicker(delegate: self), by: .presentWithoutNavigationController)
        }

        fileView.startObserving(event: .performClickAction) { [weak self] in
            guard let self else { return }
            self.open(.importTextDocumentPicker(delegate: self), by: .presentWithoutNavigationController)
        }
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
        addFileView()
        addPasteAction()
        addNextAction()

        bindFile(for: .empty)
    }
}

// MARK: UI functions
extension AlgorandSecureBackupImportBackupScreen {
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
    }

    private func addFileView() {
        fileView.customize(AlgorandSecureBackupFileViewTheme())

        contentView.addSubview(fileView)
        fileView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(theme.uploadTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.uploadHeight)
        }
    }

    private func addPasteAction() {
        pasteActionView.customizeAppearance(theme.pasteAction)
        pasteActionView.titleEdgeInsets = theme.pasteActionTitleEdgeInsets

        pasteActionView.addTouch(
            target: self,
            action: #selector(performPasteAction)
        )

        contentView.addSubview(pasteActionView)
        pasteActionView.snp.makeConstraints {
            $0.top.equalTo(fileView.snp.bottom).offset(theme.actionsTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.bottom.greaterThanOrEqualToSuperview().inset(theme.defaultInset)
        }
    }

    private func addNextAction() {
        nextActionView.customizeAppearance(theme.nextAction)
        nextActionView.contentEdgeInsets = theme.nextActionContentEdgeInsets

        footerView.addSubview(nextActionView)
        nextActionView.snp.makeConstraints {
            $0.top == theme.nextActionEdgeInsets.top
            $0.leading == theme.nextActionEdgeInsets.leading
            $0.trailing == theme.nextActionEdgeInsets.trailing
            $0.bottom == theme.nextActionEdgeInsets.bottom
        }

        nextActionView.addTouch(
            target: self,
            action: #selector(performNextAction)
        )

        nextActionView.isEnabled = false
    }
}

// MARK: Helpers
extension AlgorandSecureBackupImportBackupScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews() {
        scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    @objc
    private func performPasteAction() {
        loadingController?.startLoadingWithMessage("title-loading".localized)
        let pasteBoardText = UIPasteboard.general.string
        loadingController?.stopLoading()

        let validation = backupValidator.validate(invalidatedString: pasteBoardText)

        switch validation {
        case .success(let secureBackup):
            bannerController?.presentSuccessBanner(
                title: "algorand-secure-backup-import-backup-clipboard-success-title".localized
            )

            eventHandler?(.backupSelected(secureBackup), self)
        case .failure(let backupValidationError):
            presentErrorBanner(error: backupValidationError)
        }
    }

    @objc
    private func performNextAction() {
        guard let selectedSecureBackup else {
            presentErrorBanner(error: .jsonSerialization)
            return
        }

        eventHandler?(.backupSelected(selectedSecureBackup), self)
    }
}

extension AlgorandSecureBackupImportBackupScreen: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            presentErrorBanner(error: .emptySource)
            return
        }
        processBackupFile(at: url)
    }

    private func processBackupFile(at url: URL) {
        nextActionView.isEnabled = false

        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        guard hasAccess else {
            bindFile(for: .uploadFailed(.unauthorized))
            return
        }

        let invalidatedString = try? String(contentsOf: url)
        let validation = backupValidator.validate(invalidatedString: invalidatedString)

        switch validation {
        case .success(let secureBackup):
            let fileName: String

            do {
                fileName = try AlgorandSecureBackup(url: url).fileName
            } catch {
                bindFile(for: .uploadFailed(.cipherSuiteUnknown))
                return
            }

            bindFile(for: .uploaded(fileName: fileName))
            nextActionView.isEnabled = true
            selectedSecureBackup = secureBackup
        case .failure(let backupValidationError):
            bindFile(for: .uploadFailed(backupValidationError))
        }
    }

    private func bindFile(for state: AlgorandSecureBackupFileViewModel.State) {
        let viewModel = AlgorandSecureBackupFileViewModel(state: state)
        fileView.bindData(viewModel)
    }
}

/// <mark>: Error Handling
extension AlgorandSecureBackupImportBackupScreen {
    private func presentErrorBanner(error: BackupValidationError) {
        let title: String
        let message: String

        switch error {
        case .emptySource:
            title = "algorand-secure-backup-import-backup-clipboard-failed-title".localized
            message = "algorand-secure-backup-import-backup-clipboard-failed-subtitle".localized
        case .wrongFormat:
            title = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
            message = ""
        case .unsupportedVersion:
            title = "algorand-secure-backup-import-backup-clipboard-version-failed-title".localized
            message = ""
        case .cipherSuiteUnknown:
            title = "algorand-secure-backup-import-backup-clipboard-cipher-suite-failed-title".localized
            message = ""
        case .jsonSerialization:
            title = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
            message = ""
        case .unauthorized:
            title = "algorand-secure-backup-import-backup-clipboard-unauthorized-failed-title".localized
            message = ""
        case .keyNotFound(let key):
            title = "algorand-secure-backup-import-backup-clipboard-key-not-exist".localized(params: key)
            message = ""
        }

        bannerController?.presentErrorBanner(
            title: title,
            message: message
        )
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum Event {
        case backupSelected(SecureBackup)
    }
}
