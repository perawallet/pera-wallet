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
//  SettingsInfoViewModel.swift

import UIKit

class SettingsInfoViewModel {
    
    private var image: UIImage?
    private var title: String?
    private var detail: String?
    
    init(setting: Settings, info: String?) {
        setImage(from: setting)
        setTitle(from: setting)
        setDetail(from: info)
    }
    
    private func setImage(from settings: Settings) {
        image = settings.image
    }
    
    private func setTitle(from settings: Settings) {
        title = settings.name
    }
    
    private func setDetail(from info: String?) {
        detail = info
    }
}

extension SettingsInfoViewModel {
    func configure(_ cell: SettingsInfoCell) {
        cell.contextView.setImage(image)
        cell.contextView.setName(title)
        cell.contextView.setDetail(detail)
    }
}
