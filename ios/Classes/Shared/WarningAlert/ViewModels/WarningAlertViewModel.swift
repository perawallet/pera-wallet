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
//   WarningAlertViewModel.swift

import UIKit

class WarningAlertViewModel {
    private(set) var title: String?
    private(set) var image: UIImage?
    private(set) var description: String?
    private(set) var actionTitle: String?
    
    init(warningAlert: WarningAlert) {
        setTitle(from: warningAlert)
        setImage(from: warningAlert)
        setDescription(from: warningAlert)
        setActionTitle(from: warningAlert)
    }
    
    private func setTitle(from warningAlert: WarningAlert) {
        self.title = warningAlert.title
    }
    
    private func setImage(from warningAlert: WarningAlert) {
        self.image = warningAlert.image
    }
    
    private func setDescription(from warningAlert: WarningAlert) {
        self.description = warningAlert.description
    }
    
    private func setActionTitle(from warningAlert: WarningAlert) {
        self.actionTitle = warningAlert.actionTitle
    }
}
