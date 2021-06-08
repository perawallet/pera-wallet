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

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.ui.settings.selection.ThemeListItem
import com.algorand.android.utils.preference.ThemePreference
import com.algorand.android.utils.preference.getSavedThemePreference
import com.algorand.android.utils.preference.saveThemePreference

class ThemeSelectionViewModel @ViewModelInject constructor(
    private val sharedPref: SharedPreferences
) : BaseViewModel() {

    fun getThemeList(): List<ThemeListItem> {
        val currentThemePreference = sharedPref.getSavedThemePreference()
        return ThemePreference.values().map { themePreference ->
            themePreference.convertToThemeListItem(isSelected = themePreference == currentThemePreference)
        }
    }

    fun saveThemePreference(themePreference: ThemePreference) {
        sharedPref.saveThemePreference(themePreference)
    }
}
