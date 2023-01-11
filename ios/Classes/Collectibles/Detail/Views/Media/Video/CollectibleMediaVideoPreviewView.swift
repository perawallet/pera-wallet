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
    ListReusable {

    private lazy var placeholderView = URLImagePlaceholderView()
    private(set) lazy var videoPlayerView = VideoPlayerView()
    private lazy var overlayView = UIView()
    private lazy var fullScreenBadge = ImageView()

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
        addFullScreenBadge(theme)
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
        overlayView.customizeAppearance(theme.overlay)
        overlayView.layer.draw(corner: theme.corner)
        overlayView.clipsToBounds = true
        overlayView.alpha = 0.0

        addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addFullScreenBadge(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        fullScreenBadge.customizeAppearance(theme.fullScreenBadge)
        fullScreenBadge.layer.draw(corner: theme.corner)

        fullScreenBadge.contentEdgeInsets = theme.fullScreenBadgeContentEdgeInsets
        addSubview(fullScreenBadge)
        fullScreenBadge.snp.makeConstraints {
            $0.trailing == theme.fullScreenBadgePaddings.trailing
            $0.bottom == theme.fullScreenBadgePaddings.bottom
        }
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
        
        overlayView.alpha = viewModel.displaysOffColorMedia ? 0.4 : 0.0

        fullScreenBadge.isHidden = viewModel.isFullScreenBadgeHidden
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
        overlayView.alpha = 0.0
        fullScreenBadge.isHidden = false
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
