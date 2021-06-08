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
//  AssetCardDisplayView.swift

import UIKit

class AssetCardDisplayView: BaseView {
    
    private var isPageControlSizeUpdateCompleted = false
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = CardViewConstants.cardSpacing
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: CardViewConstants.cardInset, bottom: 0, right: CardViewConstants.cardInset)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.register(AlgosCardCell.self, forCellWithReuseIdentifier: AlgosCardCell.reusableIdentifier)
        collectionView.register(AssetCardCell.self, forCellWithReuseIdentifier: AssetCardCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = Colors.Text.primary.withAlphaComponent(0.1)
        pageControl.currentPageIndicatorTintColor = Colors.General.selected
        return pageControl
    }()

    override func prepareLayout() {
        setupAssetsCollectionViewLayout()
        setupPageControlLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isPageControlSizeUpdateCompleted {
            pageControl.subviews.forEach {
                $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            }
            isPageControlSizeUpdateCompleted = true
        }
    }
}

extension AssetCardDisplayView {
    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.height.equalTo(CardViewConstants.cardHeight)
        }
    }
    
    private func setupPageControlLayout() {
        addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(assetsCollectionView.snp.bottom).offset(layout.current.pageControlTopInset)
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.pageControlHorizontalInset)
        }
    }
}

extension AssetCardDisplayView {
    func reloadData() {
        assetsCollectionView.reloadData()
    }
    
    func reloadData(at index: Int) {
        assetsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func item(at index: Int) -> UICollectionViewCell? {
        return assetsCollectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        assetsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        assetsCollectionView.dataSource = dataSource
    }
    
    func setCurrentPage(_ page: Int) {
        pageControl.currentPage = page
    }
    
    func setNumberOfPages(_ pageCount: Int) {
        pageControl.numberOfPages = pageCount
    }
    
    func index(for cell: UICollectionViewCell) -> Int? {
        return assetsCollectionView.indexPath(for: cell)?.item
    }
    
    func scrollTo(_ index: Int, animated: Bool) {
        assetsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: . centeredHorizontally, animated: animated)
    }
    
    var contentWidth: CGFloat {
        return assetsCollectionView.contentSize.width
    }
    
    var currentPage: Int {
        return pageControl.currentPage
    }
    
    var numberOfPages: Int {
        return pageControl.numberOfPages
    }
}

extension AssetCardDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let pageControlHorizontalInset: CGFloat = 20.0
        let pageControlTopInset: CGFloat = 16.0
    }
}

extension AssetCardDisplayView {
    enum CardViewConstants {
        static let height: CGFloat = 322.0
        static let cardHeight: CGFloat = 250.0
        static let cardWidth: CGFloat = UIScreen.main.bounds.width - CardViewConstants.cardInset * 2.0
        static let cardSpacing: CGFloat = 12.0
        static let cardInset: CGFloat = 24.0
    }
}
