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

package com.algorand.android.ui.settings.selection.themeselection

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatDelegate
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentThemeSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.settings.selection.SelectionAdapter
import com.algorand.android.ui.settings.selection.ThemeListItem
import com.algorand.android.utils.addDivider
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ThemeSelectionFragment : DaggerBaseFragment(R.layout.fragment_theme_selection) {

    private val themeSelectionViewModel: ThemeSelectionViewModel by viewModels()

    private val themeSelectionAdapter = SelectionAdapter(::onDifferentThemeSelectionClick)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.set_theme,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentThemeSelectionBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
    }

    private fun setupRecyclerView() {
        binding.root.apply {
            adapter = themeSelectionAdapter
            addDivider(R.drawable.horizontal_divider_20dp)
        }
        themeSelectionAdapter.setItems(themeSelectionViewModel.getThemeList())
    }

    private fun onDifferentThemeSelectionClick(themeSelectionItem: ThemeListItem) {
        themeSelectionItem.convertToThemePreference()?.run {
            themeSelectionViewModel.saveThemePreference(this)
            AppCompatDelegate.setDefaultNightMode(convertToSystemAbbr())
        }
    }
}
