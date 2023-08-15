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
import MacaroonUtils
import AVFoundation

final class CollectibleMediaPreviewViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    NotificationObserver {
    static let theme = Theme()

    var eventHandler: ((Event) -> Void)?

    var notificationObservations: [NSObjectProtocol] = []

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
        collectionView.register(CollectibleMediaImagePreviewCell.self)
        collectionView.register(CollectibleMediaVideoPreviewCell.self)
        collectionView.register(CollectibleMediaAudioPreviewCell.self)
        return collectionView
    }()

    private lazy var imageTransitionDelegate = ImageTransitionDelegate()
    private lazy var videoTransitionDelegate = VideoTransitionDelegate()

    private lazy var pageControl = UIPageControl()

    private var selectedIndex = 0 {
        didSet {
            pageControl.currentPage = selectedIndex

            let selectedMedia = asset.media[safe: selectedIndex]
            eventHandler?(.didScrollToMedia(selectedMedia))
        }
    }

    private var isPageControlSizeUpdated = false

    private lazy var dataSource = CollectibleMediaPreviewDataSource(
        theme: Self.theme,
        asset: asset,
        accountCollectibleStatus: accountCollectibleStatus
    )

    private var asset: CollectibleAsset
    private var accountCollectibleStatus: AccountCollectibleStatus {
        didSet {
            if accountCollectibleStatus != oldValue {
                dataSource.accountCollectibleStatus = accountCollectibleStatus
                listView.reloadData()
            }
        }
    }
    
    private let thumbnailImage: UIImage?

    init(
        asset: CollectibleAsset,
        accountCollectibleStatus: AccountCollectibleStatus,
        thumbnailImage: UIImage?,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.accountCollectibleStatus = accountCollectibleStatus
        self.thumbnailImage = thumbnailImage
        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    class func calculatePreferredSize(
        _ asset: CollectibleAsset?,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let asset = asset else {
            return CGSize((size.width, 0))
        }

        let mediaHeight =
            size.width -
            2 * Self.theme.horizontalInset

        var preferredHeight: CGFloat = mediaHeight.float()

        if asset.media.count > 1 {
            let pageControlHeight: CGFloat = Self.theme.pageControlHeight
            preferredHeight += pageControlHeight
        }

        return CGSize((size.width, min(preferredHeight.float(), size.height)))
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

        pageControl.addTarget(
            self,
            action: #selector(didTapPageControl),
            for: .valueChanged
        )
    }

    override func setListeners() {
        super.setListeners()

        observeWhenApplicationDidEnterBackground {
            [weak self] _ in
            self?.stopMediaIfNeeded()
        }

        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            self?.playMediaIfNeeded()
        }
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playMediaIfNeededWhenViewDidAppear()
    }

    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        playMediaIfNeededWhenViewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopMediaIfNeededWhenViewDidDisappear()
    }
}

extension CollectibleMediaPreviewViewController {
    private func playMediaIfNeededWhenViewDidAppear() {
        playMediaIfNeeded()
    }

    private func stopMediaIfNeededWhenViewDidDisappear() {
        stopMediaIfNeeded()
    }

    private func playMediaIfNeeded() {
        if let playableMediaPreviewCell = currentVisibleCell as? CollectiblePlayableMediaPreviewCell {
            playableMediaPreviewCell.play()
            return
        }
    }

    private func stopMediaIfNeeded() {
        if let playableMediaPreviewCell = currentVisibleCell as? CollectiblePlayableMediaPreviewCell {
            playableMediaPreviewCell.stop()
            return
        }
    }
}

extension CollectibleMediaPreviewViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addPageControl() {
        let theme = Self.theme

        pageControl.pageIndicatorTintColor = theme.pageIndicatorTintColor.uiColor
        pageControl.currentPageIndicatorTintColor = theme.currentPageIndicatorTintColor.uiColor

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top == listView.snp.bottom
            $0.leading.trailing
                .lessThanOrEqualToSuperview()
                .inset(theme.horizontalInset)
            $0.bottom == 0
        }

        configurePageControl()
    }
}

extension CollectibleMediaPreviewViewController {
    @objc
    private func didTapPageControl(_ sender: UIPageControl) {
        if selectedIndex == sender.currentPage {
            return
        }

        selectedIndex = sender.currentPage

        listView.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
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
    
    func updateAccountCollectibleStatus(_ accountCollectibleStatus: AccountCollectibleStatus) {
        self.accountCollectibleStatus = accountCollectibleStatus
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
            cell.handlers.didTap3DModeAction = {
                [weak self, weak cell] in
                guard let self,
                      let cell else {
                    return
                }
                
                guard let image = cell.contextView.currentImage else {
                    return
                }

                self.open3DCardForImage(
                    image: image,
                    rendersContinuously: media.isGIF
                )
            }
            cell.handlers.didTapFullScreenAction = {
                [weak self, weak cell] in
                guard let self,
                      let cell else {
                    return
                }

                let image = cell.contextView.currentImage

                guard let image = image else {
                    return
                }

                self.openFullScreenImagePreview(
                    image: image,
                    media: media
                )
            }
        case .video:
            guard let cell = cell as? CollectibleMediaVideoPreviewCell else {
                return
            }

            cell.startObserving(event: .perform3DModeAction) {
                [weak self, weak cell] in
                guard let self,
                      let cell else {
                    return
                }

                guard let mediaURL = media.downloadURL else {
                    return
                }

                cell.stop()
                
                self.open3DCardForVideo(
                    url: mediaURL,
                    didDismiss: {
                        [weak cell] in
                        cell?.play()
                    }
                )
            }
            cell.startObserving(event: .performFullScreenAction) {
                [weak self, weak cell] in
                guard let self,
                      let cell else {
                    return
                }
                
                let player = cell.contextView.currentPlayer

                guard let player = player else {
                    return
                }

                cell.stop()

                self.openFullScreenVideoPreview(
                    with: player,
                    didDismiss: {
                        [weak cell] in
                        cell?.play()
                    }
                )
            }
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
        case .audio:
            guard let cell = cell as? CollectibleMediaAudioPreviewCell else {
                return
            }
            
            cell.stop()
        case .video:
            guard let cell = cell as? CollectibleMediaVideoPreviewCell else {
                return
            }

            cell.stop()
        default:
            break
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

    private func open3DCardForImage(
        image: UIImage,
        rendersContinuously: Bool
    ) {
        open(
            .image3DCard(
                image: image,
                rendersContinuously: rendersContinuously
            ),
            by: .presentWithoutNavigationController
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
    
    private func open3DCardForVideo(
        url: URL,
        didDismiss: @escaping (() -> Void)
    ) {
        if isScrolling {
            return
        }

        let screen = open(
            .video3DCard(
                image: thumbnailImage,
                url: url
            ),
            by: .presentWithoutNavigationController
        ) as? Collectible3DVideoViewController
        screen?.eventHandler = {
            [weak screen] event in
            switch event {
            case .didClose:
                screen?.dismissScreen()
                didDismiss()
            }
        }
        screen?.presentationController?.delegate = self
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        performActionsWhenScrollDidFinish()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }

        performActionsWhenScrollDidFinish()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        performActionsWhenScrollDidFinish()
    }

    private func performActionsWhenScrollDidFinish() {
        for visibleCell in listView.visibleCells {
            if let playableMediaPreviewCell = visibleCell as? CollectiblePlayableMediaPreviewCell,
               currentVisibleCell != playableMediaPreviewCell {
                playableMediaPreviewCell.stop()
            }
        }

        if let playableMediaPreviewCell = currentVisibleCell as? CollectiblePlayableMediaPreviewCell {
            playableMediaPreviewCell.play()
            return
        }
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
    var isScrolling: Bool {
        return
            listView.isDragging ||
            listView.isDecelerating ||
            listView.isTracking

    }
}

extension CollectibleMediaPreviewViewController {
    enum Event {
        case didScrollToMedia(Media?)
    }
}
