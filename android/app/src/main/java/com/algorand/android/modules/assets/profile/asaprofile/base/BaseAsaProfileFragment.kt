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
import androidx.annotation.StringRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAsaProfileBinding
import com.algorand.android.models.AccountIconResource.Companion.DEFAULT_ACCOUNT_ICON_RESOURCE
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.addition.AddAssetActionBottomSheet
import com.algorand.android.modules.assets.action.removal.RemoveAssetActionBottomSheet
import com.algorand.android.modules.assets.profile.about.ui.AssetAboutFragment
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaProfilePreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.AsaProfileAccountSelectionFragment.Companion.ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY
import com.algorand.android.modules.collectibles.action.optin.CollectibleOptInActionBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigDecimal
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
                hasFormattedPrice = hasFormattedPrice
            )
            setMarketInformation(
                isMarketInformationVisible = isMarketInformationVisible,
                formattedAssetPrice = formattedAssetPrice.orEmpty(),
                isChangePercentageVisible = isChangePercentageVisible,
                changePercentage = changePercentage,
                changePercentageIcon = changePercentageIcon,
                changePercentageTextColor = changePercentageTextColor
            )
        }
    }

    private val asaStatusPreviewCollector: suspend (value: AsaStatusPreview?) -> Unit = {
        setAsaStatusPreview(it)
    }

    protected val assetShortName: String?
        get() = asaProfileViewModel.asaProfilePreviewFlow.value?.assetShortName?.getName(resources)

    abstract fun navToAccountSelection()
    abstract fun navToAssetAdditionFlow()
    abstract fun navToAssetRemovalFlow()
    abstract fun navToAssetTransferFlow()
    abstract fun onBackButtonClick()
    abstract fun onAccountSelected(selectedAccountAddress: String)
    abstract fun navToDiscoverTokenDetailPage()

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
            result = { isConfirmed -> if (isConfirmed) onBackButtonClick() }
        )
        useFragmentResultListenerValue<Boolean>(
            key = CollectibleOptInActionBottomSheet.OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) onBackButtonClick() }
        )
        useFragmentResultListenerValue<Boolean>(
            key = AddAssetActionBottomSheet.ADD_ASSET_ACTION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) onBackButtonClick() }
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

    private fun initAboutAssetContainer() {
        childFragmentManager.beginTransaction().add(
            binding.assetAboutFragmentContainerView.id,
            AssetAboutFragment.newInstance(asaProfileViewModel.assetId, true)
        ).commit()
    }

    private fun initObservers() {
        with(asaProfileViewModel.asaProfilePreviewFlow) {
            collectOnLifecycle(
                flow = this,
                collection = asaDetailCollector
            )
            collectOnLifecycle(
                flow = map { it?.formattedAssetPrice }.distinctUntilChanged(),
                collection = formattedAssetPriceCollector
            )
            collectOnLifecycle(
                flow = map { it?.assetShortName }.distinctUntilChanged(),
                collection = assetShortNameCollector
            )
            collectOnLifecycle(
                flow = map { it?.asaStatusPreview }.distinctUntilChanged(),
                collection = asaStatusPreviewCollector
            )
        }
    }

    private fun setMarketInformation(
        isMarketInformationVisible: Boolean,
        formattedAssetPrice: String,
        isChangePercentageVisible: Boolean,
        changePercentage: BigDecimal?,
        changePercentageIcon: Int?,
        changePercentageTextColor: Int?
    ) {
        with(binding.marketInformationLayout) {
            root.isVisible = isMarketInformationVisible
            root.setOnClickListener { navToDiscoverTokenDetailPage() }
            assetPriceTextView.text = formattedAssetPrice
            assetChangePercentageTextView.apply {
                changePercentageIcon?.let { setDrawable(start = AppCompatResources.getDrawable(context, it)) }
                changePercentageTextColor?.let { setTextColor(ContextCompat.getColor(context, it)) }
                changePercentage?.let { text = getString(R.string.formatted_changed_percentage, it.abs()) }
                isVisible = isChangePercentageVisible
            }
        }
    }

    private fun setAsaDetail(
        isAlgo: Boolean,
        assetFullName: AssetName,
        assetId: Long,
        verificationTierConfiguration: VerificationTierConfiguration,
        baseAssetDrawableProvider: BaseAssetDrawableProvider,
        hasFormattedPrice: Boolean
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
                    text = assetId.toString()
                    setOnLongClickListener { context.copyToClipboard(assetId.toString()); true }
                }
            }
            assetIdTextView.isVisible = !isAlgo
            interpunctTextView.isVisible = !isAlgo

            assetLogoImageView.apply {
                baseAssetDrawableProvider.provideAssetDrawable(
                    imageView = this,
                    onResourceFailed = ::setImageDrawable
                )
            }
            assetPriceTextView.isVisible = hasFormattedPrice
        }
    }

    private fun setAsaStatusPreview(asaStatusPreview: AsaStatusPreview?) {
        initAboutAssetContainer()
        with(asaStatusPreview ?: return) {
            binding.assetStatusConstraintLayout.root.show()
            initAsaStatusLabel(statusLabelTextResId)
            initAsaStatusValue(this)
            initAsaStatusActionButton(this)
        }
    }

    private fun initAsaStatusLabel(@StringRes statusLabelTextResId: Int) {
        binding.assetStatusConstraintLayout.statusLabelTextView.setText(statusLabelTextResId)
    }

    private fun initAsaStatusValue(asaStatusPreview: AsaStatusPreview) {
        binding.assetStatusConstraintLayout.statusValueTextView.apply {
            when (asaStatusPreview) {
                is AsaStatusPreview.AdditionStatus -> {
                    asaStatusPreview.accountName?.run {
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
                    }
                }
                is AsaStatusPreview.RemovalStatus.AssetRemovalStatus -> {
                    text = getString(
                        R.string.pair_value_format,
                        asaStatusPreview.formattedAccountBalance,
                        asaStatusPreview.assetShortName?.getName(resources)
                    )
                }
                is AsaStatusPreview.TransferStatus -> {
                    text = getString(
                        R.string.pair_value_format,
                        asaStatusPreview.formattedAccountBalance,
                        asaStatusPreview.assetShortName?.getName(resources)
                    )
                }
                is AsaStatusPreview.AccountSelectionStatus -> {
                    // no value text for account selection case
                }
                is AsaStatusPreview.RemovalStatus.CollectibleRemovalStatus -> {
                    // no value text for  collectible removal status case
                }
            }
            show()
        }
    }

    private fun initAsaStatusActionButton(
        asaStatusPreview: AsaStatusPreview
    ) {
        with(asaStatusPreview.peraButtonState) {
            with(binding.assetStatusConstraintLayout.assetStatusActionButton) {
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
            is AsaStatusPreview.AccountSelectionStatus -> navToAccountSelection()
            is AsaStatusPreview.AdditionStatus -> navToAssetAdditionFlow()
            is AsaStatusPreview.RemovalStatus -> navToAssetRemovalFlow()
            is AsaStatusPreview.TransferStatus -> navToAssetTransferFlow()
        }
    }
}
