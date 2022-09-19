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
    static let theme = Theme()

    var eventHandler: ((Event) -> Void)?

    private typealias Index = Int
    private var existingImages: [Index: UIImage?]?

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = Self.theme.cellSpacing
        flowLayout.sectionInset.left = Self.theme.horizontalInset
        flowLayout.sectionInset.right = Self.theme.horizontalInset

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

    private lazy var imageTransitionDelegate = ImageTransitionDelegate()
    private lazy var videoTransitionDelegate = VideoTransitionDelegate()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = Colors.Text.gray.uiColor
        pageControl.currentPageIndicatorTintColor = Colors.Helpers.positive.uiColor
        return pageControl
    }()

    private lazy var tap3DActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))

    private var selectedIndex = 0 {
        didSet {
            pageControl.currentPage = selectedIndex
            selectedMedia = asset.media[safe: selectedIndex]
            eventHandler?(.didScrollToMedia(selectedMedia))

            tap3DActionView.isHidden = !(selectedMedia?.type.isSupported ?? false)
        }
    }

    private var selectedMedia: Media?

    private var isPageControlSizeUpdated = false

    private lazy var dataSource = CollectibleMediaPreviewDataSource(
        theme: Self.theme,
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

    class func calculatePreferredSize(
        _ asset: CollectibleAsset?,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let asset = asset else {
            return CGSize((size.width, 0))
        }

        let tap3DViewHeight: CGFloat = 24
        let tap3DViewTopPadding = Self.theme.tap3DActionViewTopPadding

        let mediaHeight =
        size.width -
        2 * Self.theme.horizontalInset

        var preferredHeight: CGFloat =
        mediaHeight.float() +
        tap3DViewHeight +
        tap3DViewTopPadding

        if asset.media.count > 1 {
            let pageControlHeight: CGFloat = 26
            preferredHeight += pageControlHeight
        }

        return CGSize((size.width, min(preferredHeight.float(), size.height)))
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
        addPageControl()
        addTap3DActionView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
        listView.dataSource = dataSource

        if let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            listView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }

        tap3DActionView.addTouch(
            target: self,
            action: #selector(didTap3DActionView)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedIndex = .zero
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        /// Update page control dot sizes if needed.
        if !isPageControlSizeUpdated {
            pageControl.subviews.forEach {
                $0.transform = CGAffineTransform(
                    scaleX: Self.theme.pageControlScale,
                    y: Self.theme.pageControlScale
                )
            }

            isPageControlSizeUpdated = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let visibleCells = listView.visibleCells

        for visibleCell in visibleCells {
            guard let videoCell = visibleCell as? CollectibleMediaVideoPreviewCell else {
                continue
            }

            videoCell.stopVideo()
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
            $0.leading.trailing
                .lessThanOrEqualToSuperview()
                .inset(Self.theme.horizontalInset)
        }

        configurePageControl()
    }

    private func addTap3DActionView() {
        tap3DActionView.customizeAppearance(Self.theme.tap3DActionView)

        view.addSubview(tap3DActionView)
        tap3DActionView.snp.makeConstraints {
            $0.leading >= Self.theme.horizontalInset
            $0.trailing <= Self.theme.horizontalInset
            $0.centerX == 0
            $0.top == pageControl.snp.bottom + Self.theme.tap3DActionViewTopPadding
            $0.bottom == 0
        }
    }
}

extension CollectibleMediaPreviewViewController {
    @objc
    private func didTap3DActionView() {
        open3DCard()
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
        Self.theme.horizontalInset * 2
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

        let cell = collectionView.cellForItem(at: indexPath)

        switch media.type {
        case .video:
            let videoPreviewCell = cell as? CollectibleMediaVideoPreviewCell
            let player = videoPreviewCell?.contextView.currentPlayer

            guard let videoPreviewCell = videoPreviewCell,
                  videoPreviewCell.isReadyForDisplay,
                  let player = player else {
                return
            }

            videoPreviewCell.stopVideo()

            openFullScreenVideoPreview(
                with: player,
                didDismiss: {
                    [weak videoPreviewCell] in
                    videoPreviewCell?.playVideo()
                }
            )
        default:
            let imagePreviewCell = cell as? CollectibleMediaImagePreviewCell
            let image = imagePreviewCell?.contextView.currentImage

            guard let image = image else {
                return
            }

            openFullScreenImagePreview(
                image: image,
                media: media
            )
        }
    }

    private func openFullScreenImagePreview(
        image: UIImage,
        media: Media
    ) {
        let draft = CollectibleFullScreenImageDraft(
            image: image,
            media: media
        )
        open(
            .collectibleFullScreenImage(draft: draft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: imageTransitionDelegate
            )
        )
    }

    private func openFullScreenVideoPreview(
        with player: AVPlayer,
        didDismiss: @escaping (() -> Void)
    ) {
        videoTransitionDelegate.didFinishDismissalTransition = didDismiss

        let draft = CollectibleFullScreenVideoDraft(player: player)

        open(
            .collectibleFullScreenVideo(draft: draft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: videoTransitionDelegate
            )
        )
    }

    private func open3DCard() {
        guard let media = selectedMedia else {
            return
        }

        switch media.type {
        case .image:
            if let cell = currentVisibleCell as? CollectibleMediaImagePreviewCell,
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
        Self.theme.horizontalInset * 2 +
        Self.theme.cellSpacing

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
    var currentVisibleCell: UICollectionViewCell? {
        guard let currentItem = listView.indexPathForItemAtCenter() else {
            return nil
        }

        return listView.cellForItem(at: currentItem)
    }
}

extension CollectibleMediaPreviewViewController {
    enum Event {
        case didScrollToMedia(Media?)
    }
}
