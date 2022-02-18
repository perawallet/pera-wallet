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
//   RangeSelectionViewModel.swift

import MacaroonUIKit
import UIKit

final class RangeSelectionViewModel: ViewModel {
    private(set) var title: String?
    private(set) var image: UIImage?
    private(set) var isSelected: Bool?
    private(set) var date: String?

    init(range: Range) {
        bindTitle(range)
        bindImage(range)
        bindIsSelected(range)
    }

    init(date: Date) {
        self.date = date.toFormat("dd.MM.yyyy")
    }
}

extension RangeSelectionViewModel {
    private func bindTitle(_ range: Range) {
        switch range {
        case .from:
            title = "transaction-detail-from".localized
        case .to:
            title = "transaction-detail-to".localized
        }
    }

    private func bindImage(_ range: Range) {
        switch range {
        case .from:
            image = img("icon-calendar-custom-pick-from")
        case .to:
            image = img("icon-calendar-custom-pick-to")
        }
    }

    private func bindIsSelected(_ range: Range) {
        if case .from = range {
            isSelected = true
        }
    }
}

extension RangeSelectionViewModel {
    enum Range {
        case from
        case to
    }
}
