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

package com.algorand.android.ui.settings.selection.languageselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseActivity
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentSelectionListBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.settings.selection.LanguageListItem
import com.algorand.android.ui.settings.selection.SelectionAdapter
import com.algorand.android.utils.supportedLanguages
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.util.Locale

@AndroidEntryPoint
class LanguageSelectionFragment : DaggerBaseFragment(R.layout.fragment_selection_list) {

    private val languageSelectionAdapter = SelectionAdapter(::onDifferentLanguageListItemClick)

    private val languageSelectionViewModel: LanguageSelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.language,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentSelectionListBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        loadLanguages()
    }

    private fun loadLanguages() {
        val currentLocale = (activity as BaseActivity).getCurrentLanguage().language
        languageSelectionAdapter.setItems(
            supportedLanguages.map {
                Locale(it).run {
                    LanguageListItem(language, getDisplayLanguage(this).capitalize(), currentLocale == language)
                }
            }
        )
    }

    private fun setupRecyclerView() {
        binding.selectionRecyclerView.adapter = languageSelectionAdapter
    }

    private fun onDifferentLanguageListItemClick(languageListItem: LanguageListItem) {
        val langId = languageListItem.languageId
        (activity as BaseActivity).setLanguage(langId)
        languageSelectionViewModel.logLanguageChange(langId)
    }
}
