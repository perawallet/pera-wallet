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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomAccountAssetSelectorBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger
import kotlin.properties.Delegates

class AccountAssetSelector @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private var showBalance = false
    private var showAccountType = false
    private var accountCacheManager: AccountCacheManager? = null
    private var listener: Listener? = null

    private val binding = viewBinding(CustomAccountAssetSelectorBinding::inflate)

    private var isLocked by Delegates.observable(true, { _, _, newValue ->
        if (newValue.not()) {
            showEditableUI()
        } else {
            showLockedUI()
        }
    })

    private var accountAssetPair by Delegates.observable<Pair<AccountCacheData, AssetInformation>?>(
        null,
        { _, _, newValue ->
            if (newValue == null) {
                binding.notEmptyLayout.visibility = View.GONE
                binding.emptyTextView.visibility = View.VISIBLE
                isEnabled = true
            } else {
                isEnabled = false
                val (accountCacheData, asset) = newValue
                binding.assetNameTextView.setupUI(asset)
                binding.accountNameTextView.text = accountCacheData.account.name
                setAccountTypeImage(accountCacheData)
                refreshBalance(accountCacheData.account, asset)
                binding.emptyTextView.visibility = View.INVISIBLE
                binding.notEmptyLayout.visibility = View.VISIBLE
            }
        })

    private var balance by Delegates.observable<BigInteger?>(null, { _, _, newValue ->
        if (showBalance) {
            binding.balanceTextView.apply {
                val currentAsset = accountAssetPair?.second
                visibility = if (newValue != null && currentAsset != null) {
                    setAmount(newValue, currentAsset.decimals, false)
                    View.VISIBLE
                } else {
                    View.GONE
                }
            }
        }
    })

    init {
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        showEditableUI()

        val attr = context.obtainStyledAttributes(attrs, R.styleable.AccountAssetSelector)

        showBalance =
            attr.getBoolean(R.styleable.AccountAssetSelector_showBalance, false)
        showAccountType =
            attr.getBoolean(R.styleable.AccountAssetSelector_showAccountType, false)

        attr.recycle()

        isEnabled = true

        binding.cancelButton.setOnClickListener { onCancelClick() }

        setOnClickListener { listener?.onChooseAssetClick() }

        if (showBalance) {
            binding.balanceTextView.visibility = View.VISIBLE
        }
    }

    fun setAccountAndAsset(accountCacheData: AccountCacheData, assetInformation: AssetInformation, isLocked: Boolean) {
        this.isLocked = isLocked
        accountAssetPair = Pair(accountCacheData, assetInformation)
    }

    fun getSelectedAsset(): AssetInformation? {
        return accountAssetPair?.second
    }

    fun getSelectedAccountCacheData(): AccountCacheData? {
        return accountAssetPair?.first
    }

    fun getAssetBalance(): BigInteger? {
        return balance
    }

    fun setupView(listener: Listener? = null, accountCacheManager: AccountCacheManager? = null) {
        this.listener = listener
        this.accountCacheManager = accountCacheManager
    }

    private fun onCancelClick() {
        accountAssetPair = null
    }

    private fun refreshBalance(account: Account, asset: AssetInformation) {
        if (showBalance) {
            balance = accountCacheManager?.getAssetInformation(account.address, asset.assetId)?.amount
        }
    }

    private fun setAccountTypeImage(newAccountCacheData: AccountCacheData?) {
        if (showAccountType && newAccountCacheData != null) {
            binding.accountTypeImageView.apply {
                visibility = View.VISIBLE
                setImageResource(newAccountCacheData.getImageResource())
            }
        }
    }

    private fun showLockedUI() {
        setBackgroundResource(R.drawable.bg_disabled_input)
        binding.cancelButton.visibility = View.GONE
    }

    private fun showEditableUI() {
        setBackgroundResource(R.drawable.bg_smallshadow_with_ripple)
        binding.cancelButton.visibility = View.VISIBLE
    }

    interface Listener {
        fun onChooseAssetClick()
    }
}
