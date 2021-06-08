/*
 * Copyright 2019 Algorand, Inc.
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
import androidx.appcompat.content.res.AppCompatResources
import androidx.appcompat.widget.PopupMenu
import androidx.constraintlayout.widget.ConstraintLayout.LayoutParams.BOTTOM
import androidx.constraintlayout.widget.ConstraintLayout.LayoutParams.TOP
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.customviews.TargetUserView
import com.algorand.android.customviews.Tooltip
import com.algorand.android.databinding.BottomSheetTransactionDetailBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.models.TransactionType
import com.algorand.android.models.User
import com.algorand.android.ui.transactiondetail.TransactionDetailBottomSheetDirections.Companion.actionTransactionDetailBottomSheetToAddEditContactFragment
import com.algorand.android.ui.transactiondetail.TransactionDetailBottomSheetDirections.Companion.actionTransactionDetailBottomSheetToShowQrBottomSheet
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.decodeBase64IfUTF8
import com.algorand.android.utils.enableClickToCopy
import com.algorand.android.utils.formatAsDateAndTime
import com.algorand.android.utils.openTransactionInAlgoExplorer
import com.algorand.android.utils.openTransactionInGoalSeeker
import com.algorand.android.utils.setDrawable
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

    private val binding by viewBinding(BottomSheetTransactionDetailBinding::bind)

    private val args: TransactionDetailBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        initUI()
        binding.targetUserView.setListener(targetUserListener)
        showCopyTutorialIfNeeded()
    }

    override fun onDestroy() {
        super.onDestroy()
        tutorialShowHandler?.removeCallbacksAndMessages(null)
    }

    private fun initUI() {
        with(args.transactionListItem) {
            setCloseTo(closeToAddress, closeToAmount)
            setFromToFields(transactionSymbol)
            setAccountAndAddress(contact, otherPublicKey, accountPublicKey)
            binding.amountTextView.setAmount(
                amount,
                decimals,
                isAlgorand,
                transactionSymbol
            )
            fee?.let { fee ->
                binding.feeTextView.setAmount(fee, ALGO_DECIMALS, true)
            }
            setTransactionId(id)
            if (transactionType == TransactionType.PENDING) {
                setStatusUI(isPending = true)
            } else {
                setRound(round)
                setStatusUI(isPending = false)
            }
            setRewardAmount(rewardAmount)
            setNote(noteInB64)
            setDate(zonedDateTime)
        }
    }

    private fun setAccountAndAddress(otherContact: User?, otherAddress: String?, accountPublicKey: String) {
        val address: String
        if (otherContact != null) {
            address = otherContact.publicKey
            binding.targetUserView.setUser(otherContact, enableAddressCopy = true, shouldUsePlaceHolder = false)
        } else {
            address = otherAddress.toString()
            binding.targetUserView.setAddress(
                otherAddress.orEmpty(),
                showShortened = false,
                enableAddressCopy = true
            )
        }

        binding.targetUserCopyImageView.enableClickToCopy(address)
        binding.targetUserLabelTextView.enableClickToCopy(address)

        binding.accountNameTextView.text = transactionDetailViewModel.getAccountName(accountPublicKey)
    }

    private fun setFromToFields(transactionSymbol: TransactionSymbol?) {
        if (transactionSymbol == TransactionSymbol.POSITIVE) {
            ConstraintSet().apply {
                clone(binding.fieldsLayout)
                connect(R.id.targetUserView, TOP, R.id.rewardDividerView, BOTTOM)
                connect(
                    R.id.accountNameTextView,
                    TOP,
                    R.id.targetUserDividerView,
                    BOTTOM
                )
                connect(
                    R.id.closeToTextView,
                    TOP,
                    R.id.accountNameDividerView,
                    BOTTOM
                )
            }.applyTo(binding.fieldsLayout)
            binding.targetUserLabelTextView.setText(R.string.from)
            binding.accountLabelTextView.setText(R.string.to)
        } else {
            binding.accountLabelTextView.setText(R.string.from)
            binding.targetUserLabelTextView.setText(R.string.to)
        }
    }

    private fun setRewardAmount(rewardAmount: Long?) {
        if (rewardAmount != null && rewardAmount != 0L) {
            binding.rewardTextView.setAmount(rewardAmount, ALGO_DECIMALS, true)
            binding.rewardGroup.visibility = View.VISIBLE
        }
    }

    private val targetUserListener = object : TargetUserView.Listener {
        override fun onShowQrClick(user: User) {
            nav(actionTransactionDetailBottomSheetToShowQrBottomSheet(user.name, user.publicKey))
        }

        override fun onAddContactClick(address: String) {
            nav(actionTransactionDetailBottomSheetToAddEditContactFragment(contactPublicKey = address))
        }
    }

    private fun setStatusUI(isPending: Boolean) {
        if (isPending) {
            binding.statusTextView.apply {
                setDrawable(start = AppCompatResources.getDrawable(context, R.drawable.ic_pending_20dp))
                setBackgroundResource(R.drawable.bg_orangefb_30dp_radius)
                setTextColor(ContextCompat.getColor(context, R.color.orange_D9))
                text = getString(R.string.pending)
            }
        } else {
            binding.statusTextView.apply {
                setDrawable(start = AppCompatResources.getDrawable(context, R.drawable.ic_check_20dp))
                setBackgroundResource(R.drawable.bg_greenec_30dp_radius)
                setTextColor(ContextCompat.getColor(context, R.color.green_0D))
                text = getString(R.string.confirmed)
            }
        }
    }

    private fun setRound(round: Long? = null) {
        if (round != null) {
            binding.roundTextView.text = round.toString()
            binding.roundGroup.visibility = View.VISIBLE
        }
    }

    private fun setNote(noteInBase64: String?) {
        if (noteInBase64 != null) {
            val decodedNote = noteInBase64.decodeBase64IfUTF8()
            binding.noteTextView.apply {
                text = decodedNote
                enableClickToCopy()
            }
            binding.noteLabelTextView.enableClickToCopy(decodedNote)
            binding.noteGroup.visibility = View.VISIBLE
        }
    }

    private fun setCloseTo(closeToAddress: String?, closeToAmount: BigInteger?) {
        if (closeToAddress != null && closeToAmount != null) {
            binding.closeToTextView.text = closeToAddress
            binding.closeAmountTextView.setAmount(closeToAmount, ALGO_DECIMALS, true)
            binding.closeToGroup.visibility = View.VISIBLE
        }
    }

    private fun setDate(zonedDateTime: ZonedDateTime?) {
        if (zonedDateTime != null) {
            binding.dateTextView.text = zonedDateTime.formatAsDateAndTime()
            binding.dateGroup.visibility = View.VISIBLE
        }
    }

    private fun setTransactionId(txId: String?) {
        if (txId != null) {
            val transactionIdWithoutPrefix = txId.removePrefix(TRANSACTION_ID_PREFIX)
            binding.idTextView.apply {
                text = transactionIdWithoutPrefix
                setOnClickListener {
                    openTransactionIdPopupMenu(it, transactionIdWithoutPrefix)
                }
            }
            binding.idLabelTextView.setOnClickListener {
                openTransactionIdPopupMenu(it, transactionIdWithoutPrefix)
            }
            binding.idGroup.visibility = View.VISIBLE
        }
    }

    private fun openTransactionIdPopupMenu(anchorView: View, transactionIdWithoutPrefix: String) {
        PopupMenu(anchorView.context, anchorView).apply {
            menuInflater.inflate(R.menu.transaction_id_menu, menu)
            setOnMenuItemClickListener {
                when (it.itemId) {
                    R.id.transactionIdMenuCopy -> {
                        context?.copyToClipboard(transactionIdWithoutPrefix)
                    }
                    R.id.transactionIdMenuOpenInAlgoExplorer -> {
                        val networkSlug = transactionDetailViewModel.getNetworkSlug()
                        context?.openTransactionInAlgoExplorer(transactionIdWithoutPrefix, networkSlug)
                    }
                    R.id.transactionIdMenuOpenInGoalSeeker -> {
                        val networkSlug = transactionDetailViewModel.getNetworkSlug()
                        context?.openTransactionInGoalSeeker(transactionIdWithoutPrefix, networkSlug)
                    }
                }
                return@setOnMenuItemClickListener true
            }
        }.show()
    }

    private fun showCopyTutorialIfNeeded() {
        if (transactionDetailViewModel.isCopyTutorialNeeded()) {
            tutorialShowHandler = Handler()
            tutorialShowHandler?.postDelayed({
                binding.targetUserCopyImageView.run {
                    val margin = resources.getDimensionPixelOffset(R.dimen.page_horizontal_spacing)
                    val config = Tooltip.Config(this, margin, R.string.press_and_hold, true)
                    Tooltip(context).show(config, viewLifecycleOwner)
                    transactionDetailViewModel.toggleCopyTutorialShownFlag()
                }
            }, TUTORIAL_SHOW_DELAY)
        }
    }

    companion object {
        private const val TUTORIAL_SHOW_DELAY = 600L
        private const val TRANSACTION_ID_PREFIX = "tx-"
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_transaction_detail"
    }
}
