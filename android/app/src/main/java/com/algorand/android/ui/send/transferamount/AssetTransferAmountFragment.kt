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
 *
 */

package com.algorand.android.ui.send.transferamount

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.SendAlgoNavigationDirections
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.algorandamountinput.AlgorandAmountInputTextView
import com.algorand.android.databinding.FragmentAssetTransferAmountBinding
import com.algorand.android.models.AmountInput
import com.algorand.android.models.AssetTransferAmountPreview
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.warningconfirmation.BaseMaximumBalanceWarningBottomSheet
import com.algorand.android.ui.send.shared.AddNoteBottomSheet
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import kotlin.properties.Delegates

// TODO: 17.08.2021 We will update this fragment when input format finalized,
// TODO: 29.09.2021 `handleError` function will be updated when this branch merge with `send-asset-amount-input`
// TODO: 27.01.2022 We have to get initial Ui State model from UseCase then we won't need to create initial placeholder
//  etc.

// TODO: We should refactor the flow that is explained below :/
/**
 * Current entering amount flow;
 * -> Enter digit and Trigger [DialPadView]
 * -> Trigger [AlgorandAmountInputTextView]
 * -> Trigger [AmountFormatter]
 * -> Format Amount
 * -> Invoke all chained listeners and update UI
 *
 * We should keep whole this flow into UseCase or we should make those operations cleaner
 */
@SuppressWarnings("TooManyFunctions")
@AndroidEntryPoint
class AssetTransferAmountFragment : TransactionBaseFragment(R.layout.fragment_asset_transfer_amount) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAssetTransferAmountBinding::bind)

    private val assetTransferAmountViewModel: AssetTransferAmountViewModel by viewModels()

    private val keyboardListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.amountTextView.onNumberEntered(number)
        }

        override fun onBackspaceClick() {
            binding.amountTextView.onBackspaceEntered()
        }

        override fun onDecimalSeparatorClicked() {
            binding.amountTextView.onDecimalSeparatorClicked()
        }
    }

    private val assetTransferAmountPreview: suspend (AssetTransferAmountPreview?) -> Unit = {
        it?.let { updateUIWithPreview(it) }
    }

    private var latestAmountInput by Delegates.observable(AmountInput.getDefaultAmountInput()) { _, _, newValue ->
        onAmountChanged(newValue)
    }

    private val onBalanceChangeListener = AlgorandAmountInputTextView.Listener {
        latestAmountInput = it
    }

    private var transactionNote: String? by Delegates.observable(null) { _, _, newValue ->
        binding.addNoteButton.text = if (newValue.isNullOrEmpty()) {
            getString(R.string.add_note_with_plus)
        } else {
            getString(R.string.edit_note)
        }
    }

    private var lockedNote: String? by Delegates.observable(null) { _, _, newValue ->
        if (newValue.isNullOrEmpty()) {
            binding.addNoteButton.text = getString(R.string.show_note)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initToolbar()
        showTransactionTipsIfNeed()
        handleTransactionNote()
        initObservers()
        with(binding) {
            dialpadView.setDialPadListener(keyboardListener)
            amountTextView.setOnBalanceChangeListener(onBalanceChangeListener)
            nextButton.setOnClickListener { onNextButtonClick() }
            maxButton.setOnClickListener { onMaxButtonClick() }
            addNoteButton.setOnClickListener { onAddButtonClick() }
        }
    }

    private fun initToolbar() {
        getAppToolbar()?.setEndButton(
            button = IconButton(iconResId = R.drawable.ic_info, onClick = ::navToTransactionTips)
        )
    }

    private fun updateUIWithPreview(assetTransferAmountPreview: AssetTransferAmountPreview) {
        with(assetTransferAmountPreview) {
            updateToolbarWithPreview(this)
            assetPreview?.let {
                binding.algorandApproximateValueTextView.isVisible = it.isAmountInSelectedCurrencyVisible
                updateEnteredAmountCurrencyValue(
                    formattedCurrencyValue = enteredAmountSelectedCurrencyValue,
                    isAmountInSelectedCurrencyVisible = it.isAmountInSelectedCurrencyVisible
                )
                setAmountView(it.decimals)
                setAssetNameView(
                    fullName = it.fullName,
                    assetId = it.assetId,
                    isAlgo = it.isAlgo,
                    assetDrawableProvider = it.assetDrawableProvider,
                    verificationTierConfiguration = it.verificationTierConfiguration,
                    formattedAmount = it.formattedAmount,
                    formattedDisplayedCurrencyValue = it.formattedSelectedCurrencyValue,
                    isAmountInSelectedCurrencyVisible = it.isAmountInSelectedCurrencyVisible
                )
            }
            decimalSeparator?.let { binding.dialpadView.setSeparator(decimalSeparator) }
            onPopulateAmountWithMaxEvent?.consume()?.run { onMaxButtonClick() }
            amountIsValidEvent?.consume()?.let { onAmountIsValid(it) }
            amountIsMoreThanBalanceEvent?.consume()?.let { onAmountMoreThanBalance() }
            insufficientBalanceToPayFeeEvent?.consume()?.let { onInsufficientBalanceToPayFee() }
            minimumBalanceIsViolatedResultEvent?.consume()?.let { onMinimumBalanceViolated(it) }
            assetNotFoundErrorEvent?.consume()?.let { onAssetNotFound() }
        }
    }

    private fun updateToolbarWithPreview(preview: AssetTransferAmountPreview) {
        getAppToolbar()?.apply {
            preview.accountName?.let { changeSubtitle(it) }
            preview.accountIconDrawablePreview?.let { safeAccountIconDrawablePreview ->
                AccountIconDrawable.create(
                    context = context,
                    accountIconDrawablePreview = safeAccountIconDrawablePreview,
                    sizeResId = R.dimen.spacing_normal
                ).let { setSubtitleStartDrawable(it) }
            }
            preview.assetPreview?.let {
                changeTitle(getString(R.string.send_format, it.shortName.getName()))
            }
        }
    }

    private fun onAmountIsValid(amount: BigInteger) {
        handleNextNavigation(amount)
    }

    private fun onAmountMoreThanBalance() {
        showGlobalError(getString(R.string.transaction_amount_cannot))
    }

    private fun onInsufficientBalanceToPayFee() {
        nav(
            AssetTransferAmountFragmentDirections
                .actionAssetTransferAmountFragmentToBalanceWarningBottomSheet(
                    assetTransferAmountViewModel.assetTransaction.senderAddress
                )
        )
    }

    private fun onMinimumBalanceViolated(senderAddress: String) {
        nav(
            AssetTransferAmountFragmentDirections
                .actionAssetTransferAmountFragmentToTransactionMaximumBalanceWarningBottomSheet(senderAddress)
        )
    }

    private fun setAssetNameView(
        fullName: AssetName,
        assetId: Long,
        isAlgo: Boolean,
        assetDrawableProvider: BaseAssetDrawableProvider,
        verificationTierConfiguration: VerificationTierConfiguration,
        formattedAmount: String,
        formattedDisplayedCurrencyValue: String,
        isAmountInSelectedCurrencyVisible: Boolean
    ) {
        with(binding.assetItemView) {
            getStartIconImageView().apply {
                assetDrawableProvider.provideAssetDrawable(
                    imageView = this,
                    onResourceReady = { getStartIconImageView().alpha = 1f },
                    onResourceFailed = ::setStartIconDrawable
                )
            }
            setTitleText(fullName.getName(resources))
            val descriptionText = if (isAlgo) {
                ALGO_SHORT_NAME
            } else {
                getString(R.string.asset_id_formatted, assetId.toString())
            }
            setDescriptionText(descriptionText)
            setTitleTextColor(verificationTierConfiguration.textColorResId)
            setTrailingIconOfTitleText(verificationTierConfiguration.drawableResId)
            setPrimaryValueText(formattedAmount)
            if (isAmountInSelectedCurrencyVisible) {
                setSecondaryValueText(formattedDisplayedCurrencyValue)
            }
        }
    }

    private fun setAmountView(decimal: Int) {
        binding.amountTextView.setFractionDecimalLimit(decimal)
    }

    private fun onAmountChanged(amountInput: AmountInput) {
        assetTransferAmountViewModel.updateAssetTransferAmountPreviewAccordingToAmount(amountInput.amount)
        binding.nextButton.isEnabled = amountInput.isAmountValid
    }

    private fun updateEnteredAmountCurrencyValue(
        formattedCurrencyValue: String?,
        isAmountInSelectedCurrencyVisible: Boolean
    ) {
        binding.algorandApproximateValueTextView.apply {
            isVisible = isAmountInSelectedCurrencyVisible
            text = formattedCurrencyValue.orEmpty()
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            assetTransferAmountViewModel.assetTransferAmountPreviewFlow,
            assetTransferAmountPreview
        )
    }

    private fun onNextButtonClick() {
        assetTransferAmountViewModel.onAmountSelected(latestAmountInput.amount)
    }

    private fun onMaxButtonClick() {
        val formattedMaximumAmount = assetTransferAmountViewModel.getMaximumAmountOfAsset()
        binding.amountTextView.setAmount(formattedMaximumAmount)
    }

    private fun onAddButtonClick() {
        val note = lockedNote ?: transactionNote
        nav(
            AssetTransferAmountFragmentDirections
                .actionAssetTransferAmountFragmentToAddNoteBottomSheet(note, lockedNote == null)
        )
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.assetTransferAmountFragment) {
            useSavedStateValue<Boolean>(BaseMaximumBalanceWarningBottomSheet.MAX_BALANCE_WARNING_RESULT) {
                if (it) {
                    showProgress()
                    sendWithCalculatedSendableAmount()
                }
            }
            useSavedStateValue<String>(AddNoteBottomSheet.ADD_NOTE_RESULT_KEY) {
                if (lockedNote != null) lockedNote = it else transactionNote = it
                assetTransferAmountViewModel.updateTransactionNotes(lockedNote, transactionNote)
            }
        }
    }

    private fun sendWithCalculatedSendableAmount() {
        assetTransferAmountViewModel.getCalculatedSendableAmount()?.let { handleNextNavigation(it) }
    }

    private fun showTransactionTipsIfNeed() {
        if (assetTransferAmountViewModel.shouldShowTransactionTips()) {
            navToTransactionTips()
        }
    }

    private fun navToTransactionTips() {
        nav(AssetTransferAmountFragmentDirections.actionAssetTransferAmountFragmentToTransactionTipsBottomSheet())
    }

    private fun handleNextNavigation(amount: BigInteger) {
        val assetTransaction = assetTransferAmountViewModel.assetTransaction
        if (assetTransaction.receiverUser != null) {
            val transactionData = assetTransferAmountViewModel.createSendTransactionData(amount) ?: return
            nav(
                AssetTransferAmountFragmentDirections
                    .actionAssetTransferAmountFragmentToAssetTransferPreviewFragment(transactionData)
            )
        } else {
            nav(
                AssetTransferAmountFragmentDirections
                    .actionAssetTransferAmountFragmentToReceiverAccountSelectionFragment(
                        assetTransaction = assetTransaction.copy(
                            amount = amount,
                            note = transactionNote,
                            xnote = lockedNote
                        )
                    )
            )
        }
    }

    private fun handleTransactionNote() {
        with(assetTransferAmountViewModel.assetTransaction) {
            when {
                xnote != null -> lockedNote = xnote
                else -> transactionNote = note
            }
        }
    }

    private fun showProgress() {
        binding.blockerProgressBar.root.show()
    }

    private fun hideProgress() {
        binding.blockerProgressBar.root.hide()
    }

    private fun onAssetNotFound() {
        nav(SendAlgoNavigationDirections.actionSendAlgoNavigationPop())
    }
}
