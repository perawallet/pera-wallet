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

package com.algorand.android.ui.common.accountselector

import android.os.Bundle
import android.os.Parcelable
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountSelectionBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.addDivider
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.parcelize.Parcelize

@AndroidEntryPoint
class AccountSelectionBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_account_selection,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    @Inject
    lateinit var accountManager: AccountManager

    private val args: AccountSelectionBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetAccountSelectionBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.toolbar.configure(ToolbarConfiguration(titleResId = args.titleResId))
        setupRecyclerView(
            accountCacheManager.getAccountCacheWithSpecificAsset(args.assetId, listOf(Account.Type.WATCH))
        )
        binding.cancelButton.setOnClickListener { navBack() }
    }

    private fun setupRecyclerView(accountList: List<Pair<AccountCacheData, AssetInformation>>) {
        binding.accountRecyclerView.apply {
            val accountsSelectorAdapter = AccountsSelectorAdapter(::onAccountSelect, args.showBalance).apply {
                setData(accountList)
            }
            adapter = accountsSelectorAdapter
            addDivider(R.drawable.horizontal_divider_16dp)
        }
    }

    private fun onAccountSelect(accountCacheData: AccountCacheData, assetInformation: AssetInformation) {
        setNavigationResult(ACCOUNT_SELECTION_KEY, Result(accountCacheData, assetInformation))
        navBack()
    }

    @Parcelize
    data class Result(
        val accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation
    ) : Parcelable

    companion object {
        const val ACCOUNT_SELECTION_KEY = "account_selection_key"
    }
}
