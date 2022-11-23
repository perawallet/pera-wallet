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

package com.algorand.android.nft.ui.mediaplayer.audioplayer

import androidx.appcompat.content.res.AppCompatResources
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.nft.ui.mediaplayer.MediaPlayerFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AudioPlayerFragment : MediaPlayerFragment() {

    override val mediaPlayerViewModel by viewModels<AudioPlayerViewModel>()

    override fun initUi() {
        super.initUi()
        binding.playerView.run {
            defaultArtwork = AppCompatResources.getDrawable(context, R.drawable.bg_audio_media_art_works)
            useArtwork = true
        }
    }
}
