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
//  TitledToggleViewModel.swift

import Foundation
import UserNotifications

final class TitledToggleViewModel {
    private(set) var isSelected: Bool = true

    init() {
        bindIsSelected()
    }
}

extension TitledToggleViewModel {
    private func bindIsSelected() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isSelected = settings.authorizationStatus == .authorized
            }
        }
    }
}
