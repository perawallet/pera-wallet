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
//  QRScannerViewController.swift

import UIKit
import AVFoundation
import MacaroonUtils
import MacaroonUIKit

final class QRScannerViewController: BaseViewController, NotificationObserver {
    weak var delegate: QRScannerViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    var notificationObservations: [NSObjectProtocol] = []

    private lazy var wcConnectionModalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var overlayView = QRScannerOverlayView {
        [weak self] in
        guard let self = self else { return }

        $0.cancelMode = self.canGoBack() ? .pop : .dismiss
        $0.showsConnectedAppsButton = self.isShowingConnectedAppsButton
    }

    private var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var cameraResetHandler: EmptyHandler = {
        if self.captureSession?.isRunning == false {
            self.captureSessionQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }

    private let canReadWCSession: Bool
    private var dAppName: String? = nil
    private var wcConnectionRepeater: Repeater?

    private lazy var isShowingConnectedAppsButton: Bool = {
        canReadWCSession && !walletConnector.allWalletConnectSessions.isEmpty
    }()

    init(canReadWCSession: Bool, configuration: ViewControllerConfiguration) {
        self.canReadWCSession = canReadWCSession
        super.init(configuration: configuration)
    }

    deinit {
        wcConnectionRepeater?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableCapturingIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if canReadWCSession {
            walletConnector.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        disableCapturingIfNeeded()
    }

    override func prepareLayout() {
        super.prepareLayout()
        configureScannerView()
    }

    override func bindData() {
        super.bindData()

        if isShowingConnectedAppsButton {
            overlayView.bindData(
                QRScannerOverlayViewModel(dAppCount: UInt(walletConnector.allWalletConnectSessions.count))
            )
        }
    }

    override func setListeners() {
        overlayView.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()

        observeWhenApplicationDidEnterBackground {
            [weak self] _ in
            guard let self = self else { return }
            self.walletConnector.delegate = nil
            self.disableCapturingIfNeeded()
        }
    }
}

extension QRScannerViewController {
    private func enableCapturingIfNeeded() {
        if self.captureSession?.isRunning == false && UIApplication.shared.authStatus == .ready {
            self.captureSessionQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }

    private func disableCapturingIfNeeded() {
        if captureSession?.isRunning == true {
            captureSessionQueue.async {
                self.captureSession?.stopRunning()
            }
        }
    }
}

extension QRScannerViewController {
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCaptureSession()
            setupPreviewLayer()
            setupOverlayViewLayout()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.setupOverlayViewLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentDisabledCameraAlert()
                        self.setupOverlayViewLayout()
                    }
                }
            }
        }
    }
}

extension QRScannerViewController {
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            handleFailedState()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            handleFailedState()
            return
        }
    }

    private func presentDisabledCameraAlert() {
        let alertController = UIAlertController(
            title: "qr-scan-go-settings-title".localized,
            message: "qr-scan-go-settings-message".localized,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func handleFailedState() {
        captureSession = nil
        displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
    }

    private func setupPreviewLayer() {
        guard let captureSession = captureSession else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        guard let previewLayer = previewLayer else {
            return
        }

        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        captureSessionQueue.async {
            captureSession.startRunning()
        }
    }

    private func setupOverlayViewLayout() {
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension QRScannerViewController {
    private func closeScreen() {
        if canGoBack() {
            popScreen()
        } else {
            dismissScreen()
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        captureSessionQueue.async {
            self.captureSession?.stopRunning()
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let qrString = readableObject.stringValue,
                  let qrStringData = qrString.data(using: .utf8) else {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didFail: .invalidData, completionHandler: nil)
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            if qrString.isWalletConnectConnection {
                if !canReadWCSession {
                    bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "qr-scan-invalid-wc-screen-error".localized
                    )
                    captureSession = nil
                    closeScreen()
                    return
                }

                let preferences = WalletConnectorPreferences(session: qrString)

                walletConnector.delegate = self
                walletConnector.connect(with: preferences)
                startWCConnectionTimer()
            } else if let qrExportInformations = try? JSONDecoder().decode(QRExportInformations.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrExportInformations, completionHandler: nil)
            } else if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let url = URL(string: qrString),
                      let scheme = url.scheme,
                      target.deeplinkConfig.qr.canAcceptScheme(scheme) {

                let deeplinkQR = DeeplinkQR(url: url)
                guard let qrText = deeplinkQR.qrText() else {
                    delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                    return
                }
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if qrString.isValidatedAddress {
                let qrText = QRText(mode: .address, address: qrString)
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let qrExportInformations = try? JSONDecoder().decode(QRExportInformations.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrExportInformations, completionHandler: nil)
            } else {
                delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                return
            }
        }
    }
}

extension QRScannerViewController: WalletConnectorDelegate {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectorPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        stopWCConnectionTimer()
        let api = self.api!

        let sessionChainId = session.chainId(for: api.network)

        if !api.network.allowedChainIDs.contains(sessionChainId) {
            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-transaction-error-node".localized
                )
                
                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )
                
                self.resetUIForScanning()
            }
            return
        }

        let accounts = self.sharedDataController.accountCollection

        guard accounts.contains(where: { !$0.value.isWatchAccount() }) else {
            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
                
                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )
            }
            return
        }

        let shouldShowConnectionApproval = preferences?.prefersConnectionApproval ?? true

        dAppName = session.dAppInfo.peerMeta.name

        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            let wcConnectionScreen = self.wcConnectionModalTransition.perform(
                .wcConnection(
                    walletConnectSession: session,
                    completion: completion
                ),
                by: .present
            ) as? WCConnectionScreen
            
            wcConnectionScreen?.eventHandler = {
                [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .performCancel:
                    wcConnectionScreen?.dismissScreen()
                    self.resetUIForScanning()
                case .performConnect:
                    wcConnectionScreen?.dismiss(animated: true) {
                        [weak self] in
                        guard let self else { return }

                        if !shouldShowConnectionApproval { return }

                        self.presentWCSessionsApprovedModal()
                    }
                }
            }
        }
    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {
        delegate?.qrScannerViewControllerDidApproveWCConnection(self, session: session)
        walletConnector.saveConnectedWCSession(session)
        captureSession = nil
    }

    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error) {
        switch error {
        case .failedToConnect,
                .failedToCreateSession:

            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.resetUIForScanning()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-invalid-qr-message".localized
                )
                self.captureSession = nil
            }
        default:
            break
        }
    }

    private func startWCConnectionTimer() {
        /// We need to warn the user after 10 seconds if there's no resposne from the dApp.
        wcConnectionRepeater = Repeater(intervalInSeconds: 10.0) { [weak self] in
            guard let self = self else {
                return
            }

            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                if self.captureSession?.isRunning == true {
                    self.captureSessionQueue.async {
                        self.captureSession?.stopRunning()
                    }
                }

                self.openWCConnectionError()
            }

            self.stopWCConnectionTimer()
        }

        wcConnectionRepeater?.resume(immediately: false)
    }

    private func stopWCConnectionTimer() {
        wcConnectionRepeater?.invalidate()
        wcConnectionRepeater = nil
    }

    private func openWCConnectionError() {
        let bottomTransition = BottomSheetTransition(presentingViewController: self)

        bottomTransition.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-red".uiImage,
                    title: "title-failed-connection".localized,
                    description: .plain("wallet-connect-session-timeout-message".localized),
                    secondaryActionButtonTitle: "title-close".localized
                )
            ),
            by: .presentWithoutNavigationController,
            completion: {
                [weak self] in
                self?.resetUIForScanning()
            }
        )
    }
}


extension QRScannerViewController {
    private func resetUIForScanning() {
        captureSessionQueue.async {
            self.captureSession?.startRunning()
        }
    }

    private func presentWCSessionsApprovedModal() {
        guard let dAppName = dAppName else { return }

        wcConnectionModalTransition.perform(
            .bottomWarning(
                configurator:
                    BottomWarningViewConfigurator(
                        image: "icon-check-positive".uiImage,
                        title: "wallet-connect-session-connection-approved-title".localized(dAppName),
                        description: .plain(
                            "wallet-connect-session-connection-approved-description".localized(dAppName)
                        ),
                        secondaryActionButtonTitle: "title-close".localized,
                        secondaryAction: { [weak self] in
                            self?.closeScreen()
                        }
                    )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension QRScannerViewController: QRScannerOverlayViewDelegate {
    func qrScannerOverlayViewDidTapConnectedAppsButton(_ qrScannerOverlayView: QRScannerOverlayView) {
        let walletConnectSessionsShortList: WCSessionShortListViewController? = wcConnectionModalTransition.perform(
            .walletConnectSessionShortList,
            by: .presentWithoutNavigationController
        )
        walletConnectSessionsShortList?.delegate = self
    }

    func qrScannerOverlayView(
        _ qrScannerOverlayView: QRScannerOverlayView,
        didCancel mode: QRScannerOverlayView.Configuration.CancelMode
    ) {
        switch mode {
        case .pop: popScreen()
        case .dismiss: dismissScreen()
        }
    }
}

extension QRScannerViewController: WCSessionShortListViewControllerDelegate {
    func wcSessionShortListViewControllerDidClose(_ controller: WCSessionShortListViewController) {
        overlayView.bindData(
            QRScannerOverlayViewModel(dAppCount: UInt(walletConnector.allWalletConnectSessions.count))
        )
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerViewControllerDidApproveWCConnection(_ controller: QRScannerViewController, session: WCSession)
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrExportInformations: QRExportInformations, completionHandler: EmptyHandler?)
}

extension QRScannerViewControllerDelegate {
    func qrScannerViewControllerDidApproveWCConnection(_ controller: QRScannerViewController, session: WCSession) {}
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {}
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {}
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrExportInformations: QRExportInformations, completionHandler: EmptyHandler?) {}
}

enum QRScannerError: Swift.Error {
    case jsonSerialization
    case invalidData
}
