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

//   CollectibleGalleryUIActionsView.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryUIActionsView:
    View,
    ListReusable {
    weak var delegate: CollectibleGalleryUIActionsViewDelegate?

    private lazy var searchInputView = SearchInputView()
    private lazy var galleryUIStyleInputView = SegmentedControl(theme.galleryUIStyleInput)

    private var selectedGalleryUIStyleIndex = -1 {
        didSet {
            updateSelectedSegmentIndexIfNeeded(old: oldValue)
        }
    }

    private let gridUIStyleIndex = 0
    private let listUIStyleIndex = 1

    private var theme: CollectibleGalleryUIActionsViewTheme!

    func customize(_ theme: CollectibleGalleryUIActionsViewTheme) {
        self.theme = theme

        addBackground(theme)
        addSearchInput(theme)
        addAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    static func calculatePreferredSize(
        for theme: CollectibleGalleryUIActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, theme.searchInput.intrinsicHeight))
    }
}

extension CollectibleGalleryUIActionsView {
    private func addBackground(_ theme: CollectibleGalleryUIActionsViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addSearchInput(_ theme: CollectibleGalleryUIActionsViewTheme) {
        searchInputView.customize(theme.searchInput)

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        searchInputView.delegate = self
    }

    private func addAction(_ theme: CollectibleGalleryUIActionsViewTheme) {
        addSubview(galleryUIStyleInputView)
        galleryUIStyleInputView.fitToIntrinsicSize()
        galleryUIStyleInputView.snp.makeConstraints {
            $0.top == 0
            $0.leading == searchInputView.snp.trailing + theme.spacingBetweenSearchInputAndGalleryUIStyleInput
            $0.trailing == 0
            $0.bottom == 0
        }

        let segments = [theme.gridUIStyleOption, theme.listUIStyleOption]
        galleryUIStyleInputView.add(segments: segments)
        
        galleryUIStyleInputView.addTarget(
            self,
            action: #selector(performGalleryUIStyleUpdateIfNeeded),
            for: .valueChanged
        )
    }
}

extension CollectibleGalleryUIActionsView {
    @objc
    private func performGalleryUIStyleUpdateIfNeeded() {
        selectedGalleryUIStyleIndex = galleryUIStyleInputView.selectedSegmentIndex
    }

    private func publishGalleryUIStyleChange() {
        if selectedGalleryUIStyleIndex == gridUIStyleIndex {
            delegate?.collectibleGalleryUIActionsViewDidSelectGridUIStyle(self)
            return
        }

        if selectedGalleryUIStyleIndex == listUIStyleIndex {
            delegate?.collectibleGalleryUIActionsViewDidSelectListUIStyle(self)
            return
        }
    }
}

extension CollectibleGalleryUIActionsView {
    private func updateSelectedSegmentIndexIfNeeded(old: Int) {
        if selectedGalleryUIStyleIndex == old {
            return
        }

        galleryUIStyleInputView.selectedSegmentIndex = selectedGalleryUIStyleIndex

        publishGalleryUIStyleChange()
    }
}

extension CollectibleGalleryUIActionsView {
    func setGridUIStyleSelected() {
        selectedGalleryUIStyleIndex = gridUIStyleIndex
    }

    func setListUIStyleSelected() {
        selectedGalleryUIStyleIndex = listUIStyleIndex
    }
}

extension CollectibleGalleryUIActionsView {
    func beginEditing() {
        searchInputView.beginEditing()
    }

    func endEditing() {
        searchInputView.endEditing()
    }
}

extension CollectibleGalleryUIActionsView: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        delegate?.collectibleGalleryUIActionsViewDidEditSearchInput(self, input: view.text)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        delegate?.collectibleGalleryUIActionsViewDidReturnSearchInput(self)
    }
}

protocol CollectibleGalleryUIActionsViewDelegate: AnyObject {
    func collectibleGalleryUIActionsViewDidSelectGridUIStyle(_ view: CollectibleGalleryUIActionsView)
    func collectibleGalleryUIActionsViewDidSelectListUIStyle(_ view: CollectibleGalleryUIActionsView)
    func collectibleGalleryUIActionsViewDidEditSearchInput(_ view: CollectibleGalleryUIActionsView, input: String?)
    func collectibleGalleryUIActionsViewDidReturnSearchInput(_ view: CollectibleGalleryUIActionsView)
}
