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

package com.algorand.android.modules.swap.confirmswap.ui

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.customviews.SwapAssetInputView
import com.algorand.android.databinding.FragmentConfirmSwapBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPreview
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPriceImpactWarningStatus
import com.algorand.android.modules.swap.confirmswapconfirmation.SwapConfirmationBottomSheet.Companion.CONFIRMATION_SUCCESS_KEY
import com.algorand.android.modules.swap.ledger.signwithledger.ui.model.LedgerDialogPayload
import com.algorand.android.modules.swap.slippagetolerance.ui.SlippageToleranceBottomSheet.Companion.CHECKED_SLIPPAGE_TOLERANCE_KEY
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class ConfirmSwapFragment : BaseFragment(R.layout.fragment_confirm_swap) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        titleResId = R.string.confirm_swap
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentConfirmSwapBinding::bind)

    private val confirmSwapViewModel by viewModels<ConfirmSwapViewModel>()

    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    private val confirmSwapPreviewCollector: suspend (ConfirmSwapPreview) -> Unit = { preview ->
        initConfirmSwapPreview(preview)
    }

    private val isLoadingVisibleCollector: suspend (Boolean) -> Unit = { isLoading ->
        binding.progressBar.root.isVisible = isLoading
    }

    private val slippageToleranceCollector: suspend (String) -> Unit = { slippageTolerance ->
        binding.slippageToleranceTextView.text = slippageTolerance
    }

    private val minimumReceivedAmountCollector: suspend (AnnotatedString) -> Unit = { minimumReceivedAmount ->
        binding.minimumReceivedTextView.text = context?.getXmlStyledString(minimumReceivedAmount)
    }

    private val errorEventCollector: suspend (Event<ErrorResource>?) -> Unit = { errorEvent ->
        errorEvent?.consume()?.run {
            showGlobalError(parseError(context ?: return@run), parseTitle(context ?: return@run))
        }
    }

    private val updateSlippageToleranceSuccessEventCollector: suspend (Event<Unit>?) -> Unit = { updateSuccessEvent ->
        updateSuccessEvent?.consume()?.run { showAlertSuccess(getString(R.string.slippage_tolerance_value_updated)) }
    }

    private val navigateToTransactionStatusFragmentEventCollector: suspend (
        Event<List<SwapQuoteTransaction>>?
    ) -> Unit = {
        it?.consume()?.run {
            nav(
                ConfirmSwapFragmentDirections.actionConfirmSwapFragmentToSwapTransactionStatusFragment(
                    confirmSwapViewModel.swapQuote,
                    this.toTypedArray()
                )
            )
        }
    }

    private val navigateToLedgerWaitingForApprovalDialogEventCollector: suspend (
        Event<LedgerDialogPayload>?
    ) -> Unit = {
        it?.consume()?.let { payload -> showLedgerWaitingForApprovalBottomSheet(payload) }
    }

    private val navigateToLedgerNotFoundDialogEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run { nav(HomeNavigationDirections.actionGlobalLedgerConnectionIssueBottomSheet()) }
    }

    private val navigateToSwapConfirmationBottomSheetEventCollector: suspend (Event<Long>?) -> Unit = {
        it?.consume()?.let { priceImpact ->
            nav(ConfirmSwapFragmentDirections.actionConfirmSwapFragmentToSwapConfirmationBottomSheet(priceImpact))
        }
    }

    private val dismissLedgerWaitingForApprovalDialogEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run {
            ledgerLoadingDialog?.dismissAllowingStateLoss()
            ledgerLoadingDialog = null
        }
    }

    private val ledgerLoadingDialogListener = LedgerLoadingDialog.Listener { shouldStopResources ->
        ledgerLoadingDialog = null
        confirmSwapViewModel.onLedgerDialogCancelled()
    }

    private fun showLedgerWaitingForApprovalBottomSheet(
        ledgerDialogPayload: LedgerDialogPayload
    ) {
        if (ledgerLoadingDialog == null) {
            ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog(
                ledgerName = ledgerDialogPayload.ledgerName,
                listener = ledgerLoadingDialogListener,
                currentTransactionIndex = ledgerDialogPayload.currentTransactionIndex,
                totalTransactionCount = ledgerDialogPayload.totalTransactionCount,
                isTransactionIndicatorVisible = ledgerDialogPayload.isTransactionIndicatorVisible
            )
            ledgerLoadingDialog?.showWithStateCheck(childFragmentManager, ledgerDialogPayload.ledgerName.orEmpty())
        } else {
            ledgerLoadingDialog?.updateTransactionIndicator(ledgerDialogPayload.currentTransactionIndex)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        confirmSwapViewModel.setupSwapTransactionSignManager(viewLifecycleOwner.lifecycle)
    }

    private fun initUi() {
        with(binding) {
            confirmSwapButton.setOnClickListener { confirmSwapViewModel.onConfirmSwapClick() }
            priceRatioTextView.setOnClickListener { onSwitchPriceRatioClick() }
            slippageToleranceLabelTextView.setOnClickListener { navToSlippageToleranceInfoBottomSheet() }
            slippageToleranceTextView.setOnClickListener { onUpdateSlippageToleranceClick() }
            priceImpactLabelTextView.setOnClickListener { navToPriceImpactInfoBottomSheet() }
            exchangeFeeLabelTextView.setOnClickListener { navToExchangeFeeInfoBottomSheet() }
        }
    }

    override fun onResume() {
        super.onResume()
        useFragmentResultListenerValue<Float>(CHECKED_SLIPPAGE_TOLERANCE_KEY) { slippageTolerance ->
            confirmSwapViewModel.onSlippageToleranceUpdated(slippageTolerance)
        }
        useFragmentResultListenerValue<Boolean>(CONFIRMATION_SUCCESS_KEY) { isConfirmed ->
            confirmSwapViewModel.onSwapPriceImpactConfirmationResult(isConfirmed)
        }
    }

    private fun navToPriceImpactInfoBottomSheet() {
        nav(ConfirmSwapFragmentDirections.actionConfirmSwapFragmentToPriceImpactInfoBottomSheet())
    }

    private fun navToExchangeFeeInfoBottomSheet() {
        nav(ConfirmSwapFragmentDirections.actionConfirmSwapFragmentToExchangeFeeInfoBottomSheet())
    }

    private fun navToSlippageToleranceInfoBottomSheet() {
        nav(ConfirmSwapFragmentDirections.actionConfirmSwapFragmentToSlippageToleranceInfoBottomSheet())
    }

    private fun initObservers() {
        with(confirmSwapViewModel.confirmSwapPreviewFlow) {
            with(viewLifecycleOwner) {
                collectLatestOnLifecycle(
                    confirmSwapViewModel.confirmSwapPreviewFlow,
                    confirmSwapPreviewCollector
                )
                collectLatestOnLifecycle(
                    map { it.minimumReceived }.distinctUntilChanged(),
                    minimumReceivedAmountCollector
                )
                collectLatestOnLifecycle(
                    map { it.isLoading }.distinctUntilChanged(),
                    isLoadingVisibleCollector
                )
                collectLatestOnLifecycle(
                    map { it.slippageTolerance }.distinctUntilChanged(),
                    slippageToleranceCollector
                )
                collectLatestOnLifecycle(
                    map { it.errorEvent }.distinctUntilChanged(),
                    errorEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.slippageToleranceUpdateSuccessEvent }.distinctUntilChanged(),
                    updateSlippageToleranceSuccessEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.navigateToLedgerNotFoundDialogEvent }.distinctUntilChanged(),
                    navigateToLedgerNotFoundDialogEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.navigateToLedgerWaitingForApprovalDialogEvent }.distinctUntilChanged(),
                    navigateToLedgerWaitingForApprovalDialogEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.navigateToTransactionStatusFragmentEvent }.distinctUntilChanged(),
                    navigateToTransactionStatusFragmentEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.dismissLedgerWaitingForApprovalDialogEvent }.distinctUntilChanged(),
                    dismissLedgerWaitingForApprovalDialogEventCollector
                )
                collectLatestOnLifecycle(
                    map { it.navToSwapConfirmationBottomSheetEvent }.distinctUntilChanged(),
                    navigateToSwapConfirmationBottomSheetEventCollector
                )
            }
        }
    }

    private fun initConfirmSwapPreview(preview: ConfirmSwapPreview) {
        with(binding) {
            with(preview) {
                initAssetDetail(fromAssetInputView, fromAssetDetail)
                initAssetDetail(toAssetInputView, toAssetDetail)
                priceImpactTextView.text = formattedPriceImpact
                peraFeeTextView.text = formattedPeraFee
                exchangeFeeTextView.text = formattedExchangeFee
                priceRatioTextView.text = context?.getXmlStyledString(getPriceRatio(resources))
                initPriceImpactWarningStatus(priceImpactWarningStatus)
                initToolbarAccountDetail(accountDisplayName, accountIconResource)
            }
        }
    }

    private fun initPriceImpactWarningStatus(priceImpactWarningStatus: ConfirmSwapPriceImpactWarningStatus) {
        with(binding) {
            with(priceImpactWarningStatus) {
                priceImpactErrorGroup.isVisible = isPriceImpactErrorVisible
                priceImpactTextView.setTextColor(ContextCompat.getColor(root.context, priceImpactTextColorResId))
                confirmSwapButton.isEnabled = isConfirmButtonEnabled
                priceImpactLabelTextView.setTextColor(
                    ContextCompat.getColor(root.context, priceImpactLabelTextColorResId)
                )
                val errorTextAnnotatedString = getErrorText(root.context)
                priceImpactErrorTextView.apply {
                    movementMethod = priceImpactWarningStatus.movementMethod
                    if (errorTextAnnotatedString != null) {
                        text = context?.getXmlStyledString(errorTextAnnotatedString)
                    }
                }
            }
        }
    }

    private fun initToolbarAccountDetail(
        accountDisplayName: AccountDisplayName,
        accountIconResource: AccountIconResource
    ) {
        getAppToolbar()?.run {
            val iconSize = resources.getDimensionPixelSize(R.dimen.account_icon_size_xsmall)
            AccountIconDrawable.create(context, accountIconResource, iconSize)?.run {
                setSubtitleStartDrawable(this)
            }
            changeSubtitle(accountDisplayName.getAccountPrimaryDisplayName())
            setOnTitleLongClickListener { onAccountAddressCopied(accountDisplayName.getRawAccountAddress()) }
        }
    }

    private fun onSwitchPriceRatioClick() {
        val priceRatioAnnotatedString = confirmSwapViewModel.getSwitchedPriceRatio(resources)
        binding.priceRatioTextView.text = context?.getXmlStyledString(priceRatioAnnotatedString)
    }

    private fun onUpdateSlippageToleranceClick() {
        nav(
            ConfirmSwapFragmentDirections
                .actionConfirmSwapFragmentToSlippageToleranceBottomSheet(confirmSwapViewModel.getSlippageTolerance())
        )
    }

    private fun initAssetDetail(assetInputView: SwapAssetInputView, assetDetail: ConfirmSwapPreview.SwapAssetDetail) {
        with(assetDetail) {
            assetInputView.apply {
                assetDrawableProvider.provideAssetDrawable(
                    imageView = getImageView(),
                    onResourceFailed = ::setImageDrawable
                )
                setAssetDetails(
                    amount = formattedAmount,
                    assetShortName = shortName,
                    verificationTierConfiguration = verificationTierConfig,
                    approximateValue = getString(R.string.approximate_currency_value, formattedApproximateValue)
                )
                setAmountTextColors(
                    primaryValueTextColorResId = assetDetail.amountTextColorResId,
                    secondaryValueTextColorResId = assetDetail.approximateValueTextColorResId
                )
            }
        }
    }
}
