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

import android.view.View
import androidx.annotation.StringRes
import androidx.core.view.doOnLayout
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.FragmentNavigatorExtras
import com.algorand.android.R
import com.algorand.android.databinding.LayoutAsaStatusBinding
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.collectibles.detail.base.ui.BaseCollectibleDetailFragment
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfilePreview
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CollectibleProfileFragment : BaseCollectibleDetailFragment() {

    private val asaStatusViewStubBinding by viewBinding { LayoutAsaStatusBinding.bind(inflateNFTStatusLayout()) }

    override val baseCollectibleDetailViewModel: CollectibleProfileViewModel by viewModels()

    private val collectibleProfileCollector: suspend (CollectibleProfilePreview?) -> Unit = {
        if (it != null) initCollectibleProfilePreview(it)
    }

    override fun initObservers() {
        collectLatestOnLifecycle(
            flow = baseCollectibleDetailViewModel.collectibleProfilePreviewFlow,
            collection = collectibleProfileCollector
        )
    }

    private fun initCollectibleProfilePreview(collectibleProfilePreview: CollectibleProfilePreview) {
        with(collectibleProfilePreview) {
            setCollectibleMedias(mediaListOfNFT)
            setPrimaryWarningText(primaryWarningResId)
            setSecondaryWarningText(secondaryWarningResId)
            setCollectionName(collectionNameOfNFT)
            setNFTName(nftName)
            setNFTDescription(nftDescription)
            setNFTId(nftId)
            setCollectibleAssetIdClickListener(nftId, accountAddress)
            setNFTCreatorAccount(creatorAccountAddressOfNFT)
            setNFTTraits(traitListOfNFT)
            setShowOnPeraExplorer(peraExplorerUrl)
            setProgressBarVisibility(isLoadingVisible)
            setAsaStatusPreview(collectibleStatusPreview)
        }
    }

    private fun setAsaStatusPreview(collectibleStatusPreview: AsaStatusPreview?) {
        with(collectibleStatusPreview ?: return) {
            asaStatusViewStubBinding.root.doOnLayout { updateBottomPadding(it.measuredHeight) }
            initAsaStatusValue(this)
            initAsaStatusLabel(statusLabelTextResId)
            initAsaStatusActionButton(this)
        }
    }

    private fun initAsaStatusLabel(@StringRes statusLabelTextResId: Int) {
        asaStatusViewStubBinding.statusLabelTextView.setText(statusLabelTextResId)
    }

    private fun initAsaStatusValue(asaStatusPreview: AsaStatusPreview) {
        asaStatusViewStubBinding.statusValueTextView.apply {
            when (asaStatusPreview) {
                is AsaStatusPreview.AdditionStatus -> {
                    show()
                    text = asaStatusPreview.accountName.getDisplayAddress()
                    setDrawable(
                        start = AccountIconDrawable.create(
                            context = context,
                            accountIconDrawablePreview = asaStatusPreview.accountName.accountIconDrawablePreview,
                            sizeResId = R.dimen.spacing_large
                        )
                    )
                    setOnLongClickListener {
                        onAccountAddressCopied(asaStatusPreview.accountName.publicKey)
                        true
                    }
                }
                is AsaStatusPreview.RemovalStatus.CollectibleRemovalStatus -> {
                    show()
                    text = asaStatusPreview.accountName.getDisplayAddress()
                    setDrawable(
                        start = AccountIconDrawable.create(
                            context = context,
                            accountIconDrawablePreview = asaStatusPreview.accountName.accountIconDrawablePreview,
                            sizeResId = R.dimen.spacing_large
                        )
                    )
                    setOnLongClickListener {
                        onAccountAddressCopied(asaStatusPreview.accountName.publicKey)
                        true
                    }
                }
                is AsaStatusPreview.AccountSelectionStatus -> {
                    // Account should be already selected in this fragment. Nothing to do until a flow change
                }
                is AsaStatusPreview.TransferStatus -> {
                    // No transfer action for collectible profile screen
                }
                is AsaStatusPreview.RemovalStatus.AssetRemovalStatus -> {
                    // No action for asset removal status case
                }
            }
        }
    }

    private fun initAsaStatusActionButton(asaStatusPreview: AsaStatusPreview) {
        with(asaStatusPreview.peraButtonState) {
            with(asaStatusViewStubBinding.assetStatusActionButton) {
                setIconDrawable(iconResourceId = iconDrawableResId)
                setBackgroundColor(colorResId = backgroundColorResId)
                setIconTint(iconTintResId = iconTintColorResId)
                setText(textResId = asaStatusPreview.actionButtonTextResId)
                setButtonStroke(colorResId = strokeColorResId)
                setButtonTextColor(colorResId = textColor)
                setOnClickListener { onAsaActionButtonClick(asaStatusPreview) }
            }
        }
    }

    private fun onAsaActionButtonClick(asaStatusPreview: AsaStatusPreview) {
        when (asaStatusPreview) {
            is AsaStatusPreview.AdditionStatus -> navToAssetAdditionFlow()
            is AsaStatusPreview.RemovalStatus -> navToAssetRemovalFlow()
            is AsaStatusPreview.AccountSelectionStatus -> {
                // Account should be already selected in this fragment. Nothing to do until a flow change
            }
            is AsaStatusPreview.TransferStatus -> {
                // No transfer action for collectible profile screen
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
            CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToNftOptOutConfirmationNavigation(
                assetAction = assetAction
            )
        )
    }

    override fun navToVideoPlayerFragment(videoUrl: String) {
        nav(CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToVideoPlayerNavigation(videoUrl))
    }

    override fun navToAudioPlayerFragment(audioUrl: String) {
        nav(CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToAudioPlayerNavigation(audioUrl))
    }

    override fun copyOptedInAccountAddress() {
        onAccountAddressCopied(baseCollectibleDetailViewModel.accountAddress)
    }

    override fun navToCardViewerFragment(url: String) {
        nav(CollectibleProfileFragmentDirections.actionCollectibleProfileFragmentToNftCardViewerNavigation(url))
    }

    override fun onShareButtonClick() {
        context?.openTextShareBottomMenuChooser(
            title = baseCollectibleDetailViewModel.getNFTName()?.getName(resources).orEmpty(),
            text = baseCollectibleDetailViewModel.getNFTExplorerUrl().orEmpty()
        )
    }

    override fun navToImagePreviewFragment(imageUrl: String, view: View, cachedMediaUri: String) {
        exitTransition = getImageDetailTransitionAnimation(isGrowing = false)
        reenterTransition = getImageDetailTransitionAnimation(isGrowing = true)
        val transitionName = view.transitionName
        nav(
            directions = CollectibleProfileFragmentDirections
                .actionCollectibleProfileFragmentToCollectibleImagePreviewNavigation(
                    transitionName = transitionName,
                    imageUri = imageUrl,
                    cachedMediaUri = cachedMediaUri
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

    override fun onNavBack() {
        navBack()
    }

    private fun inflateNFTStatusLayout(): View {
        return with(binding.collectibleStatusConstraintLayout) {
            layoutResource = R.layout.layout_asa_status
            inflate()
        }
    }
}
