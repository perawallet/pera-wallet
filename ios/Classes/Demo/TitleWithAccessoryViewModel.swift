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
//   TitleWithAccessoryViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol TitleWithAccessoryViewModel: ViewModel {
    var title: EditText? { get }
    var accessory: ButtonStyle? { get }
    var accessoryContentEdgeInsets: UIEdgeInsets? { get }
}

extension TitleWithAccessoryViewModel {
    func getTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }
        
        return .attributedString(
            aTitle
                .bodyMedium()
        )
    }
}

extension TitleWithAccessoryViewModel {
    typealias AccessoryItem = (style: ButtonStyle, contentEdgeInsets: UIEdgeInsets)
    
    func getOptionsAccessoryItem() -> AccessoryItem {
        let style: ButtonStyle = [
            .icon([ .normal("icon-options") ])
        ]
        let contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        return (style, contentEdgeInsets)
    }
}
