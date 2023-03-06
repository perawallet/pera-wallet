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
    static var didUpdateNetwork: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.network.didUpdate")
    }
    
    private lazy var theme = Theme()
    private lazy var nodeSettingsView = SingleSelectionListView()
    
    private var selectedNetwork: ALGAPI.Network {
        return api?.network ?? .mainnet
    }
    
    private let nodes = [mainNetNode, testNetNode]
    
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )
    
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
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return nodes.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let node = nodes[indexPath.item]
        let viewModel = SingleSelectionViewModel(
            title: node.name,
            isSelected: node.network == selectedNetwork
        )
        let cell = collectionView.dequeue(SingleSelectionCell.self, at: indexPath)
        
        cell.bindData(viewModel)
        
        return cell
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let node = nodes[indexPath.item]
        
        if node.network == selectedNetwork {
            return
        }

        select(node)
    }
}

extension NodeSettingsViewController {
    private func select(
        _ node: AlgorandNode
    ) {
        willSelectNetwork(node.network)

        select(
            node: node,
            onChange: {
                self.nodeSettingsView.reloadData()

                NotificationCenter.default.post(
                    name: Self.didUpdateNetwork,
                    object: self
                )
            },
            onComplete: {
                [weak self] network in
                self?.didSelectNetwork(network)
            }
        )
    }
    
    private func willSelectNetwork(
        _ network: ALGAPI.Network
    ) {
        sharedDataController.stopPolling()
    }

    private func select(
        node: AlgorandNode,
        onChange change: () -> Void,
        onComplete completion: @escaping (ALGAPI.Network) -> Void
    ) {
        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        let oldNetwork = selectedNetwork
        
        api?.setupNetworkBase(node.network)
        change()
        
        pushNotificationController.sendDeviceDetails {
            [weak self] error in
            guard let self = self else { return }
            
            self.loadingController?.stopLoading()
            
            guard let error = error else {
                self.pushNotificationController.unregisterDevice(from: oldNetwork)
                
                self.session?.authenticatedUser?.setDefaultNode(node)
                self.sharedDataController.resetPolling()
                
                completion(node.network)
                
                return
            }
            
            self.api?.setupNetworkBase(oldNetwork)
            self.sharedDataController.startPolling()

            self.bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.prettyDescription
            )
            
            completion(oldNetwork)
        }
    }
    
    private func didSelectNetwork(
        _ network: ALGAPI.Network
    ) {
        nodeSettingsView.reloadData()
        
        NotificationCenter.default.post(
            name: Self.didUpdateNetwork,
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
