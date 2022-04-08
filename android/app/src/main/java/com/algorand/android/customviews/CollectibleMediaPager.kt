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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import com.algorand.android.databinding.CustomCollectibleMediaPagerBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.nfsdetail.CollectibleMediaAdapter
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator

class CollectibleMediaPager(context: Context, attrs: AttributeSet? = null) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomCollectibleMediaPagerBinding::inflate)

    private var pagerListener: MediaPagerListener? = null

    private var adapterListener = object : CollectibleMediaAdapter.MediaClickListener {
        override fun onVideoMediaClick(videoUrl: String?) {
            pagerListener?.onVideoMediaClick(videoUrl)
        }
    }

    private val adapter = CollectibleMediaAdapter(adapterListener)

    init {
        initRootLayout()
    }

    fun setListener(listener: MediaPagerListener) {
        pagerListener = listener
    }

    fun submitList(mediaList: List<BaseCollectibleMediaItem>) {
        adapter.submitList(mediaList)
        binding.collectibleMediaTabLayout.isVisible = mediaList.size > 1
    }

    private fun initRootLayout() {
        with(binding) {
            collectibleMediaViewPager.adapter = adapter
            TabLayoutMediator(collectibleMediaTabLayout, collectibleMediaViewPager) { _, _ -> }.attach()
        }
    }

    interface MediaPagerListener {
        fun onVideoMediaClick(videoUrl: String?)
    }
}
