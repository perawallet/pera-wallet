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

package com.algorand.android.modules.collectibles.profile.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.FragmentNavigatorExtras
import com.algorand.android.R
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.assets.action.removal.RemoveAssetActionBottomSheet.Companion.REMOVE_ASSET_ACTION_RESULT_KEY
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.collectibles.action.optin.CollectibleOptInActionBottomSheet.Companion.OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfilePreview
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.nfsdetail.base.BaseCollectibleDetailFragment
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.useFragmentResultListenerValue
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class CollectibleProfileFragment : BaseCollectibleDetailFragment() {

    override val baseCollectibleDetailViewModel: CollectibleProfileViewModel by viewModels()

    private val collectibleProfileCollector: suspend (CollectibleProfilePreview) -> Unit = {
        initCollectibleProfilePreview(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            baseCollectibleDetailViewModel.collectibleProfilePreviewFlow.collectLatest(collectibleProfileCollector)
        }
    }

    override fun onStart() {
        super.onStart()
        startFragmentResultListeners()
    }

    private fun startFragmentResultListeners() {
        useFragmentResultListenerValue<Boolean>(
            key = REMOVE_ASSET_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) navBack() }
        )
        useFragmentResultListenerValue<Boolean>(
            key = OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) navBack() }
        )
    }

    private fun initCollectibleProfilePreview(collectibleProfilePreview: CollectibleProfilePreview) {
        with(collectibleProfilePreview) {
            with(collectibleProfile ?: return) {
                setCollectibleMedias(collectibleMedias)
                setWarningViewGroup(warningTextRes)
                setOptedInWarningViewGroup(isOwnedByTheUser, optedInWarningTextRes)
                setCollectionTitleView(collectionName)
                setCollectibleNameView(collectibleName)
                setCollectibleDescription(collectibleDescription)
                setCollectibleAssetId(collectibleId)
                setCollectibleAssetIdClickListener(collectibleId, accountAddress)
                setCollectibleCreatorNameView(creatorName)
                setCollectibleCreatorWalletAddressView(creatorWalletAddress)
                setCollectibleTraits(collectibleTraits)
                setShowOnPeraExplorerGroup(isPeraExplorerVisible, peraExplorerUrl)
            }
            with(binding.progressbar.root) {
                isVisible = isLoadingVisible
                onTransactionLoadingEvent?.consume()?.run { show() }
                onTransactionSuccess?.consume()?.run { navBack() }
                onTransactionFailed?.consume()?.run {
                    hide()
                    showGlobalError(message)
                }
            }
            setAsaStatusPreview(collectibleStatusPreview)
        }
    }

    private fun setAsaStatusPreview(collectibleStatusPreview: AsaStatusPreview?) {
        with(binding.collectibleStatusConstraintLayout) {
            with(collectibleStatusPreview) {
                root.isVisible = this != null
                if (this == null) return
                updateBottomPadding()
                assetStatusLabelTextView.setText(statusLabelTextResId)
                accountTextView.apply {
                    isVisible = accountName != null
                    text = accountName?.getDisplayAddress()
                    setDrawable(
                        start = AccountIconDrawable.create(
                            context = context,
                            accountIconResource = accountName?.accountIconResource
                                ?: AccountIconResource.DEFAULT_ACCOUNT_ICON_RESOURCE,
                            size = resources.getDimension(R.dimen.account_icon_size_small).toInt()
                        )
                    )
                }

                with(peraButtonState) {
                    with(assetStatusActionButton) {
                        setIconDrawable(iconResourceId = iconDrawableResId)
                        setBackgroundColor(colorResId = backgroundColorResId)
                        setIconTint(iconTintResId = iconTintColorResId)
                        setText(textResId = actionButtonTextResId)
                        setButtonStroke(colorResId = strokeColorResId)
                        setButtonTextColor(colorResId = textColor)
                        setOnClickListener { onAsaActionButtonClick(asaStatusActionType) }
                    }
                }
            }
        }
    }

    private fun onAsaActionButtonClick(asaStatusActionType: AsaStatusActionType) {
        when (asaStatusActionType) {
            AsaStatusActionType.ADDITION -> navToAssetAdditionFlow()
            AsaStatusActionType.REMOVAL -> navToAssetRemovalFlow()
            AsaStatusActionType.ACCOUNT_SELECTION -> {
                // Account should be already selected in this fragment. Nothing to do until a flow change
            }
        }
    }

    private fun navToAssetAdditionFlow() {
        val assetAction = baseCollectibleDetailViewModel.getAssetAction()
        nav(
            CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToCollectibleOptInActionNavigation(
                assetAction = assetAction
            )
        )
    }

    private fun navToAssetRemovalFlow() {
        val assetAction = baseCollectibleDetailViewModel.getAssetAction()
        nav(
            CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToAssetRemovalActionNavigation(
                assetAction = assetAction
            )
        )
    }

    override fun navToVideoPlayerFragment(videoUrl: String) {
        nav(CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToVideoPlayerNavigation(videoUrl))
    }

    override fun copyOptedInAccountAddress() {
        onAccountAddressCopied(baseCollectibleDetailViewModel.accountAddress)
    }

    override fun navToShowQrBottomSheet() {
        nav(
            CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToShowQrNavigation(
                title = getString(R.string.qr_code),
                qrText = baseCollectibleDetailViewModel.accountAddress
            )
        )
    }

    override fun navToImagePreviewFragment(
        imageUrl: String,
        errorDisplayText: String,
        view: View,
        mediaType: BaseCollectibleMediaItem.ItemType,
        previewPrismUrl: String
    ) {
        exitTransition = getImageDetailTransitionAnimation(isGrowing = false)
        reenterTransition = getImageDetailTransitionAnimation(isGrowing = true)
        val transitionName = view.transitionName
        nav(
            directions = CollectibleProfileFragmentDirections
                .actionCollectibleProfileFragmentToCollectibleImagePreviewNavigation(
                    imageUrl = imageUrl,
                    errorDisplayText = errorDisplayText,
                    transitionName = transitionName,
                    mediaType = mediaType,
                    previewPrismUrl = previewPrismUrl
                ),
            extras = FragmentNavigatorExtras(view to transitionName)
        )
    }

    private fun setCollectibleAssetIdClickListener(collectibleAssetId: Long, address: String) {
        binding.assetIdTextView.setOnClickListener {
            nav(
                CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToAssetProfileNavigation(
                    assetId = collectibleAssetId,
                    accountAddress = address
                )
            )
        }
    }
}
