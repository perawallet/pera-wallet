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

package com.algorand.android.ui.register.ledger.verify

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemVerifiableLedgerAddressBinding
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.APPROVED
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.AWAITING_VERIFICATION
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.PENDING
import com.algorand.android.ui.register.ledger.verify.VerifiableLedgerAddressItemStatus.REJECTED

class VerifiableLedgerAddressViewHolder(
    private val binding: ItemVerifiableLedgerAddressBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: VerifiableLedgerAddressItem) {
        binding.authTextView.text = item.address
        when (item.status) {
            AWAITING_VERIFICATION -> showAwaitingVerificationUI()
            PENDING -> showPendingUI()
            APPROVED -> showApprovedUI()
            REJECTED -> showRejectedUI()
        }
    }

    private fun showAwaitingVerificationUI() {
        setStatusText(R.string.awaiting_verification, R.color.orange_F8)
        showLoading()
        customizeCard(backgroundColor = R.color.secondaryBackground, newStrokeColor = R.color.orange_F8)
    }

    private fun showPendingUI() {
        setStatusText(R.string.pending, R.color.tertiaryTextColor)
        setStatusImageView(R.drawable.ic_ledger_verify_pending)
        customizeCard(backgroundColor = R.color.transparent)
    }

    private fun showApprovedUI() {
        setStatusText(R.string.account_verified, R.color.colorPrimary)
        setStatusImageView(R.drawable.ic_ledger_verified)
        customizeCard(backgroundColor = R.color.secondaryBackground)
    }

    private fun showRejectedUI() {
        setStatusText(R.string.not_verified, R.color.red_E9)
        setStatusImageView(R.drawable.ic_rejected_warning)
        customizeCard(backgroundColor = R.color.red_E9_alpha_10)
    }

    private fun setStatusText(@StringRes textResId: Int, @ColorRes colorResId: Int) {
        with(binding.statusTextView) {
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

    private fun setStatusImageView(@DrawableRes imageResId: Int) {
        binding.loadingBar.isVisible = false
        binding.statusImageView.setImageResource(imageResId)
        binding.statusImageView.isVisible = true
    }

    private fun showLoading() {
        binding.statusImageView.isVisible = false
        binding.loadingBar.isVisible = true
    }

    companion object {
        fun create(parent: ViewGroup): VerifiableLedgerAddressViewHolder {
            return VerifiableLedgerAddressViewHolder(
                ItemVerifiableLedgerAddressBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            )
        }
    }
}
