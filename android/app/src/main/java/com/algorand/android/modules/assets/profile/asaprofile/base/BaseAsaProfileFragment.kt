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

package com.algorand.android.modules.assets.profile.asaprofile.base

import android.os.Bundle
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.view.doOnLayout
import androidx.core.view.isVisible
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAsaProfileBinding
import com.algorand.android.models.AccountIconResource.Companion.DEFAULT_ACCOUNT_ICON_RESOURCE
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.addition.AddAssetActionBottomSheet
import com.algorand.android.modules.assets.action.removal.RemoveAssetActionBottomSheet
import com.algorand.android.modules.assets.profile.about.ui.AssetAboutFragment
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaProfilePreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType.ACCOUNT_SELECTION
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType.ADDITION
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusActionType.REMOVAL
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.AsaProfileAccountSelectionFragment.Companion.ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY
import com.algorand.android.modules.collectibles.action.optin.CollectibleOptInActionBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

abstract class BaseAsaProfileFragment : BaseFragment(R.layout.fragment_asa_profile),
    AssetAboutFragment.AssetAboutTabListener {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackButtonClick,
        backgroundColor = R.color.hero_bg
    )

    abstract val asaProfileViewModel: BaseAsaProfileViewModel

    override val fragmentConfiguration = FragmentConfiguration()

    protected val binding by viewBinding(FragmentAsaProfileBinding::bind)

    private val formattedAssetPriceCollector: suspend (String?) -> Unit = {
        binding.assetPriceTextView.text = it
    }

    private val assetShortNameCollector: suspend (AssetName?) -> Unit = {
        val toolbarTitle = it?.getName(binding.root.resources).orEmpty()
        binding.toolbar.changeTitle(toolbarTitle)
    }

    private val asaDetailCollector: suspend (AsaProfilePreview?) -> Unit = { asaProfilePreview ->
        asaProfilePreview?.run {
            setAsaDetail(
                isAlgo = isAlgo,
                assetFullName = assetFullName,
                assetId = assetId,
                verificationTierConfiguration = verificationTierConfiguration,
                baseAssetDrawableProvider = baseAssetDrawableProvider,
                assetPrismUrl = assetPrismUrl
            )
        }
    }

    private val asaStatusPreviewCollector: suspend (value: AsaStatusPreview?) -> Unit = {
        setAsaStatusPreview(it)
    }

    private val sendTransactionObserver = Observer<Event<Resource<AssetOperationResult>>> {
        it.consume()?.use(
            onSuccess = {
                onSendTransactionSuccess(it)
                onBackButtonClick()
            },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.loadingLayout.root.hide() }
        )
    }

    protected val assetShortName: String?
        get() = asaProfileViewModel.asaProfilePreviewFlow.value?.assetShortName?.getName(resources)

    abstract fun navToAccountSelection()
    abstract fun navToAssetAdditionFlow()
    abstract fun onBackButtonClick()
    abstract fun onAccountSelected(selectedAccountAddress: String)

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<String>(ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY) { selectedAccountAddress ->
            onAccountSelected(selectedAccountAddress)
            navToAssetAdditionFlow()
        }
        useFragmentResultListenerValue<Boolean>(
            key = RemoveAssetActionBottomSheet.REMOVE_ASSET_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) navBack() }
        )
        useFragmentResultListenerValue<Boolean>(
            key = CollectibleOptInActionBottomSheet.OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) navBack() }
        )
        useFragmentResultListenerValue<Boolean>(
            key = AddAssetActionBottomSheet.ADD_ASSET_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) navBack() }
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.toolbar.configure(toolbarConfiguration)
    }

    private fun initAboutAssetContainer(isBottomPaddingNeeded: Boolean) {
        childFragmentManager.beginTransaction().add(
            binding.assetAboutFragmentContainerView.id,
            AssetAboutFragment.newInstance(asaProfileViewModel.assetId, isBottomPaddingNeeded)
        ).commit()
    }

    private fun initObservers() {
        with(viewLifecycleOwner.lifecycleScope) {
            with(asaProfileViewModel.asaProfilePreviewFlow) {
                launchWhenResumed {
                    map { it?.formattedAssetPrice }.distinctUntilChanged().collectLatest(formattedAssetPriceCollector)
                }
                launchWhenResumed {
                    map { it?.assetShortName }.distinctUntilChanged().collectLatest(assetShortNameCollector)
                }
                launchWhenResumed {
                    collectLatest(asaDetailCollector)
                }
                launchWhenResumed {
                    map { it?.asaStatusPreview }.distinctUntilChanged().collectLatest(asaStatusPreviewCollector)
                }
            }
        }
        asaProfileViewModel.sendTransactionResultLiveData.observe(viewLifecycleOwner, sendTransactionObserver)
    }

    private fun setAsaDetail(
        isAlgo: Boolean,
        assetFullName: AssetName,
        assetId: Long,
        verificationTierConfiguration: VerificationTierConfiguration,
        baseAssetDrawableProvider: BaseAssetDrawableProvider,
        assetPrismUrl: String?
    ) {
        with(binding) {
            assetNameAndBadgeTextView.apply {
                setTextColor(ContextCompat.getColor(root.context, verificationTierConfiguration.textColorResId))
                verificationTierConfiguration.drawableResId?.run {
                    setDrawable(end = AppCompatResources.getDrawable(context, this))
                }
                text = assetFullName.getName(resources)
            }
            if (!isAlgo) {
                assetIdTextView.apply {
                    text = getString(R.string.interpunct_asset_id, assetId)
                    setOnLongClickListener { context.copyToClipboard(assetId.toString()); true }
                    show()
                }
            }
            assetLogoImageView.apply {
                doOnLayout {
                    baseAssetDrawableProvider.provideAssetDrawable(
                        context = root.context,
                        assetName = assetFullName,
                        logoUri = assetPrismUrl,
                        width = it.measuredWidth,
                        onResourceReady = ::setImageDrawable
                    )
                }
            }
        }
    }

    private fun setAsaStatusPreview(asaStatusPreview: AsaStatusPreview?) {
        with(binding.assetStatusConstraintLayout) {
            with(asaStatusPreview) {
                root.isVisible = this != null
                initAboutAssetContainer(isBottomPaddingNeeded = this != null)
                if (this == null) return
                assetStatusLabelTextView.setText(statusLabelTextResId)
                accountTextView.apply {
                    accountName?.run {
                        text = getDisplayAddress()
                        setDrawable(
                            start = AccountIconDrawable.create(
                                context = context,
                                accountIconResource = accountIconResource ?: DEFAULT_ACCOUNT_ICON_RESOURCE,
                                size = resources.getDimension(R.dimen.account_icon_size_small).toInt()
                            )
                        )
                        setOnLongClickListener {
                            onAccountAddressCopied(publicKey)
                            true
                        }
                        show()
                    }
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
            ADDITION -> navToAssetAdditionFlow()
            ACCOUNT_SELECTION -> navToAccountSelection()
            REMOVAL -> {
                // Currently, asset removal is not supported in BaseProfileFragment. If account is opted in
                // we only show information of the asset. Add removal case if the flow changes
            }
        }
    }

    private fun onSendTransactionSuccess(assetOperationResult: AssetOperationResult) {
        showAlertSuccess(
            title = getString(
                assetOperationResult.resultTitleResId,
                assetOperationResult.assetName.getName(resources)
            )
        )
    }
}
