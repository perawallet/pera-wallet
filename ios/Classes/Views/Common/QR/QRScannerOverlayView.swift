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
//  QRScannerView.swift

import UIKit

class QRScannerOverlayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Main.white)
            .withText("qr-scan-title".localized)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var overlayView: UIView = {
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = Colors.QRScanner.qrScannerBackground
        let path = CGMutablePath()
        path.addRect(UIScreen.main.bounds)
        path.addRoundedRect(
            in: overlayViewCenterRect,
            cornerWidth: 18.0,
            cornerHeight: 18.0
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = maskLayer
        return overlayView
    }()
    
    private lazy var overlayViewCenterRect: CGRect = {
        let size: CGFloat = 248.0
        return CGRect(x: UIScreen.main.bounds.midX - (size / 2.0), y: UIScreen.main.bounds.midY - (size / 2.0), width: size, height: size)
    }()
    
    private lazy var overlayImageView = UIImageView(image: img("img-qr-overlay-center"))
    
    private lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.QRScanner.detailText)
            .withText("qr-scan-message-text".localized)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupOverlayViewLayout()
        setupOverlayImageViewLayout()
        setupTitleLabelLayout()
        setupExplanationLabelLayout()
    }
}

extension QRScannerOverlayView {
    private func setupOverlayViewLayout() {
        addSubview(overlayView)
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOverlayImageViewLayout() {
        addSubview(overlayImageView)
        overlayImageView.frame = overlayViewCenterRect
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(safeAreaTop + layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(overlayImageView.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.explanationLabelHorizontalInset)
        }
    }
}

extension Colors {
    fileprivate enum QRScanner {
        static let qrScannerBackground = color("qrScannerBackground")
        static let detailText = Colors.Main.white.withAlphaComponent(0.8)
    }
}

extension QRScannerOverlayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 40.0
        let titleLabelTopInset: CGFloat = 20.0
        let explanationLabelHorizontalInset: CGFloat = 40.0
    }
}
