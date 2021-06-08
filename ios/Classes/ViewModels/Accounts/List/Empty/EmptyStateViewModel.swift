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
//   EmptyStateViewModel.swift

import UIKit

class EmptyStateViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var detail: String?
    private(set) var action: String?

    init(emptyState: EmptyState) {
        setImage(from: emptyState)
        setTitle(from: emptyState)
        setDetail(from: emptyState)
        setAction(from: emptyState)
    }

    private func setImage(from state: EmptyState) {
        switch state {
        case .accounts:
            image = img("img-accounts-empty")
        }
    }

    private func setTitle(from state: EmptyState) {
        switch state {
        case .accounts:
            title = "empty-accounts-title".localized
        }
    }

    private func setDetail(from state: EmptyState) {
        switch state {
        case .accounts:
            detail = "empty-accounts-detail".localized
        }
    }

    private func setAction(from state: EmptyState) {
        switch state {
        case .accounts:
            action = "empty-accounts-action".localized
        }
    }
}
