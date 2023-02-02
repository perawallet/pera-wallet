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

//   CollectibleMediaVideoPreviewView.swift

import UIKit
import MacaroonUIKit
import AVKit
import AVFoundation
import MacaroonURLImage

final class CollectibleMediaVideoPreviewView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .perform3DModeAction: TargetActionInteraction(),
        .performFullScreenAction: TargetActionInteraction()
    ]

    private lazy var placeholderView = URLImagePlaceholderView()
    private(set) lazy var videoPlayerView = VideoPlayerView()
    private lazy var overlayView = UIImageView()
    private lazy var threeDModeActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    private lazy var fullScreenActionView = MacaroonUIKit.Button()
    private(set) var isReadyForDisplay = false

    private var playerStateObserver: NSKeyValueObservation?

    var currentPlayer: AVPlayer? {
        return videoPlayerView.player
    }

    func customize(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        addPlaceholderView(theme)
        addVideoPlayerView(theme)
        addOverlayView(theme)
        add3DModeAction(theme)
        addFullScreenAction(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    deinit {
        removeObservers()
    }
}

extension CollectibleMediaVideoPreviewView {
    private func addPlaceholderView(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        placeholderView.build(theme.placeholder)
        placeholderView.layer.draw(corner: theme.corner)
        placeholderView.clipsToBounds = true

        addSubview(placeholderView)
        placeholderView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addVideoPlayerView(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        videoPlayerView.layer.draw(corner: theme.corner)
        videoPlayerView.clipsToBounds = true

        addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addOverlayView(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func add3DModeAction(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        threeDModeActionView.customizeAppearance(theme.threeDAction)

        addSubview(threeDModeActionView)
        threeDModeActionView.contentEdgeInsets = UIEdgeInsets(theme.threeDActionContentEdgeInsets)
        threeDModeActionView.snp.makeConstraints {
            $0.leading == theme.threeDModeActionPaddings.leading
            $0.bottom == theme.threeDModeActionPaddings.bottom
        }

        startPublishing(
            event: .perform3DModeAction,
            for: threeDModeActionView
        )
    }

    private func addFullScreenAction(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        fullScreenActionView.customizeAppearance(theme.fullScreenAction)

        addSubview(fullScreenActionView)
        fullScreenActionView.snp.makeConstraints {
            $0.trailing == theme.fullScreenBadgePaddings.trailing
            $0.bottom == theme.fullScreenBadgePaddings.bottom
        }

        startPublishing(
            event: .performFullScreenAction,
            for: fullScreenActionView
        )
    }
}

extension CollectibleMediaVideoPreviewView {
    func bindData(
        _ viewModel: CollectibleMediaVideoPreviewViewModel?
    ) {
        placeholderView.placeholder = viewModel?.placeholder

        guard let viewModel = viewModel,
              let url = viewModel.url else {
            return
        }

        playerStateObserver = videoPlayerView.playerLayer?.observe(
            \.isReadyForDisplay,
             options:  [.new]
        ) {
            [weak self] (playerLayer, change) in
            guard let self = self else { return }
            self.placeholderView.isHidden = playerLayer.isReadyForDisplay
            self.isReadyForDisplay = playerLayer.isReadyForDisplay
        }

        let videoPlayer = AVPlayer(url: url)
        videoPlayer.playImmediately(atRate: 1)
        videoPlayerView.player = videoPlayer

        addObservers()

        overlayView.image = viewModel.overlayImage
        threeDModeActionView.isHidden = viewModel.is3DModeActionHidden
        fullScreenActionView.isHidden = viewModel.isFullScreenActionHidden
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaVideoPreviewViewModel?,
        for theme: CollectibleMediaVideoPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, size.height))
    }
}

extension CollectibleMediaVideoPreviewView {
    @objc
    private func playerItemDidReachEnd() {
        videoPlayerView.player?.seek(to: .zero)
        videoPlayerView.player?.play()
    }
}

extension CollectibleMediaVideoPreviewView {
    func playVideo() {
        videoPlayerView.player?.play()
    }

    func stopVideo() {
        videoPlayerView.player?.pause()
    }
}

extension CollectibleMediaVideoPreviewView {
    func prepareForReuse() {
        removeObservers()
        playerStateObserver?.invalidate()
        stopVideo()
        videoPlayerView.player = nil
        placeholderView.prepareForReuse()
        overlayView.image = nil
        threeDModeActionView.isHidden = false
        fullScreenActionView.isHidden = false
    }
}

extension CollectibleMediaVideoPreviewView {
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: videoPlayerView.player?.currentItem
        )
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}

extension CollectibleMediaVideoPreviewView {
    enum Event {
        case performFullScreenAction
        case perform3DModeAction
    }
}
