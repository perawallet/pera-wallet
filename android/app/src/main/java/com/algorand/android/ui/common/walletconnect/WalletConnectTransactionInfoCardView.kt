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
import android.text.SpannableStringBuilder
import android.util.AttributeSet
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectTransactionInfoBinding
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.setAssetNameTextColorByVerificationTier
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectTransactionInfoCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectTransactionInfoBinding::inflate)

    private var listener: WalletConnectTransactionInfoCardViewListener? = null

    init {
        initRootLayout()
    }

    fun setListener(listener: WalletConnectTransactionInfoCardViewListener) {
        this.listener = listener
    }

    fun initTransactionInfo(transactionInfo: TransactionRequestTransactionInfo?) {
        if (transactionInfo == null) return
        with(transactionInfo) {
            binding.assetDeletionRequestWarningTextView.isVisible = showDeletionWarning
            initFromAddress(fromDisplayedAddress, fromAccountIconDrawablePreview)
            initToAddress(toDisplayedAddress, toAccountIconDrawablePreview)
            initAssetInformation(assetInformation, fromDisplayedAddress?.fullAddress)
            initAccountBalance(accountBalance, assetInformation)
            initRekeyToAddress(rekeyToAccountAddress, isLocalAccountSigner)
            initCloseToAddress(closeToAccountAddress, isLocalAccountSigner)
            initAssetCloseToAddress(
                address = assetCloseToAddress,
                assetShortName = assetInformation?.shortName,
                accountName = fromDisplayedAddress?.displayValue
            )
            initAssetName(assetName, isAssetUnnamed)
            initUnitName(assetUnitName, isAssetUnnamed)
        }
    }

    fun setWalletConnectTransactionInfoCardViewListener(listener: WalletConnectTransactionInfoCardViewListener) {
        this.listener = listener
    }

    private fun initAssetName(assetName: String?, isAssetUnnamed: Boolean) {
        when {
            isAssetUnnamed -> {
                with(binding) {
                    assetTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
                    assetNameGroup.show()
                }
            }
            !assetName.isNullOrBlank() -> {
                with(binding) {
                    assetTextView.text = assetName
                    assetNameGroup.show()
                }
            }
        }
    }

    private fun initUnitName(assetUnitName: String?, isAssetUnnamed: Boolean) {
        when {
            isAssetUnnamed -> {
                with(binding) {
                    assetUnitNameTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
                    unitNameGroup.show()
                }
            }
            !assetUnitName.isNullOrBlank() -> {
                with(binding) {
                    assetUnitNameTextView.text = assetUnitName
                    unitNameGroup.show()
                }
            }
        }
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

    private fun initAssetInformation(
        assetInformation: TransactionRequestAssetInformation?,
        accountAddress: String?
    ) {
        assetInformation?.let {
            with(binding) {
                it.verificationTierConfiguration.drawableResId?.run {
                    assetNameTextView.setDrawable(start = AppCompatResources.getDrawable(context, this))
                }
                assetNameTextView.apply {
                    text = assetInformation.shortName
                    setAssetNameTextColorByVerificationTier(it.verificationTierConfiguration)
                    setOnClickListener {
                        listener?.onAssetItemClick(assetId = assetInformation.assetId, accountAddress = accountAddress)
                    }
                }
                assetIdTextView.apply {
                    text = assetInformation.assetId.toString()
                    setOnClickListener {
                        listener?.onAssetItemClick(assetId = assetInformation.assetId, accountAddress = accountAddress)
                    }
                }
                assetGroup.show()
            }
        }
    }

    private fun initAccountBalance(balance: BigInteger?, assetInformation: TransactionRequestAssetInformation?) {
        balance?.let {
            with(binding) {
                // TODO Move this formatting into UseCase
                val formattedBalance = balance.formatAmount(assetInformation?.decimals ?: ALGO_DECIMALS)
                accountBalanceTextView.text = context?.getString(
                    R.string.pair_value_format,
                    formattedBalance,
                    assetInformation?.shortName.orEmpty()
                )
                accountBalanceGroup.show()
            }
        }
    }

    private fun initRekeyToAddress(address: BaseWalletConnectDisplayedAddress?, isLocalAccountSigner: Boolean) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                    setOnLongClickListener {
                        address?.fullAddress?.let { fullAddress -> listener?.onAccountAddressLongPressed(fullAddress) }
                        return@setOnLongClickListener true
                    }
                }
                rekeyGroup.show()
                rekeyToWarningTextView.isVisible = isLocalAccountSigner
            }
        }
    }

    private fun initCloseToAddress(address: BaseWalletConnectDisplayedAddress?, isLocalAccountSigner: Boolean) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                remainderCloseToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                    setOnLongClickListener {
                        address?.fullAddress?.let { fullAddress -> listener?.onAccountAddressLongPressed(fullAddress) }
                        return@setOnLongClickListener true
                    }
                }
                remainderGroup.show()
                remainderCloseToWarningTextView.isVisible = isLocalAccountSigner
            }
        }
    }

    private fun initAssetCloseToAddress(
        address: BaseWalletConnectDisplayedAddress?,
        assetShortName: String?,
        accountName: String?
    ) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                closeAssetToWarningTextView.text = root.context.getString(
                    R.string.this_transaction_is_sending_your,
                    assetShortName,
                    accountName
                )
                closeAssetToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                    setOnLongClickListener {
                        address?.fullAddress?.let { fullAddress -> listener?.onAccountAddressLongPressed(fullAddress) }
                        return@setOnLongClickListener true
                    }
                }
                closeAssetToGroup.show()
            }
        }
    }

    private fun initRootLayout() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }

    interface WalletConnectTransactionInfoCardViewListener {
        fun onAssetItemClick(assetId: Long?, accountAddress: String?)
        fun onAccountAddressLongPressed(accountAddress: String)
    }
}
