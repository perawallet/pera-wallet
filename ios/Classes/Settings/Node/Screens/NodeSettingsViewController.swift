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
//  NodeSettingsViewController.swift

import Foundation
import MacaroonUtils
import UIKit

final class NodeSettingsViewController: BaseViewController {
    static var willChangeNetwork: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.network.willChange")
    }
    static var didChangeNetwork: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.network.didChange")
    }
    
    private lazy var theme = Theme()
    private lazy var nodeSettingsView = SingleSelectionListView()
    
    private let nodes = [mainNetNode, testNetNode]
        
    private lazy var lastActiveNetwork: ALGAPI.Network = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return api.network
    }()
    
    private lazy var pushNotificationController =
        PushNotificationController(session: session!, api: api!, bannerController: bannerController)
    
    override func linkInteractors() {
        nodeSettingsView.linkInteractors()
        nodeSettingsView.setDataSource(self)
        nodeSettingsView.setListDelegate(self)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "node-settings-title".localized
    }
    
    override func prepareLayout() {
        addNodeSettingsView()
    }
}

extension NodeSettingsViewController {
    private func addNodeSettingsView() {
        view.addSubview(nodeSettingsView)
        
        nodeSettingsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NodeSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SingleSelectionCell.self, at: indexPath)
        
        if let algorandNode = nodes[safe: indexPath.item] {
            let isActiveNetwork = algorandNode.network == lastActiveNetwork
            cell.bindData(SingleSelectionViewModel(title: algorandNode.name, isSelected: isActiveNetwork))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension NodeSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeNode(at: indexPath)
    }
}

extension NodeSettingsViewController {
    /// <todo>
    /// The flow here is too complicated to understand. It should be refactored later.
    private func changeNode(at indexPath: IndexPath) {
        let selectedNode = nodes[indexPath.item]
        let selectedNetwork = selectedNode.network
        
        willChangeNetwork(selectedNetwork)
        
        if pushNotificationController.token == nil {
            session?.authenticatedUser?.setDefaultNode(selectedNode)
            didChangeNetwork(selectedNetwork)
        } else {
            loadingController?.startLoadingWithMessage("title-loading".localized)
            
            pushNotificationController.sendDeviceDetails {
                [weak self] isCompleted in
                guard let self = self else { return }

                if isCompleted {
                    self.session?.authenticatedUser?.setDefaultNode(selectedNode)
                    self.didChangeNetwork(selectedNetwork)
                    self.sharedDataController.resetPolling()
                } else {
                    self.didChangeNetwork(self.lastActiveNetwork)
                    self.sharedDataController.startPolling()
                }
                
                self.loadingController?.stopLoading()
            }
        }
    }
    
    private func willChangeNetwork(
        _ network: ALGAPI.Network
    ) {
        sharedDataController.stopPolling()
        api?.setupNetworkBase(network)
        
        NotificationCenter.default.post(
            name: Self.willChangeNetwork,
            object: self
        )
    }
    
    private func didChangeNetwork(
        _ network: ALGAPI.Network
    ) {
        lastActiveNetwork = network
        nodeSettingsView.reloadData()
        
        NotificationCenter.default.post(
            name: Self.didChangeNetwork,
            object: self
        )
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
