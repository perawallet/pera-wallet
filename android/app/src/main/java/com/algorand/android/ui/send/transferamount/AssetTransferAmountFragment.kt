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
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.algorandamountinput.AlgorandAmountInputTextView
import com.algorand.android.databinding.FragmentAssetTransferAmountBinding
import com.algorand.android.models.AssetTransferAmountPreview
import com.algorand.android.models.BalanceInput
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TargetUser
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.common.warningconfirmation.BaseMaximumBalanceWarningBottomSheet
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.Event
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.loadImage
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.math.BigInteger
import kotlin.properties.Delegates

// TODO: 17.08.2021 We will update this fragment when input format finalized,
// TODO: 29.09.2021 `handleError` function will be updated when this branch merge with `send-asset-amount-input`
// TODO: 27.01.2022 We have to get initial Ui State model from UseCase then we won't need to create initial placeholder
//  etc.
@AndroidEntryPoint
class AssetTransferAmountFragment : TransactionBaseFragment(R.layout.fragment_asset_transfer_amount) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAssetTransferAmountBinding::bind)

    private val assetTransferAmountViewModel: AssetTransferAmountViewModel by viewModels()

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoading() {
            showProgress()
        }

        override fun onSignTransactionLoadingFinished() {
            hideProgress()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            when (signedTransactionDetail) {
                is SignedTransactionDetail.Send -> {
                    nav(
                        AssetTransferAmountFragmentDirections
                            .actionAssetTransferAmountFragmentToAssetTransferPreviewFragment(signedTransactionDetail)
                    )
                }
            }
        }
    }

    private val keyboardListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.amountTextView.onNumberEntered(number)
        }

        override fun onBackspaceClick() {
            binding.amountTextView.onBackspaceEntered()
        }

        override fun onDotClick() {
            binding.amountTextView.onDotEntered()
        }
    }

    private val amountCollector: suspend (Event<Resource<BigInteger>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = ::handleNextNavigation,
            onFailed = { handleError(it, binding.root) },
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    private val assetTransferAmountPreview: suspend (AssetTransferAmountPreview?) -> Unit = {
        it?.let { initUi(it) }
    }

    private var latestAmountInput by Delegates.observable(BalanceInput.createDefaultBalanceInput()) { _, _, newValue ->
        onAmountChanged(newValue)
    }

    private var onBalanceChangeListener = AlgorandAmountInputTextView.Listener {
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
            nextButton.setOnClickListener { onNextButtonClick() }
            maxButton.setOnClickListener { onMaxButtonClick() }
            addNoteButton.setOnClickListener { onAddButtonClick() }
        }
    }

    private fun initToolbar() {
        val transactionTipButton = IconButton(iconResId = R.drawable.ic_info, onClick = ::navToTransactionTips)
        getAppToolbar()?.addButtonToEnd(transactionTipButton)
    }

    private fun initUi(assetTransferAmountPreview: AssetTransferAmountPreview) {
        with(assetTransferAmountPreview) {
            getAppToolbar()?.changeTitle(getString(R.string.send_format, shortName.getName()))
            binding.algorandApproximateValueTextView.isVisible = isAmountInSelectedCurrencyVisible
            updateEnteredAmountCurrencyValue(enteredAmountSelectedCurrencyValue, isAmountInSelectedCurrencyVisible)
            setAmountView(decimals)
            setAmountCurrencyValueView(formattedSelectedCurrencyValue, isAmountInSelectedCurrencyVisible)
            setAssetBalanceView(isAlgo, formattedAmount)
            setAssetNameView(
                isVerified,
                fullName.getName(binding.root.resources),
                assetId,
                isAlgo,
                collectiblePrismUrl,
                isCollectibleOwnedByUser
            )
        }
    }

    private fun setAssetNameView(
        isVerified: Boolean,
        fullName: String?,
        assetId: Long,
        isAlgo: Boolean,
        collectiblePrismUrl: String?,
        isOwnedByUser: Boolean
    ) {
        with(binding.assetNameTextView) {
            if (collectiblePrismUrl != null) {
                context?.loadImage(
                    uri = createPrismUrlForCollectibleDrawable(collectiblePrismUrl),
                    onResourceReady = {
                        setupUiWithDrawable(isVerified, fullName, assetId, it, isOwnedByUser)
                    },
                    onLoadFailed = {
                        setupUIWithId(isVerified, fullName, assetId, isAlgo)
                    }
                )
            } else {
                setupUIWithId(isVerified, fullName, assetId, isAlgo)
            }
        }
    }

    private fun createPrismUrlForCollectibleDrawable(collectiblePrismUrl: String): String {
        val collectibleImageViewWidth = resources.getDimension(R.dimen.asset_avatar_image_size).toInt()
        return PrismUrlBuilder.create(collectiblePrismUrl)
            .addWidth(collectibleImageViewWidth)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    private fun setAssetBalanceView(isAlgo: Boolean, formattedAmount: String) {
        binding.assetBalanceTextView.text = if (isAlgo) {
            getString(R.string.pair_value_format, formattedAmount, ALGOS_SHORT_NAME)
        } else {
            formattedAmount
        }
    }

    private fun setAmountCurrencyValueView(
        formattedDisplayedCurrencyValue: String,
        isAmountInSelectedCurrencyVisible: Boolean
    ) {
        binding.assetCurrencyTextView.apply {
            text = formattedDisplayedCurrencyValue
            isVisible = isAmountInSelectedCurrencyVisible
        }
    }

    private fun setAmountView(decimal: Int) {
        with(binding) {
            amountTextView.apply {
                setOnBalanceChangeListener(onBalanceChangeListener)
                dialpadView.setDialPadListener(keyboardListener)
                decimalLimit = decimal
            }
        }
    }

    private fun onAmountChanged(balanceInput: BalanceInput) {
        assetTransferAmountViewModel.updateAssetTransferAmountPreviewAccordingToAmount(
            balanceInput.formattedBalanceInBigDecimal
        )
        binding.nextButton.isEnabled = balanceInput.isAmountValid
    }

    private fun updateEnteredAmountCurrencyValue(
        formattedCurrencyValue: String?,
        isAmountInSelectedCurrencyVisible: Boolean
    ) {
        binding.algorandApproximateValueTextView.apply {
            isVisible = isAmountInSelectedCurrencyVisible
            text = getString(R.string.approximate_currency_value, formattedCurrencyValue)
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetTransferAmountViewModel.amountValidationFlow.collectLatest(amountCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            assetTransferAmountViewModel.assetTransferAmountPreviewFlow.collectLatest(
                assetTransferAmountPreview
            )
        }
    }

    private fun onNextButtonClick() {
        assetTransferAmountViewModel.onAmountSelected(latestAmountInput.formattedBalanceInBigDecimal)
    }

    private fun onMaxButtonClick() {
        val formattedMaximumAmount = assetTransferAmountViewModel.getMaximumAmountOfAsset().orEmpty()
        binding.amountTextView.updateBalance(formattedMaximumAmount)
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
                    assetTransferAmountViewModel.calculateAmount(latestAmountInput.formattedBalanceInBigDecimal)
                }
            }
            useSavedStateValue<String>(AddNoteBottomSheet.ADD_NOTE_RESULT_KEY) {
                if (lockedNote != null) lockedNote = it else transactionNote = it
            }
        }
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
            val targetUser = TargetUser(
                contact = assetTransaction.receiverUser,
                publicKey = assetTransaction.receiverUser.publicKey
            )
            startSendingTransaction(targetUser, amount)
            return
        }

        nav(
            AssetTransferAmountFragmentDirections.actionAssetTransferAmountFragmentToReceiverAccountSelectionFragment(
                assetTransaction = assetTransaction.copy(
                    amount = amount,
                    note = transactionNote,
                    xnote = lockedNote
                )
            )
        )
    }

    // TODO: 2.02.2022 We have to move this logic in domain layer
    private fun startSendingTransaction(targetUser: TargetUser, amount: BigInteger) {
        val note = lockedNote ?: transactionNote
        val selectedAccountCacheData = assetTransferAmountViewModel.getAccountCachedData() ?: return
        val selectedAsset = assetTransferAmountViewModel.getAssetInformation() ?: return
        sendTransaction(
            TransactionData.Send(
                selectedAccountCacheData,
                amount,
                selectedAsset,
                note,
                targetUser
            )
        )
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
        binding.progressBar.root.show()
    }

    private fun hideProgress() {
        binding.progressBar.root.hide()
    }
}
