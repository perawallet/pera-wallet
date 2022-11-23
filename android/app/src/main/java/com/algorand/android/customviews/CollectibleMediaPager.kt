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
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.viewpager2.widget.MarginPageTransformer
import androidx.viewpager2.widget.ViewPager2
import com.algorand.android.R
import com.algorand.android.databinding.CustomCollectibleMediaPagerBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.nfsdetail.CollectibleMediaAdapter
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator
import kotlin.properties.Delegates

class CollectibleMediaPager(context: Context, attrs: AttributeSet? = null) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomCollectibleMediaPagerBinding::inflate)

    private var pagerListener: MediaPagerListener? = null

    private val adapterListener = object : CollectibleMediaAdapter.MediaClickListener {
        override fun onVideoMediaClick(videoUrl: String?, collectibleImageView: View) {
            pagerListener?.onVideoMediaClick(videoUrl, collectibleImageView)
        }

        override fun onAudioMediaClick(audioUrl: String?, collectibleImageView: View) {
            pagerListener?.onAudioMediaClick(audioUrl, collectibleImageView)
        }

        override fun onImageMediaClick(
            imageUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        ) {
            pagerListener?.onImageMediaClick(
                imageUrl,
                errorDisplayText,
                collectibleImageView,
                mediaType,
                previewPrismUrl
            )
        }

        override fun onGifMediaClick(
            previewUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        ) {
            pagerListener?.onGifMediaClick(
                previewUrl,
                errorDisplayText,
                collectibleImageView,
                mediaType,
                previewPrismUrl
            )
        }
    }

    private val adapter = CollectibleMediaAdapter(adapterListener)

    private var bottomButtonText: String? by Delegates.observable(null) { _, _, newValue ->
        if (!newValue.isNullOrBlank()) binding.collectibleMediaBottomButton.text = newValue
    }

    private var bottomButtonIcon: Drawable? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) binding.collectibleMediaBottomButton.icon = newValue
    }

    private var isBottomButtonVisible: Boolean = false

    private var isFullScreenIconVisible: Boolean = true

    private val pageChangeCallback = object : ViewPager2.OnPageChangeCallback() {
        override fun onPageSelected(position: Int) {
            super.onPageSelected(position)
            onCollectiblePageSelected(position)
        }
    }

    init {
        initAttributes(attrs)
        initRootLayout()
    }

    private fun initAttributes(attributeSet: AttributeSet?) {
        context.obtainStyledAttributes(attributeSet, R.styleable.CollectibleMediaPager).use { attrs ->
            bottomButtonIcon = attrs.getDrawable(R.styleable.CollectibleMediaPager_bottomButtonIcon)
            bottomButtonText = attrs.getString(R.styleable.CollectibleMediaPager_bottomButtonText)
            isBottomButtonVisible =
                attrs.getBoolean(R.styleable.CollectibleMediaPager_isBottomButtonVisible, isBottomButtonVisible)
            isFullScreenIconVisible =
                attrs.getBoolean(R.styleable.CollectibleMediaPager_isFullScreenIconVisible, isFullScreenIconVisible)
        }
    }

    fun setListener(listener: MediaPagerListener) {
        pagerListener = listener
    }

    fun submitList(mediaList: List<BaseCollectibleMediaItem>) {
        adapter.submitList(mediaList)
        binding.collectibleMediaTabLayout.isVisible = mediaList.size > 1
        setPagerSwipeStatus(mediaList.size > 1)
    }

    private fun initRootLayout() {
        with(binding) {
            with(collectibleMediaViewPager) {
                adapter = this@CollectibleMediaPager.adapter
                setPageTransformer(MarginPageTransformer(resources.getDimension(R.dimen.spacing_large).toInt()))
                registerOnPageChangeCallback(pageChangeCallback)
            }
            TabLayoutMediator(collectibleMediaTabLayout, collectibleMediaViewPager) { _, _ -> }.attach()
        }
    }

    private fun setPagerSwipeStatus(isEnabled: Boolean) {
        binding.collectibleMediaViewPager.isUserInputEnabled = isEnabled
    }

    private fun onCollectiblePageSelected(position: Int) {
        val selectedItem = adapter.currentList.getOrNull(position)
        val isSelectedMediaHas3dSupport = selectedItem?.has3dSupport ?: false
        binding.fullScreenImageView.isVisible = isFullScreenIconVisible && selectedItem?.hasFullScreenSupport ?: false
        binding.collectibleMediaBottomButton.apply {
            isInvisible = !isSelectedMediaHas3dSupport || !isBottomButtonVisible || selectedItem?.previewUrl == null
            if (isSelectedMediaHas3dSupport) {
                setOnClickListener { pagerListener?.on3dModeClick(selectedItem?.previewUrl) }
            }
        }
    }

    override fun onDetachedFromWindow() {
        binding.collectibleMediaViewPager.unregisterOnPageChangeCallback(pageChangeCallback)
        super.onDetachedFromWindow()
    }

    interface MediaPagerListener {

        fun onVideoMediaClick(videoUrl: String?, collectibleImageView: View)

        fun onAudioMediaClick(audioUrl: String?, collectibleImageView: View)

        fun onImageMediaClick(
            imageUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        )

        fun onGifMediaClick(
            previewUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        )

        fun on3dModeClick(imageUrl: String?)
    }
}
