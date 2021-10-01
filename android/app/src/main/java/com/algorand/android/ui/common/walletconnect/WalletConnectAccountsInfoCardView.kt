/*
 * Copyright 2019 Algorand, Inc.
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
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.setPadding
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectAccountsInfoCardBinding
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAccountsInfo
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectAccountsInfoCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectAccountsInfoCardBinding::inflate)

    init {
        initRootLayout()
    }

    fun initAccountsInfo(walletConnectAccountsInfo: WalletConnectAccountsInfo) {
        binding.root.visibility = View.VISIBLE
        with(walletConnectAccountsInfo) {
            initAmount(amount, safeCreateAssetDecimal)
            initFee(fee)
            initDecimalPlaces(createdAssetDecimal)
            initDefaultFrozen(isFrozen)
            initManagerAccount(managerAddress)
            initReserveAccount(reserveAddress)
            initFreezeAccount(frozenAddress)
            initClawbackAccount(clawbackAddress)
        }
    }

    private fun initDefaultFrozen(frozen: Boolean?) {
        if (frozen != null) {
            with(binding) {
                val frozenTextRes = if (frozen) R.string.on else R.string.off
                defaultFrozenTextView.setText(frozenTextRes)
                defaultFrozenGroup.visibility = VISIBLE
            }
        }
    }

    private fun initDecimalPlaces(decimals: Long?) {
        if (decimals != null) {
            with(binding) {
                decimalPlacesTextView.text = decimals.toString()
                decimalPlacesGroup.visibility = VISIBLE
            }
        }
    }

    private fun initAmount(amount: BigInteger?, decimal: Int) {
        if (amount != null) {
            with(binding) {
                amountTextView.setAmount(amount, decimal, false)
                amountGroup.visibility = VISIBLE
            }
        }
    }

    private fun initReserveAccount(reserveAddress: BaseWalletConnectDisplayedAddress?) {
        if (!reserveAddress?.displayValue.isNullOrBlank()) {
            with(binding) {
                reserveAccountTextView.apply {
                    text = reserveAddress?.displayValue
                    isSingleLine = reserveAddress?.isSingleLine == true
                }
                reserveAccountGroup.visibility = VISIBLE
            }
        }
    }

    private fun initClawbackAccount(clawbackAddress: BaseWalletConnectDisplayedAddress?) {
        if (!clawbackAddress?.displayValue.isNullOrBlank()) {
            with(binding) {
                clawbackAccountTextView.apply {
                    text = clawbackAddress?.displayValue
                    isSingleLine = clawbackAddress?.isSingleLine == true
                }
                clawbackAccountGroup.visibility = VISIBLE
            }
        }
    }

    private fun initFreezeAccount(frozenAddress: BaseWalletConnectDisplayedAddress?) {
        if (!frozenAddress?.displayValue.isNullOrBlank()) {
            with(binding) {
                freezeAccountTextView.apply {
                    text = frozenAddress?.displayValue
                    isSingleLine = frozenAddress?.isSingleLine == true
                }
                freezeAccountGroup.visibility = VISIBLE
            }
        }
    }

    private fun initManagerAccount(managerAddress: BaseWalletConnectDisplayedAddress?) {
        if (!managerAddress?.displayValue.isNullOrBlank()) {
            with(binding) {
                managerAccountNameTextView.apply {
                    text = managerAddress?.displayValue
                    isSingleLine = managerAddress?.isSingleLine == true
                }
                managerAccountGroup.visibility = VISIBLE
            }
        }
    }

    private fun initFee(fee: Long) {
        binding.feeTextView.setAmount(fee, ALGO_DECIMALS, true)
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
        updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.smallshadow_bottom_padding_18dp))
    }
}
