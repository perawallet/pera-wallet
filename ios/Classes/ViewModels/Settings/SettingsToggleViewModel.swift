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
//  SettingsToggleViewModel.swift

import UIKit

class SettingsToggleViewModel {
    
    private var image: UIImage?
    private var title: String?
    private var isOn: Bool = false
    
    init(setting: Settings, isOn: Bool) {
        setImage(from: setting)
        setTitle(from: setting)
        setIsOn(from: isOn)
    }
    
    private func setImage(from settings: Settings) {
        image = settings.image
    }
    
    private func setTitle(from settings: Settings) {
        title = settings.name
    }
    
    private func setIsOn(from isOn: Bool) {
        self.isOn = isOn
    }
}

extension SettingsToggleViewModel {
    func configure(_ cell: SettingsToggleCell) {
        cell.contextView.setImage(image)
        cell.contextView.setName(title)
        cell.contextView.setToggleOn(isOn, animated: false)
    }
}
