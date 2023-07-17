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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectConnectionAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AccountIconDrawable

class WalletConnectConnectionAccountItemViewHolder(
    private val binding: ItemWalletConnectConnectionAccountBinding,
    private val listener: Listener
) : BaseViewHolder<BaseWalletConnectConnectionItem>(binding.root) {

    override fun bind(item: BaseWalletConnectConnectionItem) {
        if (item !is BaseWalletConnectConnectionItem.AccountItem) return
        with(item) {
            setAccountIcon(accountIconDrawablePreview)
            setAccountTitleText(accountDisplayName)
            setAccountDescriptionText(accountDisplayName)
            setButtonState(buttonState, accountAddress)
        }
    }

    private fun setAccountIcon(accountIconDrawablePreview: AccountIconDrawablePreview) {
        binding.statefulAccountItemView.apply {
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconDrawablePreview = accountIconDrawablePreview,
                sizeResId = R.dimen.spacing_xxxxlarge
            )
            setStartIconDrawable(accountIconDrawable)
        }
    }

    private fun setAccountTitleText(accountDisplayName: AccountDisplayName?) {
        binding.statefulAccountItemView.run {
            setTitleText(accountDisplayName?.getAccountPrimaryDisplayName())
        }
    }

    private fun setAccountDescriptionText(accountDisplayName: AccountDisplayName?) {
        binding.statefulAccountItemView.run {
            setDescriptionText(accountDisplayName?.getAccountSecondaryDisplayName(resources))
        }
    }

    private fun setButtonState(buttonState: AccountAssetItemButtonState, accountAddress: String) {
        binding.statefulAccountItemView.run {
            setButtonState(buttonState)
            setActionButtonClickListener { listener.onAccountChecked(accountAddress) }
            setOnClickListener { listener.onAccountChecked(accountAddress) }
        }
    }

    fun interface Listener {
        fun onAccountChecked(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): WalletConnectConnectionAccountItemViewHolder {
            val binding =
                ItemWalletConnectConnectionAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectConnectionAccountItemViewHolder(binding, listener)
        }
    }
}
