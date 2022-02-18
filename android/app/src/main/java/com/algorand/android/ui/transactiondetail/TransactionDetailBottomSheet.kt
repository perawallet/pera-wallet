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

package com.algorand.android.ui.transactiondetail

import android.os.Bundle
import android.os.Handler
import android.view.View
import androidx.constraintlayout.widget.ConstraintSet
import androidx.constraintlayout.widget.ConstraintSet.BOTTOM
import androidx.constraintlayout.widget.ConstraintSet.TOP
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.customviews.Tooltip
import com.algorand.android.databinding.BottomSheetTransactionDetailBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionItemType
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasChipGroupView
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.decodeBase64IfUTF8
import com.algorand.android.utils.enableClickToCopy
import com.algorand.android.utils.formatAsTxnDateAndTime
import com.algorand.android.utils.openTransactionInAlgoExplorer
import com.algorand.android.utils.openTransactionInGoalSeeker
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import java.time.ZonedDateTime

@AndroidEntryPoint
class TransactionDetailBottomSheet : DaggerBaseBottomSheet(
    R.layout.bottom_sheet_transaction_detail,
    fullPageNeeded = true,
    firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
) {

    private val transactionDetailViewModel: TransactionDetailViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.transaction_detail,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private var tutorialShowHandler: Handler? = null

    private val chipGroupListener = object : WalletConnectExtrasChipGroupView.Listener {
        override fun onOpenInAlgoExplorerClick(url: String) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openTransactionInAlgoExplorer(url, networkSlug)
        }

        override fun onOpenInGoalSeekerClick(url: String) {
            val networkSlug = transactionDetailViewModel.getNetworkSlug()
            context?.openTransactionInGoalSeeker(url, networkSlug)
        }
    }

    private val binding by viewBinding(BottomSheetTransactionDetailBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        initUI()
        binding.toUserView.setOnAddButtonClickListener(::onAddButtonClicked)
        showCopyTutorialIfNeeded()
    }

    private fun initUI() {
        val transaction = transactionDetailViewModel.getTransaction() ?: return
        val assetInformation = transactionDetailViewModel.getTxnAssetInformation()
        with(transaction) {
            setFromToFields(transactionSymbol)
            setCloseTo(closeToAddress, closeToAmount, transactionSymbol, assetInformation)
            setToAndFromAddress(transactionTargetUser, otherPublicKey, accountPublicKey)
            setAmount(amount, decimals, transactionSymbol, assetInformation)
            setFee(fee)
            setNote(noteInB64)
            setDate(zonedDateTime)
            setTransactionId(id)
            setChipButtons(id)
            if (this is BaseTransactionItem.TransactionItem.Transaction) {
                setStatusUI(transactionItemType == TransactionItemType.PENDING)
            } else {
                setRewardAmount(rewardAmount, assetInformation)
            }
        }
    }

    private fun setAmount(
        amount: BigInteger?,
        decimal: Int,
        transactionSymbol: TransactionSymbol?,
        assetInformation: AssetInformation?
    ) {
        binding.amountView.setAmount(amount, decimal, transactionSymbol, assetInformation?.shortName)
    }

    private fun setFee(fee: Long?) {
        fee?.let { binding.feeAmountTextView.setAmountAsFee(it) }
    }

    private fun setStatusUI(isPending: Boolean) {
        if (isPending) {
            binding.statusTextView.apply {
                setBackgroundResource(R.drawable.bg_transaction_pending)
                setTextColor(ContextCompat.getColor(context, R.color.secondaryTextColor))
                text = getString(R.string.pending)
            }
        } else {
            binding.statusTextView.apply {
                setBackgroundResource(R.drawable.bg_turquoise_1a_24dp_radius)
                setTextColor(ContextCompat.getColor(context, R.color.transaction_amount_positive_color))
                text = getString(R.string.completed)
            }
        }
        binding.statusGroup.visibility = View.VISIBLE
        binding.transactionGroup.isVisible = isPending.not()
    }

    private fun setNote(noteInBase64: String?) {
        noteInBase64?.let { note ->
            val decodedNote = note.decodeBase64IfUTF8()
            binding.noteTextView.apply {
                text = decodedNote
                enableClickToCopy()
            }
            binding.noteLabelTextView.enableClickToCopy(decodedNote)
            binding.noteGroup.visibility = View.VISIBLE
        }
    }

    private fun setDate(zonedDateTime: ZonedDateTime?) {
        zonedDateTime?.let { date ->
            binding.dateTextView.text = date.formatAsTxnDateAndTime()
        }
    }

    private fun setTransactionId(txId: String?) {
        txId?.let { txnId ->
            binding.transactionIdTextView.text = txnId.removePrefix(TRANSACTION_ID_PREFIX)
        }
    }

    private fun setChipButtons(transactionIdWithoutPrefix: String?) {
        binding.extrasChipGroupView.apply {
            initOpenInExplorerChips(transactionIdWithoutPrefix, R.dimen.spacing_zero)
            setChipGroupListener(chipGroupListener)
        }
    }

    private fun setRewardAmount(rewardAmount: Long?, assetInformation: AssetInformation?) {
        if (rewardAmount != null && rewardAmount != 0L) {
            binding.rewardAmountTextView.setAmountAsReward(rewardAmount, ALGO_DECIMALS, assetInformation)
            binding.rewardGroup.visibility = View.VISIBLE
        }
    }

    private fun onAddButtonClicked(address: String) {
        nav(
            TransactionDetailBottomSheetDirections.actionTransactionDetailBottomSheetToAddContactFragment(
                contactPublicKey = address
            )
        )
    }

    private fun setFromToFields(transactionSymbol: TransactionSymbol?) {
        if (transactionSymbol == TransactionSymbol.POSITIVE) {
            ConstraintSet().apply {
                clone(binding.containerLayout)
                connect(R.id.toUserView, TOP, R.id.statusDivider, BOTTOM)
                connect(R.id.fromUserView, TOP, R.id.toUserView, BOTTOM)
                connect(R.id.feeAmountTextView, TOP, R.id.fromUserView, BOTTOM)
            }.applyTo(binding.containerLayout)
            binding.toLabelTextView.setText(R.string.from)
            binding.fromLabelTextView.setText(R.string.to)
        } else {
            binding.fromLabelTextView.setText(R.string.from)
            binding.toLabelTextView.setText(R.string.to)
        }
    }

    private fun setCloseTo(
        closeToAddress: String?,
        closeToAmount: BigInteger?,
        transactionSymbol: TransactionSymbol?,
        assetInformation: AssetInformation?
    ) {
        if (closeToAddress != null && closeToAmount != null) {
            if (transactionSymbol == TransactionSymbol.POSITIVE) {
                ConstraintSet().apply {
                    clone(binding.containerLayout)
                    connect(R.id.closeToUserView, TOP, R.id.fromUserView, BOTTOM)
                    connect(R.id.feeAmountTextView, TOP, R.id.closeToUserView, BOTTOM)
                }.applyTo(binding.containerLayout)
            }
            binding.closeToUserView.setAddress(closeToAddress)
            binding.closeAmountView.setAmount(
                closeToAmount,
                ALGO_DECIMALS,
                transactionSymbol,
                assetInformation?.shortName
            )
            binding.closeToGroup.visibility = View.VISIBLE
        }
    }

    private fun setToAndFromAddress(
        transactionTargetUser: TransactionTargetUser?,
        otherAddress: String?,
        accountPublicKey: String
    ) {
        val address: String
        val accountCachedData = transactionDetailViewModel.getAccountCacheData(accountPublicKey)
        with(binding) {
            with(transactionTargetUser) {
                if (this != null) {
                    address = publicKey
                    when {
                        publicKey == accountPublicKey -> toUserView.setAccount(accountCachedData)
                        accountName != null && accountIcon != null -> toUserView.setAccount(accountName, accountIcon)
                        contact != null -> toUserView.setContact(contact)
                        else -> toUserView.setAddress(publicKey)
                    }
                } else {
                    address = otherAddress.toString()
                    toUserView.setAddress(address)
                }
            }
            toUserView.enableClickToCopy(address)
            toLabelTextView.enableClickToCopy(address)
            fromUserView.setAccount(accountCachedData)
        }
    }

    private fun showCopyTutorialIfNeeded() {
        if (transactionDetailViewModel.isCopyTutorialNeeded()) {
            tutorialShowHandler = Handler()
            tutorialShowHandler?.postDelayed({
                binding.toUserView.run {
                    val margin = resources.getDimensionPixelOffset(R.dimen.page_horizontal_spacing)
                    val config = Tooltip.Config(this, margin, R.string.press_and_hold, true)
                    Tooltip(context).show(config, viewLifecycleOwner)
                    transactionDetailViewModel.toggleCopyTutorialShownFlag()
                }
            }, TUTORIAL_SHOW_DELAY)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        tutorialShowHandler?.removeCallbacksAndMessages(null)
    }

    companion object {
        private const val TUTORIAL_SHOW_DELAY = 600L
        private const val TRANSACTION_ID_PREFIX = "tx-"
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_transaction_detail"
    }
}
