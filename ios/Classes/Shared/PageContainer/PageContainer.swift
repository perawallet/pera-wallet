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
//   PageContainer.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

class PageContainer: BaseViewController, TabbedContainer, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var items: [PageBarItem] = [] {
        didSet {
            itemsDidChange()
            selectedIndex = items.firstIndex
        }
    }

    var selectedIndex: Int? {
        didSet {
            selectedItemDidChange()
            itemDidSelect(selectedIndex.unwrap(or: 0))
        }
    }

    var selectedScreen: UIViewController? {
        get { screens[safe: selectedIndex] }
        set {
            selectedIndex = newValue.unwrap {
                screens.firstIndex(of: $0)
            }
        }
    }

    private(set) var screens: [UIViewController] = []

    private(set) lazy var pageBar = PageBar()
    private(set) lazy var pagesView = ListView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var pageSize: CGSize?
    private var isLayoutFinalized = false

    func customizePageBarAppearance() {
        pageBar.customizeAppearance(PageBarCommonStyleSheet())
    }

    func customizePagesAppearance() {
        pagesView.showsHorizontalScrollIndicator = false
        pagesView.showsVerticalScrollIndicator = false
        pagesView.bounces = false
        pagesView.isPagingEnabled = true
    }

    func addPageBar() {
        view.addSubview(pageBar)
        pageBar.prepareLayout(PageBarCommonLayoutSheet())
        pageBar.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    func addPages() {
        view.addSubview(
            pagesView
        )
        pagesView.flowLayout.scrollDirection = .horizontal
        pagesView.flowLayout.minimumLineSpacing = 0
        pagesView.flowLayout.minimumInteritemSpacing = 0
        pagesView.flowLayout.sectionInset = .zero
        pagesView.snp.makeConstraints {
            $0.top == pageBar.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }

    override func configureAppearance() {
        super.configureAppearance()

        customizePageBarAppearance()
        customizePagesAppearance()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addPageBar()
        addPages()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if pagesView.bounds.isEmpty {
            return
        }

        if !isLayoutFinalized {
            isLayoutFinalized = true
            selectedItemDidChange()
        }

        let newPageSize = pagesView.bounds.size

        guard let oldPageSize = pageSize else {
            pageSize = newPageSize
            return
        }

        if oldPageSize != newPageSize {
            pageSize = newPageSize
            pagesView.collectionViewLayout.invalidateLayout()
            pagesView.layoutIfNeededInParent()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            pagesView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }
    }

    override func setListeners() {
        super.setListeners()

        pagesView.dataSource = self
        pagesView.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()

        pageBar.itemDidSelect = { [unowned self] index in
            self.selectedIndex = index
        }
    }

    func itemDidSelect(_ index: Int) {}
}

extension PageContainer {
    private func itemsDidChange() {
        var newBarButtonItems: [PageBarButtonItem] = []
        var newScreens: [UIViewController] = []

        items.forEach {
            preparePageForUse($0)

            newBarButtonItems.append($0.barButtonItem)
            newScreens.append($0.screen)
        }

        pageBar.items = newBarButtonItems
        screens = newScreens

        if !isLayoutFinalized {
            return
        }

        pagesView.reloadData()
        pagesView.layoutIfNeeded()
    }

    private func preparePageForUse(
        _ item: PageBarItem
    ) {
        pagesView.register(PageCell.self, forCellWithReuseIdentifier: item.id)

        addChild(item.screen)
        item.screen.didMove(toParent: self)
    }

    private func selectedItemDidChange() {
        guard let selectedIndex = selectedIndex else {
            return
        }

        if !isLayoutFinalized {
            return
        }

        /// <note>
        /// If `isViewAppeared=true`, then scroll delegate will handle the selected page bar item.
        if !isViewAppeared {
            pageBar.scrollToItem(at: selectedIndex, animated: false)
        }

        let currenIndexPath = pagesView.indexPathForItemAtCenter()
        let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)

        if currenIndexPath == selectedIndexPath {
            return
        }

        pagesView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: isViewAppeared)
    }
}

/// <mark>
/// UICollectionViewDataSource
extension PageContainer {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]

        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.id, for: indexPath) as! PageCell
        // swiftlint:enable force_cast
        cell.contextView = item.screen.view

        return cell
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension PageContainer {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return pageSize ?? collectionView.bounds.size
    }
}

/// <mark>
/// UIScrollViewDelegate
extension PageContainer {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLayoutFinalized {
            return
        }

        if items.isEmpty {
            return
        }

        pageBar.scrollToItem(at: scrollView.contentOffset.x - pageBar.frame.minX, animated: false)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard selectedIndex != pageBar.selectedPage else {
            return
        }

        selectedIndex = pageBar.selectedPage
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }

        selectedIndex = pageBar.selectedPage
    }
}
