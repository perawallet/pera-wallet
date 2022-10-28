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

package com.algorand.android.nft.ui.nfsdetail.base

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
import com.algorand.android.customviews.AccountCopyQrView
import com.algorand.android.customviews.CollectibleMediaPager
import com.algorand.android.databinding.FragmentCollectibleDetailBinding
import com.algorand.android.models.BaseAccountAddress.AccountAddress
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.nft.ui.model.CollectibleTraitItem
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.browser.openAccountAddressInAlgoExplorer
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.transition.platform.MaterialElevationScale

@Suppress("TooManyFunctions")
abstract class BaseCollectibleDetailFragment : BaseFragment(R.layout.fragment_collectible_detail) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    abstract val baseCollectibleDetailViewModel: BaseCollectibleDetailViewModel

    private val accountQrViewListener = object : AccountCopyQrView.Listener {
        override fun onCopyClick() {
            copyOptedInAccountAddress()
        }

        override fun onQrClick() {
            navToShowQrBottomSheet()
        }
    }

    private val collectibleMediaItemClickListener = object : CollectibleMediaPager.MediaPagerListener {
        override fun onVideoMediaClick(videoUrl: String?, collectibleImageView: View) {
            if (videoUrl.isNullOrBlank()) return
            navToVideoPlayerFragment(videoUrl)
        }

        override fun onImageMediaClick(
            imageUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: ItemType,
            previewPrismUrl: String
        ) {
            if (imageUrl.isNullOrBlank()) return
            navToImagePreviewFragment(imageUrl, errorDisplayText, collectibleImageView, mediaType, previewPrismUrl)
        }

        override fun onGifMediaClick(
            previewUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: ItemType,
            previewPrismUrl: String
        ) {
            if (previewUrl.isNullOrBlank()) return
            navToImagePreviewFragment(previewUrl, errorDisplayText, collectibleImageView, mediaType, previewPrismUrl)
        }

        override fun on3dModeClick(imageUrl: String?) {
            if (imageUrl.isNullOrBlank()) return
            context?.openUrl(getImage3DViewUrl(imageUrl))
        }
    }

    protected val binding by viewBinding(FragmentCollectibleDetailBinding::bind)

    abstract fun initObservers()

    abstract fun navToShowQrBottomSheet()

    abstract fun navToVideoPlayerFragment(videoUrl: String)

    abstract fun copyOptedInAccountAddress()

    abstract fun navToImagePreviewFragment(
        imageUrl: String,
        errorDisplayText: String,
        view: View,
        mediaType: ItemType,
        previewPrismUrl: String
    )

    open fun initUi() {
        binding.collectibleMediaPager.setListener(collectibleMediaItemClickListener)
    }

    open fun navToOptOutConfirmationBottomSheet(collectibleDetail: CollectibleDetail) {}

    override fun onResume() {
        super.onResume()
        clearTransitions()
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
        binding.collectibleMediaPager.submitList(collectibleMedias.orEmpty())
    }

    protected fun setCollectionTitleView(collectionName: String?) {
        with(binding) {
            collectionTitleNameTextView.text = collectionName
            collectionNameTextView.text = collectionName
            collectionNameGroup.isVisible = !collectionName.isNullOrBlank()
        }
    }

    protected fun setCollectibleNameView(collectibleName: String?) {
        binding.collectibleTitleNameTextView.apply {
            text = collectibleName
            isVisible = !collectibleName.isNullOrBlank()
        }
    }

    protected fun setShowOnPeraExplorerGroup(isPeraExplorerVisible: Boolean, peraExplorerUrl: String?) {
        with(binding) {
            showOnPeraExplorerGroup.isVisible = isPeraExplorerVisible
            showOnPeraExplorerTextView.setOnClickListener {
                context?.openUrl(peraExplorerUrl.orEmpty())
            }
        }
    }

    protected fun setCollectibleDescription(collectibleDescription: String?) {
        with(binding) {
            descriptionGroup.isVisible = !collectibleDescription.isNullOrBlank()
            collectibleDescriptionTextView.text = collectibleDescription
        }
    }

    protected fun setCollectibleOwnerAddress(ownerAddress: AccountAddress, isOwned: Boolean) {
        with(binding) {
            collectibleOwnerAccountUserView.apply {
                ownerAddress.run {
                    if (accountIconResource != null) {
                        setAccount(getDisplayAddress(), accountIconResource, publicKey)
                    } else {
                        setAddress(
                            displayAddress = ownerAddress.getDisplayAddress(),
                            publicKey = ownerAddress.publicKey
                        )
                    }
                }
            }
            collectibleOwnerGroup.isVisible = isOwned
        }
    }

    protected fun setCollectibleAssetId(collectibleAssetId: Long) {
        binding.assetIdTextView.text = collectibleAssetId.toString()
    }

    protected fun setCollectibleCreatorNameView(collectibleCreatorName: String?) {
        with(binding) {
            creatorNameTextView.text = collectibleCreatorName
            creatorNameGroup.isVisible = !collectibleCreatorName.isNullOrBlank()
        }
    }

    protected fun setCollectibleCreatorWalletAddressView(collectibleCreatorWalletAddress: AccountAddress?) {
        with(binding) {
            creatorWalletNameGroup.isVisible = !collectibleCreatorWalletAddress?.publicKey.isNullOrBlank()
            if (collectibleCreatorWalletAddress == null) return
            creatorWalletAddressTextView.apply {
                text = collectibleCreatorWalletAddress.getDisplayAddress()
                setOnLongClickListener { onAccountAddressCopied(collectibleCreatorWalletAddress.publicKey); true }
                setOnClickListener {
                    val activeNodeSlug = baseCollectibleDetailViewModel.getActiveNodeSlug()
                    context.openAccountAddressInAlgoExplorer(collectibleCreatorWalletAddress.publicKey, activeNodeSlug)
                }
            }
        }
    }

    protected fun setOptedInAccountGroupVisibilitiesAndViews(
        isOptOutButtonVisible: Boolean,
        collectibleDetail: CollectibleDetail
    ) {
        with(binding) {
            with(collectibleDetail) {
                optOutButton.apply {
                    isVisible = isOptOutButtonVisible
                    setOnClickListener { navToOptOutConfirmationBottomSheet(collectibleDetail) }
                }
                optedInViewsGroup.isVisible = !isOwnedByTheUser && !isCreatedByTheUser
                optedInAccountQrView.apply {
                    setAccountIcon(ownerAccountAddress.accountIconResource)
                    setAccountName(ownerAccountAddress.getDisplayAddress())
                    setListener(accountQrViewListener)
                }
            }
        }
    }

    protected fun setCollectibleTraits(traits: List<CollectibleTraitItem>?) {
        with(binding) {
            collectibleTraitsGroup.isVisible = !traits.isNullOrEmpty()
            collectibleTraitsLayout.initView(traits.orEmpty())
        }
    }

    protected fun setWarningViewGroup(warningTextRes: Int?) {
        with(binding) {
            if (warningTextRes != null) {
                warningTextView.setText(warningTextRes)
                warningGroup.show()
            }
        }
    }

    protected fun setOptedInWarningViewGroup(isOwnedByTheUser: Boolean, optedInWarningTextRes: Int?) {
        binding.optedInWarningGroup.isVisible = !isOwnedByTheUser
        if (optedInWarningTextRes != null) {
            binding.optedInWarningTextView.setText(optedInWarningTextRes)
        }
    }

    protected fun setTotalOwnedViewGroup(formattedAmount: String, isAmountVisible: Boolean) {
        with(binding) {
            totalOwnedGroup.isVisible = isAmountVisible
            totalOwnedTextView.text = formattedAmount
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

    protected fun updateBottomPadding() {
        with(binding.collectibleDetailScrollView) {
            updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.asa_action_layout_height))
            clipToPadding = false
        }
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
