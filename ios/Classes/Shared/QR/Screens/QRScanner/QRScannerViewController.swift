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

final class QRScannerViewController:
    BaseViewController,
    NotificationObserver,
    PeraConnectObserver {
    static var didReset: Notification.Name {
        return .init(rawValue: "qrScannerViewController.reset")
    }
    static var didConnectWCSessionSuccessfully: Notification.Name {
        return .init(rawValue: "qrScannerViewController.wcSessionConnectionSuccessful")
    }

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

    private lazy var transitionToWCSessionList = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var overlayView = QRScannerOverlayView {
        [weak self] in
        guard let self else { return }

        $0.cancelMode = self.canGoBack() ? .pop : .dismiss
        $0.showsConnectedAppsButton = self.isShowingConnectedAppsButton
    }
    
    private var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: AVCaptureSession.description())
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var walletConnectSessionCreationPreferences: WalletConnectSessionCreationPreferences?
    private var wcConnectionRepeater: Repeater?

    private lazy var cameraResetHandler: EmptyHandler = {
        [weak self] in
        guard let self else { return }

        if captureSession?.isRunning == false {
            captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.startRunning()
            }
        }
    }
    
    private var isShowingConnectedAppsButton: Bool {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        return canReadWCSession && !sessions.isEmpty
    }

    private let canReadWCSession: Bool

    init(
        canReadWCSession: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.canReadWCSession = canReadWCSession

        super.init(configuration: configuration)
    }

    deinit {
        captureSession = nil
        
        stopWCConnectionTimer()
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.Defaults.background.uiColor

        peraConnect.add(self)

        observe(notification: Self.didReset) {
            [weak self] notification in
            guard let self else { return }
            
            let preferencesKey = ALGPeraConnect.sessionRequestPreferencesKey
            let preferences = notification.userInfo?[preferencesKey] as? WalletConnectSessionCreationPreferences
            guard let preferences,
                  hasSameOngoingConnectionRequest(preferences) else {
                return
            }

            enableCapturingIfNeeded()
        }
        observe(notification: Self.didConnectWCSessionSuccessfully) {
            [weak self] notification in
            guard let self else { return }
          
            let preferencesKey = ALGPeraConnect.sessionRequestPreferencesKey
            let preferences = notification.userInfo?[preferencesKey] as? WalletConnectSessionCreationPreferences
            guard let preferences,
                  hasSameOngoingConnectionRequest(preferences) else {
                return
            }

            closeScreen()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableCapturingIfNeeded()
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

        bindOverlayIfNeeded()
    }

    override func setListeners() {
        overlayView.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            guard let self else { return }
            self.enableCapturingIfNeeded()
        }
        observeWhenApplicationDidEnterBackground {
            [weak self] _ in
            guard let self else { return }
            self.disableCapturingIfNeeded()
        }
    }
}

extension QRScannerViewController {
    private func enableCapturingIfNeeded() {
        if captureSession?.isRunning == false &&
           UIApplication.shared.authStatus == .ready {
            captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.startRunning()
            }
        }
    }

    private func disableCapturingIfNeeded() {
        if captureSession?.isRunning == true {
            captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.stopRunning()
            }
        }
    }
}

extension QRScannerViewController {
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupCaptureSession()
            setupPreviewLayer()
            setupOverlayViewLayout()
        } else {
            AVCaptureDevice.requestAccess(for: .video) {
                [weak self] granted in
                guard let self else { return }

                if granted {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.setupOverlayViewLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
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

        guard let captureSession,
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
      
        displaySimpleAlertWith(
            title: "qr-scan-error-title".localized,
            message: "qr-scan-error-message".localized
        )
    }

    private func setupPreviewLayer() {
        guard let captureSession else { return  }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        guard let previewLayer else { return }

        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        captureSessionQueue.async {
            [weak captureSession] in
            guard let captureSession else { return }
            captureSession.startRunning()
        }
    }

    private func setupOverlayViewLayout() {
        overlayView.customize(QRScannerOverlayViewTheme())

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
            [weak self] in
            guard let self else { return }
            self.captureSession?.stopRunning()
        }

        guard let metadataObject = metadataObjects.first else {
            return
        }

        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let qrString = readableObject.stringValue,
              let qrStringData = qrString.data(using: .utf8) else {
            closeScreen()
            delegate?.qrScannerViewController(self, didFail: .invalidData, completionHandler: nil)
            return
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        if peraConnect.isValidSession(qrString) {
            if !canReadWCSession {
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "qr-scan-invalid-wc-screen-error".localized
                )

                closeScreen()
                return
            }

            let preferences = WalletConnectSessionCreationPreferences(session: qrString)

            walletConnectSessionCreationPreferences = preferences
            
            peraConnect.connectToSession(with: preferences)

            startWCConnectionTimer()
        } else if let qrBackupParameters = try? JSONDecoder().decode(QRBackupParameters.self, from: qrStringData) {
            closeScreen()
            delegate?.qrScannerViewController(self, didRead: qrBackupParameters, completionHandler: nil)
        } else if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
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
            closeScreen()
            delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
        } else if qrString.isValidatedAddress {
            let qrText = QRText(mode: .address, address: qrString)
            closeScreen()
            delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
        } else if let qrBackupParameters = try? JSONDecoder().decode(QRBackupParameters.self, from: qrStringData) {
            closeScreen()
            delegate?.qrScannerViewController(self, didRead: qrBackupParameters, completionHandler: nil)
        } else {
            delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
        }
    }
}

/// <mark>: PeraConnectObserver
extension QRScannerViewController {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .shouldStartV1(let session, let preferences, let completion):
            shouldStartPeraConnect(
                session: session,
                with: preferences,
                then: completion
            )
        case .proposeSessionV2(let proposal, let preferences):
            proposeSession(
                proposal,
                with: preferences
            )
        case .didConnectToV1:
            bindOverlayIfNeeded()
        case .settleSessionV2:
            bindOverlayIfNeeded()
        case .didDisconnectFromV1:
            bindOverlayIfNeeded()
        case .didDisconnectFromV1Fail(_, let error):
            if case .failedToDisconnectInactiveSession = error {
                bindOverlayIfNeeded()
                return
            }
        case .didDisconnectFromV2:
            bindOverlayIfNeeded()
        case .deleteSessionV2:
            bindOverlayIfNeeded()
        default:
            break
        }
    }
}

extension QRScannerViewController {
    private func shouldStartPeraConnect(
        session: WalletConnectSession,
        with preferences: WalletConnectSessionCreationPreferences,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        guard hasSameOngoingConnectionRequest(preferences) else { return  }

        stopWCConnectionTimer()
    }
}

extension QRScannerViewController {
    private func proposeSession(
        _ sessionProposal: WalletConnectV2SessionProposal,
        with preferences: WalletConnectSessionCreationPreferences
    ) {
        guard hasSameOngoingConnectionRequest(preferences) else { return }

        stopWCConnectionTimer()
    }
}

extension QRScannerViewController {
    private func hasSameOngoingConnectionRequest(_ preferences: WalletConnectSessionCreationPreferences) -> Bool {
        return walletConnectSessionCreationPreferences?.session == preferences.session
    }
}

extension QRScannerViewController {
    private func startWCConnectionTimer() {
        /// <note>
        /// We need to warn the user after 10 seconds if there's no resposne from the dApp.
        wcConnectionRepeater = Repeater(intervalInSeconds: 10.0) { 
            [weak self] in
            guard let self else { return }

            asyncMain { [weak self] in
                guard let self else { return }

                if self.captureSession?.isRunning == true {
                    self.captureSessionQueue.async {
                        [weak self] in
                        guard let self else { return }
                        self.captureSession?.stopRunning()
                    }
                }

                self.presentWCConnectionError()
            }

            self.stopWCConnectionTimer()
        }
        wcConnectionRepeater?.resume(immediately: false)
    }

    private func stopWCConnectionTimer() {
        wcConnectionRepeater?.invalidate()
        wcConnectionRepeater = nil
    }

    private func presentWCConnectionError() {
        bannerController?.presentErrorBanner(
            title: "title-failed-connection".localized,
            message: "wallet-connect-session-timeout-message".localized
        )
    }
}

extension QRScannerViewController: QRScannerOverlayViewDelegate {
    func qrScannerOverlayViewDidTapConnectedAppsButton(_ qrScannerOverlayView: QRScannerOverlayView) {
        let screen: WCSessionShortListViewController? = transitionToWCSessionList.perform(
            .walletConnectSessionShortList,
            by: .presentWithoutNavigationController
        )
        screen?.delegate = self
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
        bindOverlayIfNeeded()
    }
}

extension QRScannerViewController {
    private func bindOverlayIfNeeded() {
        guard isShowingConnectedAppsButton else {
            overlayView.bindData(nil)
            return
        }

        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        let viewModel = QRScannerOverlayViewModel(dAppCount: UInt(sessions.count))
        overlayView.bindData(viewModel)
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    )
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    )
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrBackupParameters: QRBackupParameters,
        completionHandler: EmptyHandler?
    )
}

extension QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {}
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {}
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrBackupParameters: QRBackupParameters,
        completionHandler: EmptyHandler?
    ) {}
}

enum QRScannerError: Swift.Error {
    case jsonSerialization
    case invalidData
}
