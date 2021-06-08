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
//   LedgerDeviceConnectionView.swift

import UIKit

class LedgerDeviceConnectionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 88.0)
    }

    private lazy var bluetoothAnimationView = BluetoothLoadingView()

    private lazy var ledgerImageView = UIImageView(image: img("img-ledger-small"))

    private lazy var deviceImageView = UIImageView(image: img("img-pixel-device"))

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupBluetoothAnimationViewLayout()
        setupDeviceImageViewLayout()
        setupLedgerImageViewLayout()
    }
}

extension LedgerDeviceConnectionView {
    private func setupBluetoothAnimationViewLayout() {
        addSubview(bluetoothAnimationView)

        bluetoothAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupDeviceImageViewLayout() {
        addSubview(deviceImageView)

        deviceImageView.snp.makeConstraints { make in
            make.leading.equalTo(bluetoothAnimationView.snp.trailing).offset(layout.current.deviceImageLeadingInset)
            make.centerY.equalTo(bluetoothAnimationView)
            make.size.equalTo(layout.current.deviceImageSize)
        }
    }

    private func setupLedgerImageViewLayout() {
        addSubview(ledgerImageView)

        ledgerImageView.snp.makeConstraints { make in
            make.centerY.equalTo(bluetoothAnimationView)
            make.trailing.equalTo(bluetoothAnimationView.snp.leading).offset(layout.current.imageTrailingOffset)
            make.size.equalTo(layout.current.ledgerImageSize)
        }
    }
}

extension LedgerDeviceConnectionView {
    func startAnimation() {
        bluetoothAnimationView.show()
    }

    func stopAnimation() {
        bluetoothAnimationView.stop()
    }
}

extension LedgerDeviceConnectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 32.0
        let deviceImageLeadingInset: CGFloat = 5.0
        let imageTrailingOffset: CGFloat = -5.0
        let deviceImageSize = CGSize(width: 44.0, height: 88.0)
        let ledgerImageSize = CGSize(width: 27.0, height: 24.0)
    }
}
