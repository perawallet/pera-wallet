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

package com.algorand.android.nft.ui.nftimagepreview

import android.animation.ArgbEvaluator
import android.animation.ValueAnimator
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.annotation.ColorRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentCollectibleImagePreviewBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.loadGif
import com.algorand.android.utils.loadImageWithCachedFirst
import com.algorand.android.utils.recordException
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.transition.platform.MaterialContainerTransform
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class CollectibleImagePreviewFragment : BaseFragment(R.layout.fragment_collectible_image_preview) {

    private val binding by viewBinding(FragmentCollectibleImagePreviewBinding::bind)
    private val args: CollectibleImagePreviewFragmentArgs by navArgs()
    private var colorAnimator: ValueAnimator? = null
    private var animationDuration: Long = 0L

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::handleNavBack,
        startIconResId = R.drawable.ic_close_rounded,
        backgroundColor = R.color.black
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            handleNavBack()
        }
    }

    private fun handleNavBack() {
        animateBackgroundColor(R.color.black, R.color.background)
        setImageDimensionRatio(INITIAL_DIMEN_RATIO)
        navBack()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        animationDuration = container?.resources
            ?.getInteger(R.integer.shared_fragment_transition_delay_ms)?.toLong() ?: 0
        sharedElementEnterTransition = MaterialContainerTransform().apply { duration = animationDuration }
        sharedElementReturnTransition = MaterialContainerTransform().apply { duration = animationDuration }
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.collectibleImageView.transitionName = args.transitionName
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        loadCollectiblePreview()
        animateBackgroundColor(R.color.background, R.color.black)
        setImageDimensionRatioWithDelay()
    }

    private fun setImageDimensionRatioWithDelay() {
        viewLifecycleOwner.lifecycleScope.launch {
            delay(getDimenRatioDelayDuration())
            setImageDimensionRatio(null)
        }
    }

    private fun setImageDimensionRatio(ratio: String?) {
        binding.collectibleImageView.apply {
            layoutParams = (layoutParams as? ConstraintLayout.LayoutParams)?.apply {
                dimensionRatio = ratio
            }
        }
    }

    // We need this duration to avoid image flickering
    private fun getDimenRatioDelayDuration(): Long {
        return animationDuration + SET_DIMEN_RATIO_DURATION_OFFSET
    }

    private fun loadCollectiblePreview() {
        val prismUrl = createPrismPreviewImageUrl(args.imageUrl)
        val isImageTypeGif = args.mediaType.name == BaseCollectibleMediaItem.ItemType.GIF.name
        if (isImageTypeGif) loadGif(prismUrl) else loadCollectibleImage(prismUrl)
    }

    private fun loadCollectibleImage(prismUrl: String) {
        with(binding.collectibleImageView) {
            context.loadImageWithCachedFirst(
                uri = prismUrl,
                cachedUri = args.previewPrismUrl,
                onCachedResourceReady = { showImage(it) },
                onResourceReady = { showImage(it) },
                onCachedLoadFailed = { showText(args.errorDisplayText) }
            )
        }
    }

    private fun loadGif(prismUrl: String) {
        with(binding.collectibleImageView) {
            getImageView()?.loadGif(
                uri = prismUrl,
                onResourceReady = { gifDrawable ->
                    showImage(gifDrawable)
                    gifDrawable.start()
                },
                onLoadFailed = { showText(args.errorDisplayText) }
            )
        }
    }

    private fun createPrismPreviewImageUrl(rawUrl: String?): String {
        return PrismUrlBuilder.create(rawUrl.orEmpty())
            .addWidth(PrismUrlBuilder.DEFAULT_IMAGE_SIZE)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    private fun animateBackgroundColor(@ColorRes fromColorRes: Int, @ColorRes toColorRes: Int) {
        context?.run {
            colorAnimator?.cancel()
            val fromColor = ContextCompat.getColor(this, fromColorRes)
            val toColor = ContextCompat.getColor(this, toColorRes)
            colorAnimator = ValueAnimator.ofObject(ArgbEvaluator(), fromColor, toColor).apply {
                duration = animationDuration
                addUpdateListener { animator ->
                    try {
                        binding.root.setBackgroundColor(animator.animatedValue as Int)
                    } catch (exception: Exception) {
                        recordException(exception)
                    }
                }
            }.also { it.start() }
        }
    }

    companion object {
        private const val SET_DIMEN_RATIO_DURATION_OFFSET = 250L
        private const val INITIAL_DIMEN_RATIO = "1:1"
    }
}
