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

package com.algorand.android.ui.rekey

import android.os.Bundle
import android.view.View
import androidx.annotation.StringRes
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRekeyInstructionBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.rekey.RekeyInstructionFragmentDirections.Companion.actionRekeyInstructionFragmentToRekeyLedgerSearchFragment
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyInstructionFragment : DaggerBaseFragment(R.layout.fragment_rekey_instruction) {

    private val rekeyInstructionViewModel: RekeyInstructionViewModel by viewModels()

    private val args: RekeyInstructionFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentRekeyInstructionBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val accountCacheData = rekeyInstructionViewModel.getCacheData(args.rekeyAddress)
        setupAccountSpecificTextViews(accountCacheData)
        binding.processButton.setOnClickListener { onStartProcessClick() }
    }

    private fun setupAccountSpecificTextViews(accountCacheData: AccountCacheData?) {
        val isStandardAccount = accountCacheData?.account?.type == Account.Type.STANDARD
        val isNotRekeyed = accountCacheData?.authAddress.isNullOrBlank()
        @StringRes val secondStepTextResId: Int
        @StringRes val descriptionTextResId: Int
        if (isStandardAccount && isNotRekeyed) {
            secondStepTextResId = R.string.this_account
            descriptionTextResId = R.string.replace_your_accounts
        } else {
            secondStepTextResId = R.string.your_old_ledger
            descriptionTextResId = R.string.replace_your_account
        }
        binding.rekeyInstructionSecondStepTextView.setText(secondStepTextResId)
        binding.descriptionTextView.setText(descriptionTextResId)
    }

    private fun onStartProcessClick() {
        nav(actionRekeyInstructionFragmentToRekeyLedgerSearchFragment(args.rekeyAddress))
    }
}
