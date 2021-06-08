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

package com.algorand.android.ui.settings.selection.currencyselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.ErrorListView
import com.algorand.android.databinding.FragmentCurrencySelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.ui.settings.selection.SelectionAdapter
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addDivider
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CurrencySelectionFragment : DaggerBaseFragment(R.layout.fragment_currency_selection) {

    private val currencySelectionAdapter = SelectionAdapter(::onDifferentCurrencyListItemClick)

    private val currencySelectionViewModel: CurrencySelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.currency,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentCurrencySelectionBinding::bind)

    private val currencyListObserver = Observer<Resource<List<CurrencyListItem>>> { resource ->
        resource.use(
            onSuccess = { list ->
                binding.errorListView.visibility = View.GONE
                currencySelectionAdapter.setItems(list)
            },
            onFailed = { errorMessage ->
                enableCurrencySelectionErrorState()
            },
            onLoadingFinished = {
                binding.loadingProgressBar.visibility = View.GONE
            },
            onLoading = {
                binding.loadingProgressBar.visibility = View.VISIBLE
            }
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupErrorListView()
        initObservers()
    }

    private fun setupRecyclerView() {
        binding.currencyRecyclerView.apply {
            adapter = currencySelectionAdapter
            addDivider(R.drawable.horizontal_divider_20dp)
        }
    }

    private fun initObservers() {
        currencySelectionViewModel.currencyListLiveData.observe(viewLifecycleOwner, currencyListObserver)
    }

    private fun onDifferentCurrencyListItemClick(currencyListItem: CurrencyListItem) {
        currencySelectionViewModel.setCurrencySelected(currencyListItem)
    }

    private fun setupErrorListView() {
        binding.errorListView.setTryAgainAction {
            currencySelectionViewModel.getCurrencyList()
        }
    }

    private fun enableCurrencySelectionErrorState() {
        binding.errorListView.setupError(ErrorListView.Type.DEFAULT_ERROR)
        binding.errorListView.visibility = View.VISIBLE
    }
}
