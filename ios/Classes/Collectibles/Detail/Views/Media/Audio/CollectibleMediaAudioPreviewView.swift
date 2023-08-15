// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleMediaAudioPreviewView.swift

import AVFoundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class CollectibleMediaAudioPreviewView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var placeholderView = URLImagePlaceholderView()
    private(set) lazy var audioPlayerView = AudioPlayerView()
    private lazy var audioPlayingStateView = UIImageView()
    private lazy var overlayView = UIImageView()

    private var playerTimeObserver: Any?

    private var isPlaying: Bool {
        guard let player = currentPlayer else {
            return false
        }
        return player.rate > 0
    }

    var currentPlayer: AVPlayer? {
        return audioPlayerView.player
    }
    
    func customize(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        addPlaceholderView(theme)
        addAudioPlayerView(theme)
        addAudioPlayingStateView(theme)
        addOverlayView(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    deinit {
        removeObservers()
    }
}

extension CollectibleMediaAudioPreviewView {
    private func addPlaceholderView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        placeholderView.build(theme.placeholder)
        placeholderView.layer.draw(corner: theme.corner)
        placeholderView.clipsToBounds = true
        
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addAudioPlayerView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        audioPlayerView.layer.draw(corner: theme.corner)
        audioPlayerView.clipsToBounds = true
        
        addSubview(audioPlayerView)
        audioPlayerView.snp.makeConstraints {
            $0.setPaddings()
        }

        audioPlayerView.isHidden = true
    }

    private func addAudioPlayingStateView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        audioPlayingStateView.customizeAppearance(theme.audioPlayingState)

        audioPlayerView.addSubview(audioPlayingStateView)
        audioPlayingStateView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addOverlayView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectibleMediaAudioPreviewView {
    func bindData(_ viewModel: CollectibleMediaAudioPreviewViewModel?) {
        guard let viewModel else {
            prepareForReuse()
            return
        }

        placeholderView.placeholder = viewModel.placeholder

        overlayView.image = viewModel.overlayImage

        guard let url = viewModel.url else {
            return
        }

        audioPlayerView.player = AVPlayer(url: url)
        
        addObservers()
    }
    
    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaAudioPreviewViewModel?,
        for layoutSheet: CollectibleMediaAudioPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, size.height))
    }
}

extension CollectibleMediaAudioPreviewView {
    func prepareForReuse() {
        removeObservers()
        stopAudio()
        audioPlayerView.player = nil
        audioPlayerView.isHidden = true
        placeholderView.prepareForReuse()
        placeholderView.isHidden = false
        overlayView.image = nil
    }
}

extension CollectibleMediaAudioPreviewView {
    func playAudio() {
        if isPlaying {
            return
        }

        addPlayerTimeObserver()

        currentPlayer?.play()
    }

    func stopAudio() {
        if !isPlaying {
            return
        }

        currentPlayer?.pause()

        removeTimeObserverIfNeeded()

        updateUIForPlayingState(isPlaying: false)
    }
}

extension CollectibleMediaAudioPreviewView {
    private func addPlayerTimeObserver() {
        playerTimeObserver = makePlayerTimeObserver()
    }

    private func makePlayerTimeObserver() -> Any? {
        guard let player = currentPlayer else {
            return nil
        }

        let interval = CMTime(
            seconds: 0.5,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        let observer = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self, weak player] _ in
            guard let self = self,
                  let player = player,
                  let currentItem = player.currentItem,
                  currentItem.currentTime().seconds <= currentItem.duration.seconds else {
                return
            }

            removeTimeObserverIfNeeded()

            updateUIForPlayingState(isPlaying: true)
        }

        return observer
    }
}

extension CollectibleMediaAudioPreviewView {
    private func updateUIForPlayingState(isPlaying: Bool) {
        let fromView = isPlaying ? placeholderView : audioPlayerView
        let toView = isPlaying ? audioPlayerView : placeholderView
        UIView.transition(
            from: fromView,
            to: toView,
            duration: 0.3,
            options: [.transitionCrossDissolve, .showHideTransitionViews, .allowUserInteraction]
        )
    }
}

extension CollectibleMediaAudioPreviewView {
    private func addObservers() {
        addPlayerItemDidPlayToEndTimeObserver()
    }

    private func addPlayerItemDidPlayToEndTimeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayerView.player?.currentItem
        )
    }
    
    private func removeObservers() {
        removePlayerItemDidPlayToEndTimeObserver()
        removeTimeObserverIfNeeded()
    }

    private func removePlayerItemDidPlayToEndTimeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    private func removeTimeObserverIfNeeded() {
        if let playerTimeObserver {
            self.currentPlayer?.removeTimeObserver(playerTimeObserver)
            self.playerTimeObserver = nil
        }
    }
}

extension CollectibleMediaAudioPreviewView {
    @objc
    private func playerItemDidReachEnd() {
        currentPlayer?.seek(to: .zero)
        currentPlayer?.play()
    }
}
