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
//   HomeAccountSectionHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeAccountSectionHeaderViewModel:
    TitleWithAccessoryViewModel,
    PairedViewModel,
    Hashable {
    private(set) var type: AccountInformation.AccountType
    private(set) var title: EditText?
    private(set) var accessory: ButtonStyle?
    private(set) var accessoryContentEdgeInsets: UIEdgeInsets?
    
    init(
        _ model: AccountInformation.AccountType
    ) {
        self.type = model
        bind(model)
    }
}

extension HomeAccountSectionHeaderViewModel {
    mutating func bind(
        _ type: AccountInformation.AccountType
    ) {
        self.type = type
        
        bindTitle(type)
        bindAccessory(type)
    }
    
    mutating func bindTitle(
        _ type: AccountInformation.AccountType
    ) {
        let aTitle: String?
        
        switch type {
        case .watch: aTitle = "portfolio-title-watchlist".localized
        default: aTitle = "portfolio-title-accounts".localized
        }
        
        title = getTitle(aTitle)
    }
    
    mutating func bindAccessory(
        _ type: AccountInformation.AccountType
    ) {
        let item = getOptionsAccessoryItem()
        
        accessory = item.style
        accessoryContentEdgeInsets = item.contentEdgeInsets
    }
}

extension HomeAccountSectionHeaderViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }
    
    static func == (
        lhs: HomeAccountSectionHeaderViewModel,
        rhs: HomeAccountSectionHeaderViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
