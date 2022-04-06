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

final class CollectibleMediaVideoPreviewView:
    View,
    ViewModelBindable,
    ListReusable {

    private lazy var videoPlayerView = VideoPlayerView()
    private lazy var overlayView = UIView()

    func customize(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        addVideoPlayerView(theme)
        addOverlayView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}

extension CollectibleMediaVideoPreviewView {
    private func addVideoPlayerView(
        _ theme: CollectibleMediaVideoPreviewViewTheme
    ) {
        videoPlayerView.layer.draw(corner: theme.corner)
        videoPlayerView.clipsToBounds = true

        addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.setPaddings()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: videoPlayerView.player?.currentItem
        )
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
}

extension CollectibleMediaVideoPreviewView {
    func bindData(
        _ viewModel: CollectibleMediaVideoPreviewViewModel?
    ) {
        guard let viewModel = viewModel,
              let url = viewModel.url else {
            return
        }

        let videoPlayer = AVPlayer(url: url)
        videoPlayer.playImmediately(atRate: 1)
        videoPlayerView.player = videoPlayer

        if !viewModel.isOwned {
            overlayView.alpha = 0.4
        } else {
            overlayView.alpha = 0.0
        }
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
        overlayView.alpha = 0.0
    }
}
