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

package com.algorand.android.nft.ui.nfsdetail

import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.FragmentNavigatorExtras
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.modules.collectibles.action.optout.CollectibleOptOutConfirmationBottomSheet.Companion.COLLECTIBLE_OPT_OUT_KEY
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.nft.ui.model.CollectibleDetailPreview
import com.algorand.android.nft.ui.nfsdetail.base.BaseCollectibleDetailFragment
import com.algorand.android.ui.send.confirmation.ui.TransactionConfirmationFragment.Companion.TRANSACTION_CONFIRMATION_KEY
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.useFragmentResultListenerValue
import dagger.hilt.android.AndroidEntryPoint
import kotlin.properties.Delegates

@AndroidEntryPoint
class CollectibleDetailFragment : BaseCollectibleDetailFragment() {

    override val baseCollectibleDetailViewModel: CollectibleDetailViewModel by viewModels()

    private var collectibleDetailPreview: CollectibleDetailPreview? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) initCollectibleDetailPreview(newValue)
    }

    private val collectibleDetailPreviewCollector: suspend (value: CollectibleDetailPreview?) -> Unit = {
        collectibleDetailPreview = it
    }

    override fun onResume() {
        super.onResume()
        useFragmentResultListenerValue<Boolean>(COLLECTIBLE_OPT_OUT_KEY) { isOptOutApproved ->
            if (isOptOutApproved) navBack()
        }
        useFragmentResultListenerValue<Boolean>(TRANSACTION_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) navBack()
        }
    }

    override fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            baseCollectibleDetailViewModel.collectibleDetailFlow,
            collectibleDetailPreviewCollector
        )
    }

    private fun initCollectibleDetailPreview(collectibleDetailPreview: CollectibleDetailPreview) {
        with(collectibleDetailPreview) {
            with(collectibleDetail ?: return) {
                setCollectibleMedias(collectibleDetail.collectibleMedias)
                setWarningViewGroup(warningTextRes)
                setOptedInWarningViewGroup(isOwnedByTheUser, optedInWarningTextRes)
                setCollectionTitleView(collectionName)
                setCollectibleNameView(collectibleName)
                setSendAndShareButtonVisibility(this)
                setCollectibleDescription(collectibleDescription)
                setCollectibleOwnerAddress(ownerAccountAddress, isOwnedByTheUser)
                setCollectibleAssetId(collectibleId)
                setCollectibleAssetIdClickListener(collectibleId, ownerAccountAddress.publicKey)
                setCollectibleCreatorNameView(creatorName)
                setCollectibleCreatorWalletAddressView(creatorWalletAddress)
                setCollectibleTraits(collectibleTraits)
                setOptedInAccountGroupVisibilitiesAndViews(isOptOutButtonVisible, collectibleDetail)
                setShowOnPeraExplorerGroup(isPeraExplorerVisible, peraExplorerUrl)
                setTotalOwnedViewGroup(formattedCollectibleAmount, isAmountVisible)
                globalErrorEvent?.consume()?.run { if (this.isNotBlank()) showGlobalError(this) }
                fractionalCollectibleSendEvent?.consume()?.run { navToSendAlgoNavigation(collectibleDetail) }
                pureCollectibleSendEvent?.consume()?.run { navToCollectibleSendFragment(collectibleDetail) }
            }
        }
    }

    private fun setSendAndShareButtonVisibility(collectibleDetail: CollectibleDetail) {
        with(binding) {
            with(collectibleDetail) {
                collectibleSendButton.apply {
                    isVisible = !isHoldingByWatchAccount && isOwnedByTheUser
                    setOnClickListener { baseCollectibleDetailViewModel.checkSendingCollectibleIsFractional() }
                }
                collectibleShareButton.apply {
                    isVisible = isOwnedByTheUser || isHoldingByWatchAccount || isCreatedByTheUser
                    setOnClickListener { onShareButtonClick(collectibleDetail) }
                }
            }
        }
    }

    private fun onShareButtonClick(collectibleDetail: CollectibleDetail) {
        context?.openTextShareBottomMenuChooser(
            title = collectibleDetail.collectibleName.orEmpty(),
            text = collectibleDetail.peraExplorerUrl.orEmpty()
        )
    }

    private fun navToCollectibleSendFragment(collectibleDetail: CollectibleDetail) {
        nav(
            HomeNavigationDirections.actionGlobalSendCollectibleNavigation(
                collectibleDetail
            )
        )
    }

    private fun navToSendAlgoNavigation(collectibleDetail: CollectibleDetail) {
        val assetTransaction = AssetTransaction(
            senderAddress = collectibleDetail.ownerAccountAddress.publicKey,
            assetId = collectibleDetail.collectibleId
        )
        nav(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
    }

    private fun setCollectibleAssetIdClickListener(collectibleAssetId: Long, address: String) {
        binding.assetIdTextView.setOnClickListener {
            nav(
                CollectibleDetailFragmentDirections.actionCollectibleDetailFragmentToAssetProfileNavigation(
                    assetId = collectibleAssetId,
                    accountAddress = address
                )
            )
        }
    }

    override fun navToShowQrBottomSheet() {
        val addressToShow = collectibleDetailPreview?.collectibleDetail?.ownerAccountAddress?.publicKey ?: return
        val title = getString(R.string.qr_code)
        nav(CollectibleDetailFragmentDirections.actionGlobalShowQrNavigation(title, addressToShow))
    }

    override fun navToImagePreviewFragment(
        imageUrl: String,
        errorDisplayText: String,
        view: View,
        mediaType: ItemType,
        previewPrismUrl: String
    ) {
        exitTransition = getImageDetailTransitionAnimation(isGrowing = false)
        reenterTransition = getImageDetailTransitionAnimation(isGrowing = true)
        val transitionName = view.transitionName
        nav(
            directions = CollectibleDetailFragmentDirections
                .actionCollectibleDetailFragmentToCollectibleImagePreviewNavigation(
                    imageUrl = imageUrl,
                    errorDisplayText = errorDisplayText,
                    transitionName = transitionName,
                    mediaType = mediaType,
                    previewPrismUrl = previewPrismUrl
                ),
            extras = FragmentNavigatorExtras(view to transitionName)
        )
    }

    override fun navToVideoPlayerFragment(videoUrl: String) {
        nav(CollectibleDetailFragmentDirections.actionCollectibleDetailFragmentToVideoPlayerNavigation(videoUrl))
    }

    override fun navToOptOutConfirmationBottomSheet(collectibleDetail: CollectibleDetail) {
        nav(
            CollectibleDetailFragmentDirections
                .actionCollectibleDetailFragmentToCollectibleOptOutConfirmationBottomSheet(
                    assetAction = AssetAction(
                        assetId = collectibleDetail.collectibleId,
                        publicKey = collectibleDetail.ownerAccountAddress.publicKey,
                        // TODO: Remove this after deleting AssetInformation
                        asset = AssetInformation.createAssetInformation(collectibleDetail)
                    )
                )
        )
    }

    override fun copyOptedInAccountAddress() {
        onAccountAddressCopied(collectibleDetailPreview?.collectibleDetail?.ownerAccountAddress?.publicKey ?: return)
    }
}
