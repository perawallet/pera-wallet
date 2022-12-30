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

package com.algorand.android.modules.collectibles.detail.base.ui.viewpager

import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemNftMediaBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.assetdrawable.CollectibleNameDrawable

abstract class BaseCollectibleMediaViewHolder(
    private val binding: ItemNftMediaBinding,
    private val listener: Listener
) : BaseViewHolder<BaseCollectibleMediaItem>(binding.root) {

    private var nftMediaDrawableListener: NFTMediaDrawableListener? = null

    override fun bind(item: BaseCollectibleMediaItem) {
        loadNFTImage(item.baseAssetDrawableProvider, item.shouldDecreaseOpacity)
        initUi(item)
    }

    protected fun setNFTMediaDrawableListener(nftMediaDrawableListener: NFTMediaDrawableListener) {
        this.nftMediaDrawableListener = nftMediaDrawableListener
    }

    private fun initUi(item: BaseCollectibleMediaItem) {
        with(binding) {
            threeDModeTextView.apply {
                setOnClickListener { listener.on3DModeClick(item.previewUrl) }
                isVisible = item.has3dSupport
            }
            nftMediaImageView.setPlayButtonVisibility(item.showPlayButton)
        }
    }

    private fun loadNFTImage(baseAssetDrawableProvider: BaseAssetDrawableProvider, shouldDecreaseOpacity: Boolean) {
        with(binding.nftMediaImageView) {
            setOpacity(shouldDecreaseOpacity)
            baseAssetDrawableProvider.provideAssetDrawable(
                imageView = getImageView(),
                onPreparePlaceHolder = { context, measuredWidth ->
                    CollectibleNameDrawable(
                        collectibleName = baseAssetDrawableProvider.assetName.getName(resources),
                        width = measuredWidth
                    ).toDrawable(context)
                },
                onResourceFailed = { it?.let(::showImage) },
                onUriReady = { nftMediaDrawableListener?.onMediaUriReady(baseAssetDrawableProvider, it) }
            )
        }
    }

    interface Listener {
        fun on3DModeClick(imageUrl: String?)
        fun onImageMediaClick(
            mediaUri: String?,
            cachedMediaUri: String,
            collectibleImageView: View
        )

        fun onVideoMediaClick(imageUrl: String?)
        fun onAudioMediaClick(imageUrl: String?)
    }

    fun interface NFTMediaDrawableListener {
        fun onMediaUriReady(baseAssetDrawableProvider: BaseAssetDrawableProvider, uri: String)
    }
}
