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
//  NodeSettingsViewModel.swift

import UIKit

class NodeSettingsViewModel {
    private(set) var nodeName: String?
    private(set) var backgroundImage: UIImage?
    private(set) var image: UIImage?

    init(node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        setNodeName(from: node)
        setBackgroundImage(from: node, activeNetwork: activeNetwork)
        setImage(from: node, activeNetwork: activeNetwork)
    }

    private func setNodeName(from node: AlgorandNode) {
        nodeName = node.name
    }

    private func setBackgroundImage(from node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        if node.network == activeNetwork {
            backgroundImage = img("bg-settings-node-selected")
        } else {
            backgroundImage = img("bg-settings-node-unselected")
        }
    }

    private func setImage(from node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        if node.network == activeNetwork {
            image = img("settings-node-active")
        } else {
            image = img("settings-node-inactive")
        }
    }
}
