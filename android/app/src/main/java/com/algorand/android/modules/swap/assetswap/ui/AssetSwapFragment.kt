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

package com.algorand.android.modules.swap.assetswap.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.SwapAssetInputView
import com.algorand.android.databinding.FragmentAssetSwapBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.swap.assetselection.fromasset.ui.SwapFromAssetSelectionFragment.Companion.SWAP_FROM_ASSET_ID_KEY
import com.algorand.android.modules.swap.assetselection.toasset.ui.SwapToAssetSelectionFragment.Companion.SWAP_TO_ASSET_ID_KEY
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview.SelectedAssetAmountDetail
import com.algorand.android.modules.swap.balancepercentage.ui.BalancePercentageBottomSheet.Companion.CHECKED_BALANCE_PERCENTAGE_KEY
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.DecimalDigitsInputFilter
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AssetSwapFragment : BaseFragment(R.layout.fragment_asset_swap) {

    private val binding by viewBinding(FragmentAssetSwapBinding::bind)

    private val assetSwapViewModel by viewModels<AssetSwapViewModel>()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.swap,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val assetIconSize by lazy { resources.getDimensionPixelSize(R.dimen.asset_avatar_image_size) }

    private val fromAssetDetailCollector: suspend (AssetSwapPreview.SelectedAssetDetail?) -> Unit = { assetDetail ->
        if (assetDetail != null) initFromAssetDetail(assetDetail)
    }

    private val toAssetDetailCollector: suspend (AssetSwapPreview.SelectedAssetDetail?) -> Unit = { assetDetail ->
        if (assetDetail != null) initToAssetDetail(assetDetail)
    }

    private val clearToSelectedAssetDetailEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run { binding.toAssetInputView.clearSelectedAssetDetail() }
    }

    private val swapButtonEnableStatusCollector: suspend (Boolean?) -> Unit = { isEnabled ->
        binding.swapButton.isEnabled = isEnabled ?: false
    }

    private val loadingVisibilityCollector: suspend (Boolean?) -> Unit = { isLoadingVisible ->
        binding.progressBar.root.isVisible = isLoadingVisible == true
    }

    private val fromAssetAmountDetailCollector: suspend (SelectedAssetAmountDetail?) -> Unit = { amountDetail ->
        amountDetail?.run {
            updateAssetAmountDetail(
                amount,
                formattedApproximateValue,
                binding.fromAssetInputView
            )
        }
    }

    private val toAssetAmountDetailCollector: suspend (SelectedAssetAmountDetail?) -> Unit = { amountDetail ->
        amountDetail?.run {
            updateAssetAmountDetail(formattedAmount, formattedApproximateValue, binding.toAssetInputView)
        }
    }

    private val onFromAmountChangeListener = SwapAssetInputView.TextChangeListener { charSequence ->
        if (charSequence != null) assetSwapViewModel.onFromAmountChanged(charSequence.toString())
    }

    private val onToAmountChangeListener = SwapAssetInputView.TextChangeListener { charSequence ->
        if (charSequence != null) assetSwapViewModel.onToAmountChanged(charSequence.toString())
    }

    private val swapErrorEventCollector: suspend (Event<ErrorResource>?) -> Unit = { errorEvent ->
        initSwapError(errorEvent)
    }

    private val switchAssetsButtonEnableCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.switchAssetsButton.isVisible = isEnabled
    }

    private val accountIconResourceCollector: suspend (AccountIconResource?) -> Unit = { accountIconResource ->
        setToolbarAccountIcon(accountIconResource)
    }

    private val formattedPercentageTextCollector: suspend (String) -> Unit = { formattedPercentageText ->
        binding.percentageTextView.text = formattedPercentageText
    }

    private val accountDisplayNameCollector: suspend (AccountDisplayName) -> Unit = { accountDisplayName ->
        getAppToolbar()?.run {
            changeSubtitle(accountDisplayName.getAccountPrimaryDisplayName())
            setOnTitleLongClickListener { onAccountAddressCopied(accountDisplayName.getRawAccountAddress()) }
        }
    }

    private val navigateToConfirmSwapFragmentEventCollector: suspend (Event<SwapQuote>?) -> Unit = {
        it?.consume()?.let { swapQuote ->
            nav(AssetSwapFragmentDirections.actionAssetSwapFragmentToConfirmSwapFragment(swapQuote))
        }
    }

    private val maxAndPercentageButtonEnableCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.balancePercentageContainer.isVisible = isEnabled
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    @Suppress("LongMethod")
    private fun initObservers() {
        with(assetSwapViewModel.assetSwapPreviewFlow) {
            with(viewLifecycleOwner) {
                collectLatestOnLifecycle(
                    map { it.isLoadingVisible }.distinctUntilChanged(),
                    loadingVisibilityCollector
                )
                collectLatestOnLifecycle(
                    map { it.fromSelectedAssetAmountDetail }.distinctUntilChanged(),
                    fromAssetAmountDetailCollector
                )
                collectLatestOnLifecycle(
                    map { it.errorEvent }.distinctUntilChanged(),
                    swapErrorEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.isSwapButtonEnabled }.distinctUntilChanged(),
                    swapButtonEnableStatusCollector
                )
                collectLatestOnLifecycle(
                    map { it.toSelectedAssetDetail }.distinctUntilChanged(),
                    toAssetDetailCollector
                )
                collectLatestOnLifecycle(
                    map { it.fromSelectedAssetDetail }.distinctUntilChanged(),
                    fromAssetDetailCollector
                )
                collectLatestOnLifecycle(
                    map { it.toSelectedAssetAmountDetail }.distinctUntilChanged(),
                    toAssetAmountDetailCollector
                )
                collectLatestOnLifecycle(
                    map { it.isSwitchAssetsButtonEnabled }.distinctUntilChanged(),
                    switchAssetsButtonEnableCollector
                )
                collectLatestOnLifecycle(
                    map { it.isMaxAndPercentageButtonEnabled }.distinctUntilChanged(),
                    maxAndPercentageButtonEnableCollector
                )
                collectLatestOnLifecycle(
                    map { it.accountDisplayName }.distinctUntilChanged(),
                    accountDisplayNameCollector
                )
                collectLatestOnLifecycle(
                    map { it.accountIconResource }.distinctUntilChanged(),
                    accountIconResourceCollector
                )
                collectLatestOnLifecycle(
                    map { it.clearToSelectedAssetDetailEvent }.distinctUntilChanged(),
                    clearToSelectedAssetDetailEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.navigateToConfirmSwapFragmentEvent }.distinctUntilChanged(),
                    navigateToConfirmSwapFragmentEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.formattedPercentageText }.distinctUntilChanged(),
                    formattedPercentageTextCollector
                )
            }
        }
    }

    private fun initUi() {
        with(binding) {
            fromAssetInputView.apply {
                setChooseAssetButtonOnClickListener { navToFromAssetSelectionFragment() }
                setOnTextChangedListener(onFromAmountChangeListener)
            }
            toAssetInputView.apply {
                setChooseAssetButtonOnClickListener { navToToAssetSelectionFragment() }
                setOnTextChangedListener(onToAmountChangeListener)
            }
            swapButton.setOnClickListener { assetSwapViewModel.onSwapButtonClick() }
            switchAssetsButton.setOnClickListener { assetSwapViewModel.onSwitchAssetsClick() }
            maxButton.setOnClickListener { assetSwapViewModel.onMaxButtonClick() }
            balancePercentageButton.setOnClickListener { navToBalancePercentageBottomSheet() }
        }
    }

    override fun onResume() {
        super.onResume()
        useFragmentResultListenerValue<Long>(SWAP_FROM_ASSET_ID_KEY) { assetId ->
            assetSwapViewModel.updateFromAssetId(assetId)
        }
        useFragmentResultListenerValue<Long>(SWAP_TO_ASSET_ID_KEY) { assetId ->
            assetSwapViewModel.updateToAssetId(assetId)
        }
        useFragmentResultListenerValue<Float>(CHECKED_BALANCE_PERCENTAGE_KEY) { balancePercentage ->
            assetSwapViewModel.onBalancePercentageSelected(balancePercentage)
        }
    }

    private fun navToFromAssetSelectionFragment() {
        nav(
            AssetSwapFragmentDirections.actionAssetSwapFragmentToSwapFromAssetSelectionFragment(
                accountAddress = assetSwapViewModel.accountAddress
            )
        )
    }

    private fun navToToAssetSelectionFragment() {
        nav(
            AssetSwapFragmentDirections.actionAssetSwapFragmentToSwapToAssetSelectionFragment(
                accountAddress = assetSwapViewModel.accountAddress,
                fromAssetId = assetSwapViewModel.fromAssetId
            )
        )
    }

    private fun navToBalancePercentageBottomSheet() {
        nav(AssetSwapFragmentDirections.actionAssetSwapFragmentToBalancePercentageBottomSheet())
    }

    private fun initFromAssetDetail(assetDetail: AssetSwapPreview.SelectedAssetDetail) {
        initSwapAssetInputViewDetails(assetDetail, binding.fromAssetInputView)
    }

    private fun initToAssetDetail(assetDetail: AssetSwapPreview.SelectedAssetDetail) {
        initSwapAssetInputViewDetails(assetDetail, binding.toAssetInputView)
    }

    private fun initSwapError(errorEvent: Event<ErrorResource>?) {
        binding.errorTextView.apply {
            isVisible = errorEvent != null && !errorEvent.consumed
            errorEvent?.consume()?.let { errorResource ->
                text = errorResource.parseError(context)
            }
        }
    }

    private fun initSwapAssetInputViewDetails(
        assetDetail: AssetSwapPreview.SelectedAssetDetail,
        inputView: SwapAssetInputView
    ) {
        with(inputView) {
            with(assetDetail) {
                assetDrawableProvider.provideAssetDrawable(
                    imageView = getImageView(),
                    onResourceFailed = ::setImageDrawable
                )
                setAssetDetails(
                    formattedBalance = formattedBalance,
                    assetShortName = assetShortName,
                    verificationTierConfiguration = verificationTierConfiguration
                )
                setInputFilter(DecimalDigitsInputFilter(assetDecimal))
            }
        }
    }

    private fun updateAssetAmountDetail(amount: String?, formattedAppxValue: String, inputView: SwapAssetInputView) {
        with(inputView) {
            setAmountWithoutTriggeringTextChangeListener(amount.orEmpty())
            val formattedApproximateValue = getString(R.string.approximate_currency_value, formattedAppxValue)
            setApproximateValueText(formattedApproximateValue)
        }
    }

    private fun setToolbarAccountIcon(accountIconResource: AccountIconResource?) {
        if (accountIconResource == null) return
        context?.run {
            val iconSize = resources.getDimensionPixelSize(R.dimen.account_icon_size_xsmall)
            AccountIconDrawable.create(this, accountIconResource, iconSize)?.let { drawable ->
                getAppToolbar()?.setSubtitleStartDrawable(drawable)
            }
        }
    }
}
