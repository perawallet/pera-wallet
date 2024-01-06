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

//   AlgorandSecureBackupSuccessScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AlgorandSecureBackupSuccessScreen: ScrollScreen  {
    typealias EventHandler = (Event, AlgorandSecureBackupSuccessScreen) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var headerView = ResultWithHyperlinkView()
    private lazy var fileInfoView = FileInfoView()
    private lazy var saveActionView = MacaroonUIKit.Button(theme.saveActionLayout)
    private lazy var doneActionView = MacaroonUIKit.Button()

    private lazy var transitionToNotifyForStoringBackup = BottomSheetTransition(presentingViewController: self)

    private lazy var theme: AlgorandSecureBackupSuccessScreenTheme = .init()

    private lazy var documentURL = getDocumentsDirectory()

    private let backup: AlgorandSecureBackup
    private let bannerController: BannerController?
    private let copyToClipboardController: CopyToClipboardController

    deinit {
        removeFile()
    }

    init(backup: AlgorandSecureBackup, configuration: ViewControllerConfiguration) {
        self.backup = backup
        self.bannerController = configuration.bannerController
        self.copyToClipboardController = ALGCopyToClipboardController(toastPresentationController: configuration.toastPresentationController!)
        super.init(api: configuration.api)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        disableInteractivePopGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        enableInteractivePopGesture()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let closeButtonItem = ALGBarButtonItem(kind: .close(nil)) { [weak self] in
            guard let self else { return }
            self.performDone()
        }

        hidesCloseBarButtonItem = true

        leftBarButtonItems = [closeButtonItem]
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

    private func addUI() {
        addBackground()
        addContext()
        addSaveAction()
        addDoneAction()
    }
}

extension AlgorandSecureBackupSuccessScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addHeader()
        addFileInfo()
    }

    private func addHeader() {
        headerView.customize(theme.header)

        contextView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindHeader()

        headerView.startObserving(event: .performHyperlinkAction) {
            [unowned self] in
            self.open(AlgorandWeb.algorandSecureBackup.link)
        }
    }

    private func addFileInfo() {
        fileInfoView.customize(theme.fileInfo)
        
        contextView.addSubview(fileInfoView)
        fileInfoView.snp.makeConstraints {
            $0.top == headerView.snp.bottom + theme.spacingBetweenHeaderAndFileContent
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        fileInfoView.startObserving(event: .performCopyAction) { [weak self] in
            guard let self else { return }
            self.copyBackup()
        }

        bindFileInfo()
    }

    private func addSaveAction() {
        saveActionView.customizeAppearance(theme.saveAction)

        footerView.addSubview(saveActionView)
        saveActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        saveActionView.snp.makeConstraints {
            $0.top == theme.actionMargins.top
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
        }

        saveActionView.addTouch(
            target: self,
            action: #selector(performSave)
        )
    }

    private func addDoneAction() {
        doneActionView.customizeAppearance(theme.doneAction)

        footerView.addSubview(doneActionView)
        doneActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        doneActionView.snp.makeConstraints {
            $0.top == saveActionView.snp.bottom + theme.spacingBetweenActions
            $0.leading == theme.actionMargins.leading
            $0.bottom == theme.actionMargins.bottom
            $0.trailing == theme.actionMargins.trailing
        }

        doneActionView.addTouch(
            target: self,
            action: #selector(performDone)
        )
    }
}

extension AlgorandSecureBackupSuccessScreen {
    private func bindHeader() {
        let viewModel = AlgorandSecureBackupSuccessHeaderViewModel()
        headerView.bindData(viewModel)
    }

    private func bindFileInfo() {
        fileInfoView.bindData(FileInfoViewModel(file: backup))
    }
}

extension AlgorandSecureBackupSuccessScreen {
    private func copyBackup() {
        guard let backupData = backup.data else { return }
        let copyText = backupData.base64EncodedString()
        let copyInteraction = CopyToClipboardInteraction(title: "algorand-secure-backup-success-copy-action-message".localized, body: nil)
        let item = ClipboardItem(copy: copyText, interaction: copyInteraction)

        copyToClipboardController.copy(item)
    }

    @objc
    private func performSave() {
        do {
            let url = try createFile()
            openShareSheet(url)
        } catch {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    @objc
    private func performDone() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: "algorand-secure-backup-success-confirmation-title".localized,
            description: .plain("algorand-secure-backup-success-confirmation-message".localized),
            primaryActionButtonTitle: "algorand-secure-backup-success-confirmation-primary-action-title".localized,
            secondaryActionButtonTitle: "algorand-secure-backup-success-confirmation-secondary-action-title".localized,
            primaryAction: { [weak self] in
                guard let self else { return }
                self.eventHandler?(.complete, self)
            }
        )

        transitionToNotifyForStoringBackup.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func createFile() throws -> URL {
        guard let backupData = backup.data else {
            throw FileError.missingData
        }

        let backupString = backupData.base64EncodedString()

        let url = fileUrl()

        do {
            try backupString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            throw error
        }
    }

    private func openShareSheet(_ url: URL) {
        open(
            .shareActivity(
                items: [url]
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func removeFile() {
        try? FileManager.default.removeItem(at: fileUrl())
    }

    private func fileUrl() -> URL {
        let fileName = backup.fileName
        let url = documentURL.appendingPathComponent(fileName)
        return url
    }
}

extension AlgorandSecureBackupSuccessScreen {
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AlgorandSecureBackupSuccessScreen {
    enum Event {
        case complete
    }
}

enum FileError: Error {
    case missingData
}
