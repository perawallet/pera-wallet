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
//  BottomInformationBundle.swift

import UIKit

struct BottomInformationBundle {
    let title: String
    let image: UIImage?
    let explanation: String
    let actionTitle: String?
    let actionImage: UIImage?
    let closeBackgroundImage: UIImage?
    let closeTitle: String
    let actionHandler: EmptyHandler?
    
    init(
        title: String,
        image: UIImage?,
        explanation: String,
        actionTitle: String? = nil,
        actionImage: UIImage? = nil,
        closeBackgroundImage: UIImage? = img("bg-light-gray-button"),
        closeTitle: String = "title-cancel".localized,
        actionHandler: EmptyHandler? = nil
    ) {
        self.title = title
        self.image = image
        self.explanation = explanation
        self.actionTitle = actionTitle
        self.actionImage = actionImage
        self.closeBackgroundImage = closeBackgroundImage
        self.closeTitle = closeTitle
        self.actionHandler = actionHandler
    }
}
