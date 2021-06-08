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
//  AssetActionConfirmationViewModel.swift

import UIKit

class AssetActionConfirmationViewModel {
    private(set) var title: String?
    private(set) var id: String?
    private(set) var actionTitle: String?
    private(set) var detail: NSAttributedString?
    private(set) var assetDisplayViewModel: AssetDisplayViewModel?

    init(draft: AssetAlertDraft) {
        setTitle(from: draft)
        setId(from: draft)
        setActionTitle(from: draft)
        setDetail(from: draft)
        setAssetDisplayViewModel(from: draft)
    }

    private func setTitle(from draft: AssetAlertDraft) {
        title = draft.title
    }

    private func setId(from draft: AssetAlertDraft) {
        id = "\(draft.assetIndex)"
    }

    private func setActionTitle(from draft: AssetAlertDraft) {
        actionTitle = draft.actionTitle
    }

    private func setDetail(from draft: AssetAlertDraft) {
        guard let detailText = draft.detail else {
            return
        }

        let attributedDetailText = NSMutableAttributedString(attributedString: detailText.attributed([.lineSpacing(1.2)]))

        guard let assetDetail = draft.assetDetail,
            let unitName = assetDetail.unitName, !unitName.isEmptyOrBlank else {
            detail = attributedDetailText
            return
        }

        let range = (detailText as NSString).range(of: unitName)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.General.selected, range: range)
        attributedDetailText.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.General.selected, range: range)
        detail = attributedDetailText
    }

    private func setAssetDisplayViewModel(from draft: AssetAlertDraft) {
        assetDisplayViewModel = AssetDisplayViewModel(assetDetail: draft.assetDetail)
    }
}
