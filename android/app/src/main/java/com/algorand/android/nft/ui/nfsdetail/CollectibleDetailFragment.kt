/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.nft.ui.nfsdetail

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.setFragmentResultListener
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.BuildConfig
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.AccountCopyQrView
import com.algorand.android.customviews.CollectibleMediaPager
import com.algorand.android.databinding.FragmentCollectibleDetailBinding
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountAddress.AccountAddress
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.nft.ui.model.CollectibleDetailPreview
import com.algorand.android.nft.ui.model.CollectibleTraitItem
import com.algorand.android.nft.ui.nfsdetail.CollectibleOptOutConfirmationBottomSheet.Companion.COLLECTIBLE_OPT_OUT_KEY
import com.algorand.android.ui.send.confirmation.TransactionConfirmationFragment.Companion.TRANSACTION_CONFIRMATION_KEY
import com.algorand.android.ui.send.confirmation.TransactionConfirmationFragment.Companion.TRANSACTION_CONFIRMED_KEY
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.PrismUrlBuilder.Companion.DEFAULT_IMAGE_QUALITY
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.openAccountAddressInAlgoExplorer
import com.algorand.android.utils.openAssetInAlgoExplorer
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class CollectibleDetailFragment : TransactionBaseFragment(R.layout.fragment_collectible_detail) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentCollectibleDetailBinding::bind)

    private val collectibleDetailViewModel: CollectibleDetailViewModel by viewModels()

    private val accountQrViewListener = object : AccountCopyQrView.Listener {
        override fun onCopyClick() {
            copyOptedInAccountAddress()
        }

        override fun onQrClick() {
            navToShowQrBottomSheet()
        }
    }

    private val collectibleMediaItemClickListener = object : CollectibleMediaPager.MediaPagerListener {
        override fun onVideoMediaClick(videoUrl: String?) {
            if (videoUrl.isNullOrBlank()) return
            navToVideoPlayerFragment(videoUrl)
        }

        override fun onImageMediaClick(imageUrl: String?) {
            if (imageUrl.isNullOrBlank()) return
            context?.openUrl(getImage3DViewUrl(imageUrl))
        }
    }

    private var collectibleDetailPreview: CollectibleDetailPreview? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) initCollectibleDetailPreview(newValue)
    }

    private val collectibleDetailPreviewCollector: suspend (value: CollectibleDetailPreview?) -> Unit = {
        collectibleDetailPreview = it
    }

    override val transactionFragmentListener: TransactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            collectibleDetailViewModel.sendSignedTransaction(signedTransactionDetail)
        }

        override fun onSignTransactionLoading() {
            binding.progressbar.loadingProgressBar.show()
        }

        override fun onSignTransactionLoadingFinished() {
            binding.progressbar.loadingProgressBar.hide()
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.collectibleDetailFragment) {
            useSavedStateValue<Boolean>(COLLECTIBLE_OPT_OUT_KEY) { isOptOutApproved ->
                if (isOptOutApproved) optOutFromCollectible()
            }
        }
        setFragmentResultListener(TRANSACTION_CONFIRMATION_KEY) { _, bundle ->
            if (bundle.getBoolean(TRANSACTION_CONFIRMED_KEY)) navBack()
        }
    }

    private fun optOutFromCollectible() {
        val transactionData = collectibleDetailViewModel.createRemoveAssetTransactionData() ?: return
        sendTransaction(transactionData)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    private fun initUi() {
        binding.collectibleMediaPager.setListener(collectibleMediaItemClickListener)
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            collectibleDetailViewModel.collectibleDetailFlow.collectLatest(collectibleDetailPreviewCollector)
        }
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
                setCollectibleCreatorNameView(creatorName)
                setCollectibleCreatorWalletAddressView(creatorWalletAddress)
                setCollectibleTraits(collectibleTraits)
                setOptedInAccountGroupVisibilitiesAndViews(collectibleDetail)
                setShowOnPeraExplorerGroup(collectibleDetail)
                optOutSuccessEvent?.consume()?.run { onOptOutSuccess(collectibleDetailPreview.collectibleDetail) }
                globalErrorEvent?.consume()?.run { if (this.isNotBlank()) showGlobalError(this) }
                fractionalCollectibleSendEvent?.consume()?.run { navToSendAlgoNavigation(collectibleDetail) }
                pureCollectibleSendEvent?.consume()?.run { navToCollectibleSendFragment(collectibleDetail) }
            }
        }
    }

    private fun onOptOutSuccess(collectible: CollectibleDetail?) {
        val collectibleIdentifier = (collectible?.collectibleName ?: collectible?.collectibleId.toString())
        val alertMessage = getString(R.string.nft_successfully_opted_out, collectibleIdentifier)
        showForegroundNotification(NotificationMetadata(alertMessage = alertMessage))
        navBack()
    }

    private fun copyOptedInAccountAddress() {
        val addressToCopy = collectibleDetailPreview?.collectibleDetail?.ownerAccountAddress?.publicKey ?: return
        context?.copyToClipboard(addressToCopy)
    }

    private fun navToShowQrBottomSheet() {
        val addressToShow = collectibleDetailPreview?.collectibleDetail?.ownerAccountAddress?.publicKey ?: return
        val title = getString(R.string.qr_code)
        nav(CollectibleDetailFragmentDirections.actionGlobalShowQrBottomSheet(title, addressToShow))
    }

    private fun setCollectibleMedias(collectibleMedias: List<BaseCollectibleMediaItem>?) {
        binding.collectibleMediaPager.submitList(collectibleMedias.orEmpty())
    }

    private fun navToVideoPlayerFragment(videoUrl: String) {
        nav(CollectibleDetailFragmentDirections.actionCollectibleDetailFragmentToVideoPlayerFragment(videoUrl))
    }

    private fun setCollectionTitleView(collectionName: String?) {
        with(binding) {
            collectionTitleNameTextView.text = collectionName
            collectionNameTextView.text = collectionName
            collectionNameGroup.isVisible = !collectionName.isNullOrBlank()
        }
    }

    private fun setCollectibleNameView(collectibleName: String?) {
        binding.collectibleTitleNameTextView.apply {
            text = collectibleName
            isVisible = !collectibleName.isNullOrBlank()
        }
    }

    private fun setShowOnPeraExplorerGroup(collectibleDetail: CollectibleDetail) {
        with(binding) {
            showOnPeraExplorerGroup.isVisible = collectibleDetail.isPeraExplorerVisible
            showOnPeraExplorerTextView.setOnClickListener {
                context?.openUrl(collectibleDetail.peraExplorerUrl.orEmpty())
            }
        }
    }

    private fun setCollectibleDescription(collectibleDescription: String?) {
        binding.collectibleDescriptionTextView.apply {
            text = collectibleDescription
            isVisible = !collectibleDescription.isNullOrBlank()
        }
    }

    private fun setCollectibleOwnerAddress(ownerAddress: AccountAddress?, isOwned: Boolean) {
        with(binding) {
            collectibleOwnerAccountUserView.apply {
                ownerAddress?.run {
                    if (accountIcon != null) {
                        setAccount(getDisplayAddress(), accountIcon)
                    } else {
                        setAddress(ownerAddress.getDisplayAddress())
                    }
                }
            }
            collectibleOwnerGroup.isVisible = ownerAddress != null && isOwned
        }
    }

    private fun setCollectibleAssetId(collectibleAssetId: Long) {
        binding.assetIdTextView.text = collectibleAssetId.toString()
    }

    private fun setCollectibleCreatorNameView(collectibleCreatorName: String?) {
        with(binding) {
            creatorNameTextView.text = collectibleCreatorName
            creatorNameGroup.isVisible = !collectibleCreatorName.isNullOrBlank()
        }
    }

    private fun setCollectibleCreatorWalletAddressView(collectibleCreatorWalletAddress: AccountAddress?) {
        with(binding) {
            creatorWalletNameGroup.isVisible = !collectibleCreatorWalletAddress?.publicKey.isNullOrBlank()
            if (collectibleCreatorWalletAddress == null) return
            creatorWalletAddressTextView.apply {
                text = collectibleCreatorWalletAddress.getDisplayAddress()
                setOnLongClickListener { context?.copyToClipboard(collectibleCreatorWalletAddress.publicKey); true }
                setOnClickListener {
                    val activeNodeSlug = collectibleDetailViewModel.getActiveNodeSlug()
                    context.openAccountAddressInAlgoExplorer(collectibleCreatorWalletAddress.publicKey, activeNodeSlug)
                }
            }
        }
    }

    private fun setSendAndShareButtonVisibility(collectibleDetail: CollectibleDetail) {
        with(binding) {
            with(collectibleDetail) {
                collectibleSendButton.apply {
                    isVisible = !isHoldingByWatchAccount && isOwnedByTheUser
                    setOnClickListener { collectibleDetailViewModel.checkSendingCollectibleIsFractional() }
                }
                collectibleShareButton.apply {
                    isVisible = isOwnedByTheUser || isHoldingByWatchAccount
                    setOnClickListener { onShareButtonClick(collectibleDetail) }
                }
            }
        }
    }

    private fun setOptedInAccountGroupVisibilitiesAndViews(collectibleDetail: CollectibleDetail) {
        with(binding) {
            with(collectibleDetail) {
                optOutButton.apply {
                    isVisible = !isOwnedByTheUser && !isHoldingByWatchAccount
                    setOnClickListener { navToOptOutConfirmationBottomSheet(collectibleDetail) }
                }
                optedInViewsGroup.isVisible = !isOwnedByTheUser
                optedInAccountQrView.apply {
                    setAccountIcon(ownerAccountAddress.accountIcon)
                    setAccountName(ownerAccountAddress.getDisplayAddress())
                    setListener(accountQrViewListener)
                }
            }
        }
    }

    private fun navToOptOutConfirmationBottomSheet(collectibleDetail: CollectibleDetail) {
        nav(
            CollectibleDetailFragmentDirections
                .actionCollectibleDetailFragmentToCollectibleOptOutConfirmationBottomSheet(
                    accountName = collectibleDetail.ownerAccountAddress.publicKey,
                    collectibleAssetId = collectibleDetail.collectibleId,
                    collectibleName = collectibleDetail.collectibleName
                )
        )
    }

    private fun onShareButtonClick(collectibleDetail: CollectibleDetail) {
        context?.openTextShareBottomMenuChooser(
            title = collectibleDetail.collectibleName.orEmpty(),
            text = collectibleDetail.peraExplorerUrl.orEmpty()
        )
    }

    private fun navToCollectibleSendFragment(collectibleDetail: CollectibleDetail) {
        nav(
            CollectibleDetailFragmentDirections.actionCollectibleDetailFragmentToCollectibleSendFragment(
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

    private fun setCollectibleTraits(traits: List<CollectibleTraitItem>?) {
        with(binding) {
            collectibleTraitsGroup.isVisible = !traits.isNullOrEmpty()
            collectibleTraitsLayout.initView(traits.orEmpty())
        }
    }

    private fun setWarningViewGroup(warningTextRes: Int?) {
        with(binding) {
            if (warningTextRes != null) {
                warningTextView.setText(warningTextRes)
                warningGroup.show()
            }
        }
    }

    private fun setOptedInWarningViewGroup(isOwnedByTheUser: Boolean, optedInWarningTextRes: Int?) {
        binding.optedInWarningGroup.isVisible = !isOwnedByTheUser
        if (optedInWarningTextRes != null) {
            binding.optedInWarningTextView.setText(optedInWarningTextRes)
        }
    }

    private fun getImage3DViewUrl(rawImageUrl: String): String {
        return PrismUrlBuilder.create(BuildConfig.PERA_3D_EXPLORER_BASE_URL)
            .addImageUrl(rawImageUrl)
            .addWidth(IMAGE_3D_CARD_WIDTH)
            .addQuality(DEFAULT_IMAGE_QUALITY)
            .build()
    }

    // TODO: We can remove explorer from the code in time.
    private fun setViewTransactionGroup(nftAssetId: Long, isNftExplorerVisible: Boolean, nftExplorerUrl: String?) {
        with(binding) {
            val activeNodeSlug = collectibleDetailViewModel.getActiveNodeSlug()
            showOnAlgoExplorerTextView.setOnClickListener {
                context?.openAssetInAlgoExplorer(nftAssetId, activeNodeSlug)
            }
            showOnNftExplorerTextView.apply {
                setOnClickListener { context?.openUrl(nftExplorerUrl.orEmpty()) }
                isVisible = isNftExplorerVisible
            }
            showOnAlgoExplorerDivider.isVisible = isNftExplorerVisible
        }
    }

    companion object {
        private const val IMAGE_3D_CARD_WIDTH = 1440
    }
}
