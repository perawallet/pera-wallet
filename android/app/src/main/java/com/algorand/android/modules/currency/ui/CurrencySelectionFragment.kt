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

package com.algorand.android.modules.currency.ui

import android.os.Bundle
import android.text.style.ForegroundColorSpan
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentCurrencySelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.ui.CurrencySelectionPreview
import com.algorand.android.modules.currency.domain.model.SelectedCurrency
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.ui.settings.selection.SelectionAdapter
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class CurrencySelectionFragment : DaggerBaseFragment(R.layout.fragment_currency_selection) {

    private val currencySelectionAdapter = SelectionAdapter(::onDifferentCurrencyListItemClick)

    private val currencySelectionViewModel: CurrencySelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.currency,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentCurrencySelectionBinding::bind)

    private val currencySelectionPreviewCollector: suspend (CurrencySelectionPreview?) -> Unit = {
        updateUiWithCurrencySelectionPreview(it)
    }

    private val selectedCurrencyObserver: suspend (SelectedCurrency) -> Unit = { selectedCurrency ->
        setCurrencyDescriptionText(selectedCurrency)
    }

    private fun updateUiWithCurrencySelectionPreview(currencySelectionPreview: CurrencySelectionPreview?) {
        currencySelectionPreview?.let { preview ->
            with(binding) {
                preview.currencyList?.let { currencySelectionAdapter.setItems(it) }
                successContentGroup.isVisible = preview.isContentVisible
                loadingProgressBar.isVisible = preview.isLoading
                screenStateView.isVisible = preview.isScreenStateViewVisible
                preview.screenStateViewType?.let { screenStateView.setupUi(it) }
            }
        }
    }

    private fun setCurrencyDescriptionText(selectedCurrency: SelectedCurrency) {
        with(selectedCurrency) {
            binding.currencyDescriptionTextView.text = getCurrencyDescriptionText(
                primaryCurrencyId,
                secondaryCurrencyId
            )
        }
    }

    private fun getCurrencyDescriptionText(primaryCurrencyId: String, secondaryCurrencyId: String): String {
        return context?.run {
            val currencyIdTextColor = ContextCompat.getColor(this, R.color.text_main)
            val primaryColorAnnotationPair = "primaryCurrencyColor" to ForegroundColorSpan(currencyIdTextColor)
            val secondaryColorAnnotationPair = "secondaryCurrencyColor" to ForegroundColorSpan(currencyIdTextColor)
            val primaryCurrencyIdReplacementPair = "primaryCurrencyId" to primaryCurrencyId
            val secondaryCurrencyIdReplacementPair = "secondaryCurrencyId" to secondaryCurrencyId
            getXmlStyledString(
                stringResId = R.string.your_main_currency_is,
                customAnnotations = listOf(primaryColorAnnotationPair, secondaryColorAnnotationPair),
                replacementList = listOf(primaryCurrencyIdReplacementPair, secondaryCurrencyIdReplacementPair)
            ).toString()
        }.orEmpty()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        setupRecyclerView()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            screenStateView.setOnNeutralButtonClickListener {
                currencySelectionViewModel.refreshPreview()
            }
            searchView.setOnTextChanged { currencySelectionViewModel.updateSearchKeyword(it) }
        }
    }

    private fun setupRecyclerView() {
        binding.currencyRecyclerView.adapter = currencySelectionAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            currencySelectionViewModel.currencySelectionPreviewFlow.collectLatest(currencySelectionPreviewCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            currencySelectionViewModel.selectedCurrencyFlow.collectLatest(selectedCurrencyObserver)
        }
    }

    private fun onDifferentCurrencyListItemClick(currencyListItem: CurrencyListItem) {
        currencySelectionViewModel.setCurrencySelected(currencyListItem)
    }
}
