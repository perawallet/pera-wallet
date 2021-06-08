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
//  QRView.swift

import UIKit

class QRView: BaseView {
    
    private let outputWidth: CGFloat = 200.0
    
    private(set) lazy var imageView = UIImageView()

    let qrText: QRText
    
    init(qrText: QRText) {
        self.qrText = qrText
        super.init(frame: .zero)
        
        if qrText.mode == .mnemonic {
            generateMnemonicsQR()
        } else {
            generateLinkQR()
        }
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
    }
}

extension QRView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        let ratio = outputWidth / ciImageSize.width
        
        guard let outputImage = ciImage.nonInterpolatedImage(withScale: Scale(dx: ratio, dy: ratio)) else {
            return
        }
        
        imageView.image = outputImage
    }
}
