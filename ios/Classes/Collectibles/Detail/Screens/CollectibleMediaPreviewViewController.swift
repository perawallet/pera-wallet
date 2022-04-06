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

//   CollectibleMediaPreviewViewController.swift

import UIKit
import MacaroonUIKit
import AVFoundation

final class CollectibleMediaPreviewViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private let theme = Theme()

    var eventHandler: ((Event) -> Void)?

    private typealias Index = Int
    private var existingImages: [Index: UIImage?]?

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = theme.cellSpacing
        flowLayout.sectionInset.left = theme.horizontalInset
        flowLayout.sectionInset.right = theme.horizontalInset

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        collectionView.register(
            CollectibleMediaImagePreviewCell.self
        )
        collectionView.register(
            CollectibleMediaVideoPreviewCell.self
        )
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = AppColors.Shared.Layer.gray.uiColor
        pageControl.currentPageIndicatorTintColor = AppColors.Shared.Helpers.positive.uiColor
        return pageControl
    }()

    private var selectedIndex = 0 {
        didSet {
            pageControl.currentPage = selectedIndex
            selectedMedia = asset.media[safe: selectedIndex]
            eventHandler?(.didScrollToMedia(selectedMedia))
        }
    }

    private var selectedMedia: Media?

    private var isPageControlSizeUpdated = false

    private lazy var dataSource = CollectibleMediaPreviewDataSource(
        theme: theme,
        asset: asset
    )

    private var asset: CollectibleAsset
    private let thumbnailImage: UIImage?

    init(
        asset: CollectibleAsset,
        thumbnailImage: UIImage?,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.thumbnailImage = thumbnailImage
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
        addPageControl()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
        listView.dataSource = dataSource

        if let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            listView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        /// Update page control dot sizes if needed.
        if !isPageControlSizeUpdated {
            pageControl.subviews.forEach {
                $0.transform = CGAffineTransform(
                    scaleX: theme.pageControlScale,
                    y: theme.pageControlScale
                )
            }

            isPageControlSizeUpdated = true
        }
    }
}

extension CollectibleMediaPreviewViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == 0
        }
    }

    private func addPageControl() {
        view.addSubview(pageControl)

        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top == listView.snp.bottom
            $0.bottom == 0
            $0.leading.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalInset)
        }

        configurePageControl()
    }
}

extension CollectibleMediaPreviewViewController {
    func updateAsset(_ asset: CollectibleAsset) {
        self.asset = asset
        configurePageControl()
    }

    func getExistingImage() -> UIImage? {
        if let image = existingImages?[selectedIndex] {
            return image
        }

        return nil
    }

    private func configurePageControl() {
        if asset.media.count > 1 {
            pageControl.numberOfPages = asset.media.count
        }
    }
}

extension CollectibleMediaPreviewViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width =
            collectionView.bounds.width -
            theme.horizontalInset * 2
        return CGSize(width: width.float(), height: width.float())
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let media = asset.media[safe: indexPath.item] else {
            return
        }

        switch media.type {
        case .image:
            guard let cell = cell as? CollectibleMediaImagePreviewCell else {
                return
            }

            cell.handlers.didLoadImage = {
                [weak self] image in
                guard let self = self else {
                    return
                }

                self.existingImages = [indexPath.item: image]
            }
        case .video:
            guard let cell = cell as? CollectibleMediaVideoPreviewCell else {
                return
            }

            cell.playVideo()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let media = asset.media[safe: indexPath.item] else {
            return
        }

        switch media.type {
        case .video:
            guard let cell = cell as? CollectibleMediaVideoPreviewCell else {
                return
            }

            cell.stopVideo()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let media = asset.media[safe: indexPath.item] else {
            return
        }

        open3DCard(
            for: media,
            at: indexPath
        )

        eventHandler?(.didSelectMedia(media, indexPath))
    }

    private func open3DCard(
        for media: Media,
        at indexPath: IndexPath
    ) {
        switch media.type {
        case .image:
            if let cell = listView.cellForItem(at: indexPath) as? CollectibleMediaImagePreviewCell,
               let image = cell.contextView.currentImage {
                open(
                    .image3DCard(
                        image: image
                    ),
                    by: .presentWithoutNavigationController
                )
            }
        case .video:
            if let url = media.downloadURL {
                open(
                    .video3DCard(
                        image: thumbnailImage,
                        url: url
                    ),
                    by: .presentWithoutNavigationController
                )
            }
        default: break
        }
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth =
            listView.bounds.width -
            theme.horizontalInset * 2 +
            theme.cellSpacing

        var newPage = CGFloat(selectedIndex)

        if velocity.x == 0 {
            newPage = floor((targetContentOffset.pointee.x - pageWidth / 2) / pageWidth) + 1.0
        } else {
            newPage = CGFloat(velocity.x > 0 ? selectedIndex + 1 : selectedIndex - 1)
            if newPage < 0 {
                return
            }

            if newPage > listView.contentSize.width / pageWidth {
                newPage = ceil(listView.contentSize.width / pageWidth) - 1.0
            }
        }

        if newPage >= CGFloat(asset.media.count) {
            return
        }

        selectedIndex = Int(newPage)

        targetContentOffset.pointee = CGPoint(
            x: newPage * pageWidth,
            y: targetContentOffset.pointee.y
        )
    }
}

extension CollectibleMediaPreviewViewController {
    enum Event {
        case didScrollToMedia(Media?)
        case didSelectMedia(Media, IndexPath)
    }
}
