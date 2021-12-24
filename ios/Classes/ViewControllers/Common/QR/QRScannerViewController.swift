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
//  QRScannerViewController.swift

import UIKit
import AVFoundation
import Macaroon

class QRScannerViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }

    private lazy var wcConnectionModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 454.0))
    )

    private lazy var wcConnectionErrorModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 360.0))
    )
    
    weak var delegate: QRScannerViewControllerDelegate?
    
    private(set) lazy var overlayView = QRScannerOverlayView()

    private lazy var cancelButton = LoadingButton(.none, loadingIndicator: UIActivityIndicatorView(style: .white))
    
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

    private var wcConnectionRepeater: Repeater?

    private let canReadWCSession: Bool

    init(canReadWCSession: Bool, configuration: ViewControllerConfiguration) {
        self.canReadWCSession = canReadWCSession
        super.init(configuration: configuration)
    }

    deinit {
        wcConnectionRepeater?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.captureSession?.isRunning == false {
            self.captureSessionQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        walletConnector.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSessionQueue.async {
                self.captureSession?.stopRunning()
            }
        }
    }

    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(closeScreenFromButton), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        configureScannerView()
    }
}

extension QRScannerViewController {
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCaptureSession()
            setupPreviewLayer()
            setupOverlayViewLayout()
            setupCancelButtonLayout()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.setupOverlayViewLayout()
                        self.setupCancelButtonLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentDisabledCameraAlert()
                        self.setupOverlayViewLayout()
                        self.setupCancelButtonLayout()
                    }
                }
            }
        }
    }

    private func setupCancelButtonLayout() {
        view.addSubview(cancelButton)
        customizeButtonAppearance()

        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.buttonVerticalInset + view.safeAreaBottom)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }

    private func customizeButtonAppearance() {
        cancelButton.setBackgroundImage(img("button-bg-scan-qr"), for: .normal)
        cancelButton.setTitle("title-cancel".localized, for: .normal)
        cancelButton.setTitleColor(Colors.Main.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
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
        overlayView.frame = view.frame
    }
}

extension QRScannerViewController {
    @objc
    private func closeScreenFromButton() {
        closeScreen(by: .pop)
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
                    closeScreen(by: .pop)
                    delegate?.qrScannerViewController(self, didFail: .invalidData, completionHandler: nil)
                    return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            if qrString.isWalletConnectConnection {
                if !canReadWCSession {
                    NotificationBanner.showError("title-error".localized, message: "qr-scan-invalid-wc-screen-error".localized)
                    captureSession = nil
                    closeScreen(by: .pop)
                    return
                }

                walletConnector.delegate = self
                cancelButton.startLoading()
                cancelButton.setBackgroundImage(img("button-bg-scan-qr"), for: .normal)
                walletConnector.connect(to: qrString)
                startWCConnectionTimer()
            } else if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let url = URL(string: qrString),
                qrString.hasPrefix("algorand://") {
                guard let qrText = url.buildQRText() else {
                    delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                    return
                }
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if AlgorandSDK().isValidAddress(qrString) {
                let qrText = QRText(mode: .address, address: qrString)
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
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
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        stopWCConnectionTimer()

        guard let accounts = self.session?.accounts,
              accounts.contains(where: { $0.type != .watch }) else {
                  asyncMain { [weak self] in
                      guard self != nil else {
                          return
                      }

                      NotificationBanner.showError("title-error".localized, message: "wallet-connect-session-error-no-account".localized)
                  }
            return
        }

        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            let controller = self.open(
                .wcConnectionApproval(walletConnectSession: session, completion: completion),
                by: .customPresent(
                    presentationStyle: .custom,
                    transitionStyle: nil,
                    transitioningDelegate: self.wcConnectionModalPresenter
                )
            ) as? WCConnectionApprovalViewController
            controller?.delegate = self
        }
    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {
        delegate?.qrScannerViewControllerDidApproveWCConnection(self)
        walletConnector.saveConnectedWCSession(session)
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.captureSession = nil
            self.cancelButton.stopLoading()
            self.closeScreen(by: .pop)
        }
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
                NotificationBanner.showError("title-error".localized, message: "wallet-connect-session-invalid-qr-message".localized)
                self.captureSession = nil
                self.closeScreen(by: .pop)
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
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: wcConnectionErrorModalPresenter
        )

        // swiftlint:disable line_length
        /// <todo>
        /// These texts will be localized later.
        let message = "We are sorry, but the dApp is not responding. Please refresh the page and try scanning a new QR Code. If the error persists, please contact the dApp."
        // swiftlint:enable line_length
        let warningAlert = WarningAlert(
            title: "Connection Failed",
            image: img("img-error-circle"),
            description: message,
            actionTitle: "title-close".localized
        )

        let controller = open(.warningAlert(warningAlert: warningAlert), by: transitionStyle) as? WarningAlertViewController
        controller?.delegate = self
    }
}

extension QRScannerViewController: WarningAlertViewControllerDelegate {
    func warningAlertViewControllerDidTakeAction(_ warningAlertViewController: WarningAlertViewController) {
        resetUIForScanning()
    }
}

extension QRScannerViewController: WCConnectionApprovalViewControllerDelegate {
    func wcConnectionApprovalViewControllerDidApproveConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
    }

    func wcConnectionApprovalViewControllerDidRejectConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
        resetUIForScanning()
    }

    private func resetUIForScanning() {
        cancelButton.stopLoading()
        customizeButtonAppearance()
        captureSessionQueue.async {
            self.captureSession?.startRunning()
        }
    }
}

extension QRScannerViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonHorizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 16.0
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerViewControllerDidApproveWCConnection(_ controller: QRScannerViewController)
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?)
}

extension QRScannerViewControllerDelegate {
    func qrScannerViewControllerDidApproveWCConnection(_ controller: QRScannerViewController) {

    }

    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {

    }

    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {

    }
}

enum QRScannerError: Swift.Error {
    case jsonSerialization
    case invalidData
}
