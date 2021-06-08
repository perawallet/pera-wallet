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
//  QRCreationViewController.swift

import UIKit

class QRCreationViewController: BaseScrollViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    override var name: AnalyticsScreenName? {
        return isTrackable ? .showQR : nil
    }
    
    private lazy var qrCreationView = QRCreationView(draft: draft)
    
    private let draft: QRCreationDraft
    private let isTrackable: Bool
    
    init(draft: QRCreationDraft, configuration: ViewControllerConfiguration, isTrackable: Bool = false) {
        self.draft = draft
        self.isTrackable = isTrackable
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        
        if draft.isSelectable {
            qrCreationView.setAddress(draft.address)
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        qrCreationView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupQRCreationViewLayout()
    }
}

extension QRCreationViewController {
    private func setupQRCreationViewLayout() {
        contentView.addSubview(qrCreationView)
        
        qrCreationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension QRCreationViewController: QRCreationViewDelegate {
    func qrCreationViewDidShare(_ qrCreationView: QRCreationView) {
        guard let qrImage = qrCreationView.getQRImage() else {
            return
        }
        
        let sharedItem = [qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        activityViewController.completionWithItemsHandler = { [weak self] _, success, _, _ in
            if success {
                guard let self = self else {
                    return
                }
                self.log(ReceiveShareCompleteEvent(address: self.draft.address))
            }
        }
        
        log(ReceiveShareEvent(address: draft.address))
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String) {
        log(ReceiveCopyEvent(address: draft.address))
        UIPasteboard.general.string = text
    }
}

enum QRMode {
    case address
    case mnemonic
    case algosRequest
    case assetRequest
}
