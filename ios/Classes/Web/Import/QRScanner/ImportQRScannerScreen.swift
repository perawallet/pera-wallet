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

//   ImportQRScannerScreen.swift

import Foundation
import UIKit
import AVFoundation
import MacaroonUtils
import MacaroonUIKit

final class ImportQRScannerScreen: BaseViewController, NotificationObserver {
    typealias EventHandler = (Event, ImportQRScannerScreen) -> Void

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

    var eventHandler: EventHandler?

    private lazy var overlayView = QRScannerOverlayView {
        [weak self] in
        guard let self = self else { return }
        $0.cancelMode = self.canGoBack() ? .pop : .dismiss
        $0.showsConnectedAppsButton = false
    }

    private var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var cameraResetHandler: EmptyHandler = {
        if self.captureSession?.isRunning == false {
            self.captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.startRunning()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.customizeAppearance([.backgroundColor(Colors.Defaults.background)])
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

    override func setListeners() {
        overlayView.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()

        observeWhenApplicationDidEnterBackground {
            [weak self] _ in
            guard let self = self else { return }
            self.disableCapturingIfNeeded()
        }
    }
}

extension ImportQRScannerScreen {
    private func enableCapturingIfNeeded() {
        if self.captureSession?.isRunning == false && UIApplication.shared.authStatus == .ready {
            self.captureSessionQueue.async {
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

extension ImportQRScannerScreen {
    private func configureScannerView() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            configureScannerViewWithVideoAccess()
            return
        }

        setupCaptureSession()
        setupPreviewLayer()
        setupOverlayViewLayout()
    }

    private func configureScannerViewWithVideoAccess() {
        AVCaptureDevice.requestAccess(for: .video) { 
            [weak self] isGranted in
            guard let self else { return }
            asyncMain { [weak self] in
                guard let self else {
                    return
                }

                if isGranted {
                    self.setupCaptureSession()
                    self.setupPreviewLayer()
                    self.setupOverlayViewLayout()
                } else {
                    self.presentDisabledCameraAlert()
                    self.setupOverlayViewLayout()
                }
            }
        }
    }
}

extension ImportQRScannerScreen {
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
            [weak captureSession] in
            captureSession?.startRunning()
        }
    }

    private func setupOverlayViewLayout() {
        overlayView.customize(
            QRScannerOverlayViewTheme(
                LayoutFamily.current,
                title: "web-import-qr-scanner-title".localized
            )
        )
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension ImportQRScannerScreen: AVCaptureMetadataOutputObjectsDelegate {
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
            return
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        guard let qrBackupParameters = try? JSONDecoder().decode(QRBackupParameters.self, from: qrStringData) else {
            return
        }

        validateParameters(qrBackupParameters)
    }

    private func validateParameters(_ qrBackupParameters: QRBackupParameters) {
        switch qrBackupParameters.action {
        case .import:
            eventHandler?(.didReadBackup(parameters: qrBackupParameters), self)
        default:
            eventHandler?(.didReadUnsupportedAction(parameters: qrBackupParameters), self)
        }
    }
}

extension ImportQRScannerScreen: QRScannerOverlayViewDelegate {
    func qrScannerOverlayViewDidTapConnectedAppsButton(_ qrScannerOverlayView: QRScannerOverlayView) {}

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

extension ImportQRScannerScreen {
    enum Event {
        case didReadBackup(parameters: QRBackupParameters)
        case didReadUnsupportedAction(parameters: QRBackupParameters)
    }
}
