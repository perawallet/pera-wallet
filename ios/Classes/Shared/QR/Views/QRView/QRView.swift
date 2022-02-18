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
//  QRView.swift

import UIKit
import MacaroonUIKit

final class QRView: View {
    private lazy var theme = QRViewTheme()
    private(set) lazy var imageView = UIImageView()

    let qrText: QRText
    
    init(qrText: QRText) {
        self.qrText = qrText
        super.init(frame: .zero)
        
        customize(theme)
        
        if qrText.mode == .mnemonic {
            generateMnemonicsQR()
        } else {
            generateLinkQR()
        }
    }

    private func customize(_ theme: QRViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addImageView(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension QRView {
    private func addImageView(_ theme: QRViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension QRView {
    private func generateLinkQR() {
        guard let data = qrText.qrText().data(using: .ascii) else {
            return
        }
        generateQR(from: data)
    }
    
    private func generateMnemonicsQR() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(qrText)
            generateQR(from: data)
        } catch { }
    }
    
    private func generateQR(from data: Data) {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return
        }
        
        qrFilter.setDefaults()
        qrFilter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = qrFilter.outputImage else {
            return
        }
        
        let ciImageSize = ciImage.extent.size
        let ratio = theme.outputWidth / ciImageSize.width
        
        guard let outputImage = ciImage.nonInterpolatedImage(withScale: Scale(dx: ratio, dy: ratio)) else {
            return
        }
        
        imageView.image = outputImage
    }
}
