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
//  QRScannerView.swift

import UIKit
import MacaroonUIKit

final class QRScannerOverlayView: View {
    weak var delegate: QRScannerOverlayViewDelegate?

    private lazy var theme = QRScannerOverlayViewTheme()

    private lazy var cancelButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var overlayView = UIView()
    private lazy var overlayImageView = UIImageView()
    private lazy var connectedAppsButtonContainerVisualEffectView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    )
    private lazy var connectedAppsButton = MacaroonUIKit.Button(
        .imageAtRight(
            spacing: theme.connectedAppsButtonTitleImageSpacing
        )
    )

    struct Configuration {
        var cancelMode: CancelMode = .pop
        var showsConnectedAppsButton = false

        enum CancelMode {
            case pop
            case dismiss
        }
    }

    private let configuration: Configuration

    init(configurationHandler:  (inout Configuration) -> Void = { _ in }) {
        var configuration = Configuration()
        configurationHandler(&configuration)
        self.configuration = configuration
        super.init(frame: .zero)
        setListeners()
    }

    func customize(_ theme: QRScannerOverlayViewTheme) {
        self.theme = theme
        
        addOverlayView(theme)
        addOverlayImageView(theme)
        addTitleLabel(theme)
        addCancelButton(theme)
        addConnectedAppsButton(theme)
    }

    func setListeners() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        connectedAppsButton.addTarget(self, action: #selector(didTapConnectedAppsButton), for: .touchUpInside)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension QRScannerOverlayView {
    @objc
    private func didTapConnectedAppsButton() {
        delegate?.qrScannerOverlayViewDidTapConnectedAppsButton(self)
    }

    @objc
    private func didTapCancel() {
        delegate?.qrScannerOverlayView(
            self,
            didCancel: configuration.cancelMode
        )
    }
}

extension QRScannerOverlayView {
    private func addCancelButton(_ theme: QRScannerOverlayViewTheme) {
        let style: ButtonStyle

        switch configuration.cancelMode {
        case .pop: style = theme.backButton
        case .dismiss: style = theme.dismissButton
        }

        cancelButton.customizeAppearance(style)

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.cancelButtonSize)
        }
    }

    private func addOverlayView(_ theme: QRScannerOverlayViewTheme) {
        overlayView.frame =  UIScreen.main.bounds
        overlayView.backgroundColor = theme.backgroundColor.uiColor
        let path = CGMutablePath()
        path.addRect(UIScreen.main.bounds)
        let size = theme.overlayViewSize
        let rect = CGRect(
            x: UIScreen.main.bounds.midX - (size / 2),
            y: UIScreen.main.bounds.midY - (size / 2),
            width: size,
            height: size
        )
        path.addRoundedRect(
            in: rect,
            cornerWidth: theme.overlayCornerRadius,
            cornerHeight: theme.overlayCornerRadius
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = maskLayer

        addSubview(overlayView)
    }
    
    private func addOverlayImageView(_ theme: QRScannerOverlayViewTheme) {
        overlayImageView.customizeAppearance(theme.overlayImage)

        let size = theme.overlayImageViewSize
        let frame = CGRect(
            x: UIScreen.main.bounds.midX - (size / 2),
            y: UIScreen.main.bounds.midY - (size / 2),
            width: size,
            height: size
        )
        overlayImageView.frame = frame

        addSubview(overlayImageView)
    }
    
    private func addTitleLabel(_ theme: QRScannerOverlayViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(theme.titleLabelTopInset)
        }
    }

    private func addConnectedAppsButton(_ theme: QRScannerOverlayViewTheme) {
        connectedAppsButton.customizeAppearance(theme.connectedAppsButton)
        connectedAppsButton.contentEdgeInsets = UIEdgeInsets(theme.connectedAppsButtonContentEdgeInsets)

        addSubview(connectedAppsButtonContainerVisualEffectView)
        connectedAppsButtonContainerVisualEffectView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.connectedAppsButtonBottomInset)
        }

        connectedAppsButtonContainerVisualEffectView.draw(corner: theme.connectedAppsButtonCorner)
        connectedAppsButtonContainerVisualEffectView.contentView.addSubview(connectedAppsButton)
        connectedAppsButton.pinToSuperview()

        connectedAppsButtonContainerVisualEffectView.isHidden = true
    }
}

extension QRScannerOverlayView: ViewModelBindable {
    func bindData(_ viewModel: QRScannerOverlayViewModel?) {
        if let title = viewModel?.connectedAppsButtonTitle {
            connectedAppsButton.setTitle(title, for: .normal)
            connectedAppsButtonContainerVisualEffectView.isHidden = false
        } else {
            connectedAppsButtonContainerVisualEffectView.isHidden = true
        }
    }
}

protocol QRScannerOverlayViewDelegate: AnyObject {
    func qrScannerOverlayViewDidTapConnectedAppsButton(_ qrScannerOverlayView: QRScannerOverlayView)
    func qrScannerOverlayView(
        _ qrScannerOverlayView: QRScannerOverlayView,
        didCancel mode: QRScannerOverlayView.Configuration.CancelMode
    )
}

extension UIVisualEffectView: CornerDrawable {}
