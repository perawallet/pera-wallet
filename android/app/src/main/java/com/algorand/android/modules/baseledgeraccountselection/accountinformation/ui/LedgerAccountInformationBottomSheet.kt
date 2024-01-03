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

package com.algorand.android.modules.baseledgeraccountselection.accountinformation.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.BottomSheetLedgerInformationBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.baseledgeraccountselection.accountinformation.ui.adapter.LedgerInformationAdapter
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

// TODO: extend this from BaseFoundAccountInformationFragment
@AndroidEntryPoint
class LedgerAccountInformationBottomSheet : BaseFragment(R.layout.bottom_sheet_ledger_information) {

    private val ledgerAccountInformationViewModel: LedgerAccountInformationViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(BottomSheetLedgerInformationBinding::bind)

    private val ledgerInformationAdapter = LedgerInformationAdapter()

    private val ledgerInformationCollector: suspend (List<LedgerInformationListItem>?) -> Unit = {
        ledgerInformationAdapter.submitList(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        setupRecyclerView()
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = ledgerAccountInformationViewModel.ledgerInformationFlow,
            collection = ledgerInformationCollector
        )
    }

    private fun setupRecyclerView() {
        binding.ledgerInformationList.adapter = ledgerInformationAdapter
    }
}
