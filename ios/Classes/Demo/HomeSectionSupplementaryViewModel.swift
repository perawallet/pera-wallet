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
//   HomeSectionSupplementaryViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeSectionSupplementaryViewModel:
    TitleWithAccessoryViewModel,
    PairedViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var accessory: ButtonStyle?
    private(set) var accessoryContentEdgeInsets: UIEdgeInsets?
    
    init(
        _ model: HomeSection
    ) {
        bind(model)
    }
}

extension HomeSectionSupplementaryViewModel {
    mutating func bind(
        _ section: HomeSection
    ) {
        bindTitle(section)
        bindAccessory(section)
    }
    
    mutating func bindTitle(
        _ section: HomeSection
    ) {
        let aTitle: String?
        
        switch section {
        case .accounts:
            aTitle = "portfolio-title-accounts".localized
        case .watchAccounts:
            aTitle = "portfolio-title-watchlist".localized
        default:
            aTitle = nil
        }
        
        title = getTitle(aTitle)
    }
    
    mutating func bindAccessory(
        _ section: HomeSection
    ) {
        let item = getOptionsAccessoryItem()
        
        accessory = item.style
        accessoryContentEdgeInsets = item.contentEdgeInsets
    }
}

extension HomeSectionSupplementaryViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }
    
    static func == (
        lhs: HomeSectionSupplementaryViewModel,
        rhs: HomeSectionSupplementaryViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
