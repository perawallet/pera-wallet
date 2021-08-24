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
//  LedgerDeviceListView.swift

import UIKit

class LedgerDeviceListView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerDeviceListViewDelegate?
    
    private(set) lazy var devicesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 4.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = layout.current.listContentInset
        collectionView.register(LedgerDeviceCell.self, forCellWithReuseIdentifier: LedgerDeviceCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var searchingDevicesLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("ledger-device-list-looking".localized)
    }()
    
    private lazy var searchingSpinnerView = LoadingSpinnerView()
    
    private lazy var troubleshootButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setImage(img("img-question-24"), for: .normal)
        button.setTitle("ledger-device-list-troubleshoot".localized, for: .normal)
        button.setTitleColor(Colors.Main.white, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        button.setBackgroundImage(img("bg-gray-600-button"), for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()

    override func setListeners() {
        troubleshootButton.addTarget(self, action: #selector(notifyDelegateToOpenTrobuleshooting), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTroubleshootButtonLayout()
        setupDevicesCollectionViewLayout()
        setupSearchingDevicesLabelLayout()
        setupSearchingSpinnerViewLayout()
    }
}

extension LedgerDeviceListView {
    @objc
    func notifyDelegateToOpenTrobuleshooting() {
        delegate?.ledgerDeviceListViewDidTapTroubleshootButton(self)
    }
}

extension LedgerDeviceListView {
    private func setupTroubleshootButtonLayout() {
        addSubview(troubleshootButton)
        
        troubleshootButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    private func setupDevicesCollectionViewLayout() {
        addSubview(devicesCollectionView)
        
        devicesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }
    
    private func setupSearchingDevicesLabelLayout() {
        addSubview(searchingDevicesLabel)
        
        searchingDevicesLabel.snp.makeConstraints { make in
            make.top.equalTo(devicesCollectionView.snp.bottom).offset(layout.current.devicesLabelTopOffset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSearchingSpinnerViewLayout() {
        addSubview(searchingSpinnerView)
        
        searchingSpinnerView.snp.makeConstraints { make in
            make.centerY.equalTo(searchingDevicesLabel)
            make.leading.equalTo(searchingDevicesLabel.snp.trailing).offset(layout.current.spinnerLeadingInset)
            make.size.equalTo(layout.current.spinnerSize)
        }
    }
}

extension LedgerDeviceListView {
    func startSearchSpinner() {
        searchingSpinnerView.show()
    }
    
    func stopSearchSpinner() {
        searchingSpinnerView.stop()
    }
    
    func setSearchSpinner(visible isVisible: Bool) {
        searchingDevicesLabel.isHidden = !isVisible
        searchingSpinnerView.isHidden = !isVisible
    }
    
    func invalidateContentSize(by size: Int) {
        devicesCollectionView.snp.updateConstraints { make in
            make.height.equalTo(size * layout.current.deviceItemTotalSize)
        }
    }
}

extension LedgerDeviceListView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let deviceItemTotalSize = 64
        let buttonBottomInset: CGFloat = 60.0
        let listContentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0)
        let horizontalInset: CGFloat = 20.0
        let spinnerLeadingInset: CGFloat = 13.0
        let devicesLabelTopOffset: CGFloat = 12.0
        let collectionViewHeight: CGFloat = 0.0
        let spinnerSize = CGSize(width: 17.5, height: 17.5)
    }
}

protocol LedgerDeviceListViewDelegate: AnyObject {
    func ledgerDeviceListViewDidTapTroubleshootButton(_ ledgerDeviceListView: LedgerDeviceListView)
}
