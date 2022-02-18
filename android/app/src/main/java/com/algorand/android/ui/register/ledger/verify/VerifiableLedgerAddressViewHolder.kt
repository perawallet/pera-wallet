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

package com.algorand.android.ui.register.ledger.verify

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemVerifiableLedgerAddressBinding
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.APPROVED
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.AWAITING_VERIFICATION
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.PENDING
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.REJECTED
import com.algorand.android.utils.extensions.changeTextAppearance

class VerifiableLedgerAddressViewHolder(
    private val binding: ItemVerifiableLedgerAddressBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: VerifyLedgerAddressListItem.VerifiableLedgerAddressItem) {
        binding.authTextView.text = item.address
        when (item.status) {
            AWAITING_VERIFICATION -> showAwaitingVerificationUI()
            PENDING -> showPendingUI()
            APPROVED -> showApprovedUI()
            REJECTED -> showRejectedUI()
        }
    }

    private fun showAwaitingVerificationUI() {
        setStatusText(R.string.awaiting_verification, R.color.negativeColor, R.style.TextAppearance_Body_Sans)
        showLoading()
        customizeCard(backgroundColor = R.color.transparent, newStrokeColor = R.color.negativeColor)
    }

    private fun showPendingUI() {
        setStatusText(R.string.pending, R.color.secondaryTextColor, R.style.TextAppearance_Body_Sans)
        setStatusImageView(R.drawable.ic_clock, R.color.pending_ledger_approve)
        customizeCard(backgroundColor = R.color.transparent, newStrokeColor = R.color.secondaryTextColor)
    }

    private fun showApprovedUI() {
        setStatusText(R.string.account_verified, R.color.positiveColor, R.style.TextAppearance_Body_Sans_Medium)
        setStatusImageView(R.drawable.ic_check, R.color.positiveColor)
        customizeCard(backgroundColor = R.color.transparent, newStrokeColor = R.color.secondaryTextColor)
    }

    private fun showRejectedUI() {
        setStatusText(R.string.not_verified, R.color.negativeColor, R.style.TextAppearance_Body_Sans_Medium)
        setStatusImageView(R.drawable.ic_close, R.color.negativeColor)
        customizeCard(backgroundColor = R.color.transparent, newStrokeColor = R.color.secondaryTextColor)
    }

    private fun setStatusText(@StringRes textResId: Int, @ColorRes colorResId: Int, @StyleRes styleResId: Int) {
        with(binding.statusTextView) {
            changeTextAppearance(styleResId)
            setText(textResId)
            setTextColor(ContextCompat.getColor(context, colorResId))
        }
    }

    private fun customizeCard(@ColorRes backgroundColor: Int, @ColorRes newStrokeColor: Int = R.color.transparent) {
        with(binding.root) {
            strokeColor = ContextCompat.getColor(context, newStrokeColor)
            setCardBackgroundColor(ContextCompat.getColor(context, backgroundColor))
        }
    }

    private fun setStatusImageView(@DrawableRes imageResId: Int, @ColorRes colorResId: Int) {
        with(binding) {
            loadingBar.isVisible = false
            with(statusImageView) {
                setImageResource(imageResId)
                imageTintList = ContextCompat.getColorStateList(context, colorResId)
                isVisible = true
            }
        }
    }

    private fun showLoading() {
        binding.statusImageView.isVisible = false
        binding.loadingBar.isVisible = true
    }

    companion object {
        fun create(parent: ViewGroup): VerifiableLedgerAddressViewHolder {
            val binding = ItemVerifiableLedgerAddressBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return VerifiableLedgerAddressViewHolder(binding)
        }
    }
}
