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
//  DeveloperSettingsViewController.swift

import UIKit

class DeveloperSettingsViewController: BaseViewController {
    
    private var settings: [DeveloperSettings] = [.nodeSettings]
    
    private lazy var developerSettingsView = DeveloperSettingsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let isTestNet = api?.isTestNet,
            isTestNet {
            settings.append(.dispenser)
            developerSettingsView.collectionView.reloadData()
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "settings-developer".localized
    }
    
    override func linkInteractors() {
        developerSettingsView.collectionView.delegate = self
        developerSettingsView.collectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupDeveloperSettingsViewLayout()
    }
}

extension DeveloperSettingsViewController {
    private func setupDeveloperSettingsViewLayout() {
        view.addSubview(developerSettingsView)
        
        developerSettingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.safeEqualToTop(of: self)
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension DeveloperSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsDetailCell,
            let setting = settings[safe: indexPath.item] else {
                fatalError("Index path is out of bounds")
        }
        
        SettingsDetailViewModel(setting: setting).configure(cell)
        return cell
    }
}

extension DeveloperSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = settings[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        switch setting {
        case .nodeSettings:
            open(.nodeSettings, by: .push)
        case .dispenser:
            guard let url = AlgorandWeb.dispenser.link else {
                return
            }
            
            open(url)
        }
    }
}
