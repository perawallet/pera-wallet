/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.nft.ui.videoplayer

import android.net.Uri
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.fragment.app.viewModels
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentVideoPlayerBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.utils.setScreenOrientationFullSensor
import com.algorand.android.utils.setScreenOrientationPortrait
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource

class VideoPlayerFragment : BaseFragment(R.layout.fragment_video_player) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentVideoPlayerBinding::bind)

    private val videoPlayerViewModel by viewModels<VideoPlayerViewModel>()

    private var exoPlayer: ExoPlayer? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        binding.backButton.setOnClickListener { navBack() }
        loadVideo()
    }

    private fun loadVideo() {
        val videoUrl = videoPlayerViewModel.getCollectibleVideoUrl()
        val mediaSource = createMediaSource(videoUrl)
        setupPlayer(mediaSource)
    }

    override fun onResume() {
        super.onResume()
        activity?.setScreenOrientationFullSensor()
        resumePlayer()
    }

    override fun onPause() {
        super.onPause()
        activity?.setScreenOrientationPortrait()
        pausePlayer()
    }

    override fun onDestroy() {
        super.onDestroy()
        destroyExoPlayer()
    }

    private fun resumePlayer() {
        (activity as? MainActivity)?.window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        exoPlayer?.playWhenReady = true
    }

    private fun pausePlayer() {
        (activity as? MainActivity)?.window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        exoPlayer?.playWhenReady = false
    }

    private fun destroyExoPlayer() {
        exoPlayer?.release()
    }

    private fun setupPlayer(mediaSource: MediaSource?) {
        if (mediaSource != null) {
            exoPlayer = ExoPlayer.Builder(binding.root.context).build().apply {
                binding.playerView.player = this
                setMediaSource(mediaSource)
                playWhenReady = true
                prepare()
            }
        }
    }

    private fun createMediaSource(url: String): MediaSource {
        val uri = Uri.parse(url)
        val progressiveMediaSource = ProgressiveMediaSource.Factory(buildDataSourceFactory())
        return progressiveMediaSource.createMediaSource(MediaItem.fromUri(uri))
    }

    private fun buildDefaultBandwidthMeter(): DefaultBandwidthMeter {
        return DefaultBandwidthMeter.Builder(binding.root.context).build()
    }

    private fun buildDataSourceFactory(): DataSource.Factory {
        val httpDataSource = DefaultHttpDataSource.Factory()
        return DefaultDataSource.Factory(binding.root.context, httpDataSource).apply {
            setTransferListener(buildDefaultBandwidthMeter())
        }
    }
}
