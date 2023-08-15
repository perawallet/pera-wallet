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

    private var playerLayerIsReadyForDisplayDisplayObserver: NSKeyValueObservation?

    private var isPlaying: Bool {
        guard let player = currentPlayer else {
            return false
        }
        return player.rate > 0
    }

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

        videoPlayerView.isHidden = true
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

        threeDModeActionView.isHidden = true
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

        fullScreenActionView.isHidden = true
    }
}

extension CollectibleMediaVideoPreviewView {
    func bindData(
        _ viewModel: CollectibleMediaVideoPreviewViewModel?
    ) {
        guard let viewModel = viewModel else {
            prepareForReuse()
            return
        }

        placeholderView.placeholder = viewModel.placeholder

        overlayView.image = viewModel.overlayImage

        guard let url = viewModel.url else {
            return
        }

        videoPlayerView.player = AVPlayer(url: url)

        addObservers(viewModel: viewModel)
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
        if isPlaying {
            return
        }

        videoPlayerView.player?.play()
    }

    func stopVideo() {
        if !isPlaying {
            return
        }

        videoPlayerView.player?.pause()
    }
}

extension CollectibleMediaVideoPreviewView {
    func prepareForReuse() {
        removeObservers()
        stopVideo()
        videoPlayerView.player = nil
        videoPlayerView.isHidden = true
        placeholderView.isHidden = false
        placeholderView.prepareForReuse()
        overlayView.image = nil
        threeDModeActionView.isHidden = true
        fullScreenActionView.isHidden = true
    }
}

extension CollectibleMediaVideoPreviewView {
    private func addObservers(viewModel: CollectibleMediaVideoPreviewViewModel) {
        addPlayerItemDidPlayToEndTimeObserver()
        addPlayerLayerIsReadyForDisplayDisplayObserver(viewModel: viewModel)
    }

    private func addPlayerItemDidPlayToEndTimeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: videoPlayerView.player?.currentItem
        )
    }

    private func addPlayerLayerIsReadyForDisplayDisplayObserver(
        viewModel: CollectibleMediaVideoPreviewViewModel
    ) {
        playerLayerIsReadyForDisplayDisplayObserver = makePlayerLayerIsReadyForDisplayDisplayObserver(viewModel: viewModel)
    }

    private func removeObservers() {
        removePlayerItemDidPlayToEndTimeObserver()
        removePlayerLayerIsReadyForDisplayDisplayObserver()
    }

    private func removePlayerItemDidPlayToEndTimeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    private func removePlayerLayerIsReadyForDisplayDisplayObserver() {
        playerLayerIsReadyForDisplayDisplayObserver?.invalidate()
        playerLayerIsReadyForDisplayDisplayObserver = nil
    }
}

extension CollectibleMediaVideoPreviewView {
    private func makePlayerLayerIsReadyForDisplayDisplayObserver(
        viewModel: CollectibleMediaVideoPreviewViewModel
    ) -> NSKeyValueObservation? {
        let observer = videoPlayerView.playerLayer?.observe(
            \.isReadyForDisplay,
             options:  [.new]
        ) {
            [weak self] (playerLayer, change) in
            guard let self else {
                return
            }

            guard playerLayer.isReadyForDisplay else {
                return
            }

            self.removePlayerLayerIsReadyForDisplayDisplayObserver()

            self.updateUIWhenPlayerLayerIsReadyForDisplay(viewModel: viewModel)
        }
        return observer
    }
}

extension CollectibleMediaVideoPreviewView {
    private func updateUIWhenPlayerLayerIsReadyForDisplay(
        viewModel: CollectibleMediaVideoPreviewViewModel
    ) {
        UIView.transition(
            from: placeholderView,
            to: videoPlayerView,
            duration: 0.3,
            options: [.transitionCrossDissolve, .showHideTransitionViews, .allowUserInteraction]
        )

        threeDModeActionView.isHidden = viewModel.is3DModeActionHidden
        fullScreenActionView.isHidden = viewModel.isFullScreenActionHidden
    }
}

extension CollectibleMediaVideoPreviewView {
    enum Event {
        case performFullScreenAction
        case perform3DModeAction
    }
}
