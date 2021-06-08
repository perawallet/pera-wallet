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
//  NodeSettingsViewController.swift

import UIKit
import SVProgressHUD

class NodeSettingsViewController: BaseViewController {
    
    private lazy var nodeSettingsView = NodeSettingsView()
    
    private let nodes = [mainNetNode, testNetNode]
    
    private var canTapBarButton = true
    
    private lazy var lastActiveNetwork: AlgorandAPI.BaseNetwork = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return api.network
    }()
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
    }()
    
    override func linkInteractors() {
        nodeSettingsView.collectionView.delegate = self
        nodeSettingsView.collectionView.dataSource = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "node-settings-title".localized
    }
    
    override func prepareLayout() {
        setupNodeSettingsViewLayout()
    }
    
    override func didTapBackBarButton() -> Bool {
        return canTapBarButton
    }
    
    override func didTapDismissBarButton() -> Bool {
        return canTapBarButton
    }
}

extension NodeSettingsViewController {
    private func setupNodeSettingsViewLayout() {
        view.addSubview(nodeSettingsView)
        
        nodeSettingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NodeSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NodeSelectionCell.reusableIdentifier,
            for: indexPath) as? NodeSelectionCell else {
                fatalError("Index path is out of bounds")
        }
        
        let algorandNode = nodes[indexPath.item]
        cell.bind(NodeSettingsViewModel(node: algorandNode, activeNetwork: lastActiveNetwork))
        return cell
    }
}

extension NodeSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 32.0, height: 64.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeNode(at: indexPath)
    }
}

extension NodeSettingsViewController {
    private func changeNode(at indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        setActionsEnabled(false)
        
        let selectedNode = nodes[indexPath.item]
        
        if pushNotificationController.token == nil {
            switchNetwork(for: selectedNode, at: indexPath)
        } else {
            pushNotificationController.sendDeviceDetails { isCompleted in
                if isCompleted {
                    self.switchNetwork(for: selectedNode, at: indexPath)
                } else {
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        self.setActionsEnabled(true)
                    }
                }
            }
        }
    }
    
    private func switchNetwork(for selectedNode: AlgorandNode, at indexPath: IndexPath) {
        session?.authenticatedUser?.setDefaultNode(selectedNode)
        lastActiveNetwork = selectedNode.network
        DispatchQueue.main.async {
            UIApplication.shared.rootViewController()?.setNetwork(to: selectedNode.network)
            UIApplication.shared.rootViewController()?.addBanner()
        }
        
        UIApplication.shared.accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            
            SVProgressHUD.dismiss(withDelay: 1.0) {
                self.setActionsEnabled(true)
                self.setSelected(at: indexPath, in: self.nodeSettingsView.collectionView)
            }
        }
    }

    private func setSelected(at indexPath: IndexPath, in collectionView: UICollectionView) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NodeSelectionCell else {
            return
        }
        setActive(cell)

        let otherCellIndex = indexPath.item == 0 ? 1 : 0

        guard let otherCell = collectionView.cellForItem(at: IndexPath(item: otherCellIndex, section: 0)) as? NodeSelectionCell else {
            return
        }

        setInactive(otherCell)
    }

    private func setActive(_ cell: NodeSelectionCell) {
        cell.contextView.setBackgroundImage(img("bg-settings-node-selected"))
        cell.contextView.setImage(img("settings-node-active"))
    }

    private func setInactive(_ cell: NodeSelectionCell) {
        cell.contextView.setBackgroundImage(img("bg-settings-node-unselected"))
        cell.contextView.setImage(img("settings-node-inactive"))
    }
    
    private func setActionsEnabled(_ isEnabled: Bool) {
        canTapBarButton = isEnabled
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        view.isUserInteractionEnabled = isEnabled
    }
}

let mainNetNode = AlgorandNode(
    algodAddress: Environment.current.mainNetAlgodHost,
    indexerAddress: Environment.current.mainNetAlgodHost,
    algodToken: Environment.current.algodToken,
    indexerToken: Environment.current.indexerToken,
    name: "node-settings-default-node-name".localized,
    network: .mainnet
)

let testNetNode = AlgorandNode(
    algodAddress: Environment.current.testNetAlgodHost,
    indexerAddress: Environment.current.testNetIndexerHost,
    algodToken: Environment.current.algodToken,
    indexerToken: Environment.current.indexerToken,
    name: "node-settings-default-test-node-name".localized,
    network: .testnet
)
