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

package com.algorand.android.ui.accountoptions

import android.os.Bundle
import android.os.Parcelable
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetHomeAccountOptionsBinding
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.parcelize.Parcelize

class HomeAccountOptionsBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_home_account_options) {

    private val binding by viewBinding(BottomSheetHomeAccountOptionsBinding::bind)

    private val args by navArgs<HomeAccountOptionsBottomSheetArgs>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            addAccountButton.setOnClickListener { onAddAccountClick() }
            arrangeListButton.setOnClickListener { onArrangeListClick() }
        }
    }

    private fun onAddAccountClick() {
        setNavigationResult(DESTINATION_RESULT, HomeAccountOptionsResult.AddAccount(args.isWatchAccount))
        dismiss()
    }

    private fun onArrangeListClick() {
        setNavigationResult(DESTINATION_RESULT, HomeAccountOptionsResult.ArrangeList(args.isWatchAccount))
        dismiss()
    }

    sealed class HomeAccountOptionsResult : Parcelable {

        abstract val isWatchAccount: Boolean

        @Parcelize
        data class AddAccount(override val isWatchAccount: Boolean) : HomeAccountOptionsResult()

        @Parcelize
        data class ArrangeList(override val isWatchAccount: Boolean) : HomeAccountOptionsResult()
    }

    companion object {
        const val DESTINATION_RESULT = "destination_result"
    }
}
