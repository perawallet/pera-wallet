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

package com.algorand.android.modules.collectibles.detail.base.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.view.doOnPreDraw
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import com.algorand.android.BuildConfig
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.CollectibleMediaPager
import com.algorand.android.databinding.FragmentCollectibleDetailBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.collectibles.action.optin.CollectibleOptInActionBottomSheet.Companion.OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY
import com.algorand.android.modules.collectibles.action.optout.CollectibleOptOutConfirmationBottomSheet.Companion.COLLECTIBLE_OPT_OUT_KEY
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.modules.collectibles.detail.base.ui.model.CollectibleTraitItem
import com.algorand.android.ui.send.confirmation.ui.TransactionConfirmationFragment.Companion.TRANSACTION_CONFIRMATION_KEY
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.browser.openAccountAddressInAlgoExplorer
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.transition.platform.MaterialElevationScale
import kotlin.properties.Delegates

@Suppress("TooManyFunctions")
abstract class BaseCollectibleDetailFragment : BaseFragment(R.layout.fragment_collectible_detail) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::onNavBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    abstract val baseCollectibleDetailViewModel: BaseCollectibleDetailViewModel

    private val collectibleMediaItemClickListener = object : CollectibleMediaPager.MediaPagerListener {

        override fun onVideoMediaClick(videoUrl: String?) {
            if (videoUrl.isNullOrBlank()) return
            navToVideoPlayerFragment(videoUrl)
        }

        override fun onAudioMediaClick(audioUrl: String?) {
            if (audioUrl.isNullOrBlank()) return
            navToAudioPlayerFragment(audioUrl)
        }

        override fun onImageMediaClick(
            imageUrl: String?,
            collectibleImageView: View,
            cachedMediaUri: String
        ) {
            if (imageUrl.isNullOrBlank()) return
            navToImagePreviewFragment(imageUrl, collectibleImageView, cachedMediaUri)
        }

        override fun on3dModeClick(imageUrl: String?) {
            if (imageUrl.isNullOrBlank()) return
            navToCardViewerFragment(getImage3DViewUrl(imageUrl))
        }
    }

    protected val binding by viewBinding(FragmentCollectibleDetailBinding::bind)

    private var isNFTDescriptionExpanded by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            if (newValue) expandDescriptionTextView() else collapseDescriptionTextView()
        }
    }

    private val nftDescriptionDefaultLineCount by lazy {
        resources.getInteger(R.integer.nft_description_max_lines_count)
    }

    abstract fun initObservers()

    abstract fun navToVideoPlayerFragment(videoUrl: String)

    abstract fun navToAudioPlayerFragment(audioUrl: String)

    abstract fun copyOptedInAccountAddress()

    abstract fun navToCardViewerFragment(url: String)

    abstract fun onShareButtonClick()

    abstract fun navToImagePreviewFragment(
        imageUrl: String,
        view: View,
        cachedMediaUri: String
    )

    abstract fun onNavBack()

    open fun initUi() {
        binding.nftMediaPager.setListener(collectibleMediaItemClickListener)
        getAppToolbar()?.setEndButton(button = IconButton(R.drawable.ic_share, onClick = ::onShareButtonClick))
    }

    override fun onResume() {
        super.onResume()
        clearTransitions()
        useFragmentResultListenerValue<Boolean>(OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY) { isConfirmed ->
            if (isConfirmed) onNavBack()
        }
        useFragmentResultListenerValue<Boolean>(COLLECTIBLE_OPT_OUT_KEY) { isOptOutApproved ->
            if (isOptOutApproved) onNavBack()
        }
        useFragmentResultListenerValue<Boolean>(TRANSACTION_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) onNavBack()
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        postponeEnterTransition()
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
        view.doOnPreDraw { startPostponedEnterTransition() }
    }

    protected fun setCollectibleMedias(collectibleMedias: List<BaseCollectibleMediaItem>?) {
        binding.nftMediaPager.submitList(collectibleMedias.orEmpty())
    }

    protected fun setCollectionName(collectionName: String?) {
        with(binding.nftCollectionNameTextView) {
            text = collectionName
            isVisible = !collectionName.isNullOrBlank()
        }
    }

    protected fun setNFTName(collectibleName: AssetName) {
        binding.nftNameTextView.apply {
            text = collectibleName.getName(resources)
            isVisible = !text.isNullOrBlank()
        }
    }

    protected fun setShowOnPeraExplorer(peraExplorerUrl: String?) {
        with(binding) {
            showOnPeraExplorerTextView.setOnClickListener { context?.openUrl(peraExplorerUrl.orEmpty()) }
            peraExplorerGroup.isVisible = !peraExplorerUrl.isNullOrBlank()
        }
    }

    protected fun setNFTDescription(collectibleDescription: String?) {
        with(binding) {
            with(collectibleDescriptionTextView) {
                isVisible = !collectibleDescription.isNullOrBlank()
                text = collectibleDescription
                post {
                    maxLines = nftDescriptionDefaultLineCount.takeIf { lineCount > it } ?: Int.MAX_VALUE
                    with(showMoreButton) {
                        isVisible = collectibleDescriptionTextView.lineCount > nftDescriptionDefaultLineCount
                        setOnClickListener { isNFTDescriptionExpanded = !isNFTDescriptionExpanded }
                    }
                }
            }
        }
    }

    private fun expandDescriptionTextView() {
        with(binding) {
            collectibleDescriptionTextView.maxLines = Int.MAX_VALUE
            showMoreButton.setText(R.string.show_less)
        }
    }

    private fun collapseDescriptionTextView() {
        with(binding) {
            collectibleDescriptionTextView.maxLines = nftDescriptionDefaultLineCount
            showMoreButton.setText(R.string.show_more)
        }
    }

    protected fun setNFTOwnerAccount(
        optedInAccountTypeDrawableResId: Int,
        ownerAddress: AccountDisplayName,
        formattedNFTAmount: String
    ) {
        with(binding) {
            with(nftOwnerAccountTextView) {
                text = ownerAddress.getAccountPrimaryDisplayName()
                setOnLongClickListener { onAccountAddressCopied(ownerAddress.getRawAccountAddress()); true }
            }
            nftOwnerAccountIconImageView.setImageResource(optedInAccountTypeDrawableResId)
            accountOwnedNFTCountTextView.text = getString(R.string.asset_amount_with_x, formattedNFTAmount)
            ownerAccountGroup.show()
        }
    }

    protected fun setNFTId(collectibleAssetId: Long) {
        with(binding) {
            assetIdTextView.text = collectibleAssetId.toString()
            assetIdGroup.show()
        }
    }

    protected fun setNFTCreatorAccount(creatorAccountAddressOfNFT: AccountDisplayName) {
        with(binding) {
            creatorAccountGroup.isVisible = creatorAccountAddressOfNFT.getRawAccountAddress().isNotBlank()
            creatorAccountTextView.apply {
                text = creatorAccountAddressOfNFT.getAccountPrimaryDisplayName()
                setOnLongClickListener {
                    onAccountAddressCopied(creatorAccountAddressOfNFT.getRawAccountAddress()); true
                }
                setOnClickListener {
                    val activeNodeSlug = baseCollectibleDetailViewModel.getActiveNodeSlug()
                    context.openAccountAddressInAlgoExplorer(
                        accountAddress = creatorAccountAddressOfNFT.getRawAccountAddress(),
                        networkSlug = activeNodeSlug
                    )
                }
            }
        }
    }

    protected fun setNFTTraits(traits: List<CollectibleTraitItem>?) {
        with(binding) {
            nftTraitGroup.isVisible = !traits.isNullOrEmpty()
            collectibleTraitsLayout.initView(traits.orEmpty())
        }
    }

    protected fun setPrimaryWarningText(warningTextRes: Int?) {
        if (warningTextRes != null) {
            with(binding.primarysecondaryWarningTextView) {
                setText(warningTextRes)
                show()
            }
        }
    }

    protected fun setSecondaryWarningText(warningTextRes: Int?) {
        if (warningTextRes != null) {
            with(binding.secondaryWarningTextView) {
                setText(warningTextRes)
                show()
            }
        }
    }

    protected fun setNFTTotalSupply(formattedAmount: String) {
        with(binding) {
            totalSupplyViewGroup.isVisible = formattedAmount.isNotBlank()
            totalSupplyTextView.text = formattedAmount
        }
    }

    protected fun getImageDetailTransitionAnimation(isGrowing: Boolean): MaterialElevationScale {
        return MaterialElevationScale(isGrowing).apply {
            duration = resources.getInteger(R.integer.shared_fragment_transition_delay_ms).toLong()
        }
    }

    private fun clearTransitions() {
        exitTransition = null
        reenterTransition = null
    }

    protected fun updateBottomPadding(measuredHeight: Int) {
        with(binding.collectibleDetailScrollView) {
            updatePadding(bottom = measuredHeight + resources.getDimensionPixelSize(R.dimen.spacing_large))
            clipToPadding = false
        }
    }

    protected fun setProgressBarVisibility(isVisible: Boolean) {
        binding.progressbar.root.isVisible = isVisible
    }

    private fun getImage3DViewUrl(rawImageUrl: String): String {
        return PrismUrlBuilder.create(BuildConfig.PERA_3D_EXPLORER_BASE_URL)
            .addImageUrl(rawImageUrl)
            .addWidth(IMAGE_3D_CARD_WIDTH)
            .addQuality(IMAGE_3D_QUALITY)
            .build()
    }

    companion object {
        private const val IMAGE_3D_CARD_WIDTH = 1440
        private const val IMAGE_3D_QUALITY = 100
    }
}
