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
//  SingleSelectionViewModel.swift

import UIKit

final class SingleSelectionViewModel: Hashable {
    private(set) var title: String?
    private(set) var isSelected = false
    private(set) var selectionImage: UIImage?
    
    init(title: String?, isSelected: Bool) {
        setTitle(title: title)
        setSelected(isSelected: isSelected)
        setSelectionImage()
    }
    
    private func setTitle(title: String?) {
        self.title = title
    }
    
    private func setSelected(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    private func setSelectionImage() {
        if isSelected {
            selectionImage = img("icon-radio-selected")
            return
        }
        
        selectionImage = img("icon-radio-unselected")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: SingleSelectionViewModel, rhs: SingleSelectionViewModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.isSelected == rhs.isSelected
    }
}
