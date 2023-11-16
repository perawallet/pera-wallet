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

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectRequestInfoBinding
import com.algorand.android.models.ArbitraryDataRequestInfo
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectArbitraryDataInfoCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectRequestInfoBinding::inflate)

    private var listener: WalletConnectArbitraryDataInfoCardViewListener? = null

    init {
        initRootLayout()
    }

    fun setListener(listener: WalletConnectArbitraryDataInfoCardViewListener) {
        this.listener = listener
    }

    fun initArbitraryDataInfo(arbitraryDataInfo: ArbitraryDataRequestInfo?) {
        if (arbitraryDataInfo == null) return
        with(arbitraryDataInfo) {
            initFromAddress(fromDisplayedAddress, fromAccountIconDrawablePreview)
            initToAddress(toDisplayedAddress, toAccountIconDrawablePreview)
            initAccountBalance(accountBalance)
        }
    }

    fun setWalletConnectArbitraryDataInfoCardViewListener(listener: WalletConnectArbitraryDataInfoCardViewListener) {
        this.listener = listener
    }

    private fun initFromAddress(
        displayedAddress: BaseWalletConnectDisplayedAddress?,
        accountIconDrawablePreview: AccountIconDrawablePreview?
    ) {
        if (displayedAddress != null) {
            with(binding) {
                fromAccountNameTextView.apply {
                    text = displayedAddress.displayValue
                    isSingleLine = displayedAddress.isSingleLine == true
                    setOnLongClickListener {
                        listener?.onAccountAddressLongPressed(displayedAddress.fullAddress)
                        return@setOnLongClickListener true
                    }
                }
                if (accountIconDrawablePreview != null) {
                    val accountIconDrawable = AccountIconDrawable.create(
                        context = context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xlarge

                    )
                    fromAccountTypeImageView.setImageDrawable(accountIconDrawable)
                    fromAccountTypeImageView.show()
                }
                fromGroup.show()
            }
        }
    }

    private fun initToAddress(
        displayedAddress: BaseWalletConnectDisplayedAddress?,
        accountIconDrawablePreview: AccountIconDrawablePreview?
    ) {
        if (displayedAddress != null) {
            with(binding) {
                toAccountNameTextView.apply {
                    text = displayedAddress.displayValue
                    setOnLongClickListener {
                        listener?.onAccountAddressLongPressed(displayedAddress.fullAddress)
                        return@setOnLongClickListener true
                    }
                }
                if (accountIconDrawablePreview != null) {
                    val accountIconDrawable = AccountIconDrawable.create(
                        context = context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xlarge

                    )
                    toAccountTypeImageView.setImageDrawable(accountIconDrawable)
                    toAccountTypeImageView.show()
                }
                toGroup.show()
            }
        }
    }

    private fun initAccountBalance(balance: BigInteger?) {
        balance?.let {
            with(binding) {
                // TODO Move this formatting into UseCase
                val formattedBalance = balance.formatAmount(ALGO_DECIMALS)
                accountBalanceTextView.text = context?.getString(
                    R.string.pair_value_format,
                    formattedBalance,
                    ALGO_SHORT_NAME
                )
                accountBalanceGroup.show()
            }
        }
    }

    private fun initRootLayout() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }

    interface WalletConnectArbitraryDataInfoCardViewListener {
        fun onAccountAddressLongPressed(accountAddress: String)
    }
}
