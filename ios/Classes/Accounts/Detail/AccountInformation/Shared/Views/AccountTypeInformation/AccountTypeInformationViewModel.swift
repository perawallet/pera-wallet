// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

protocol AccountTypeInformationViewModel: ViewModel {
    var title: TextProvider? { get }
    var typeIcon: Image? { get }
    var typeTitle: TextProvider? { get }
    var typeFootnote: TextProvider? { get }
    var typeDescription: TypeDescriptionTextProvider? { get }

    typealias TypeDescriptionTextProvider = AccountTypeInformationTypeDescriptionTextProvider
    typealias HighlightedText = AccountTypeInformationTypeDescriptionTextProvider.HighlightedText
}

struct AccountTypeInformationTypeDescriptionTextProvider {
    var text: TextProvider
    var highlightedText: HighlightedText? = nil

    struct HighlightedText {
        let text: String
        let attributes: TextAttributeGroup
    }
}
