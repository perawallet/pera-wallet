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
//  OptionsView.swift

import UIKit

class OptionsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: OptionsViewDelegate?
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.secondary
        collectionView.contentInset = .zero
        collectionView.register(OptionsCell.self, forCellWithReuseIdentifier: OptionsCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-cancel".localized)
            .withTitleColor(Colors.ButtonText.secondary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupCancelButtonLayout()
        setupOptionsCollectionViewLayout()
    }
}

extension OptionsView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.optionsViewDidTapCancelButton(self)
    }
}

extension OptionsView {
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    private func setupOptionsCollectionViewLayout() {
        addSubview(optionsCollectionView)
        
        optionsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(cancelButton.snp.top).offset(layout.current.bottomInset)
        }
    }
}

extension OptionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 22.0
        let buttonBottomInset: CGFloat = 20.0
        let defaultInset: CGFloat = 20.0
        let topInset: CGFloat = 10.0
        let bottomInset: CGFloat = -14.0
    }
}

protocol OptionsViewDelegate: AnyObject {
    func optionsViewDidTapCancelButton(_ optionsView: OptionsView)
}
