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

package com.algorand.android.utils.preference

import android.content.SharedPreferences
import androidx.annotation.StringRes
import androidx.appcompat.app.AppCompatDelegate
import com.algorand.android.R
import com.algorand.android.ui.settings.selection.ThemeListItem

private const val THEME_PREFERENCE_KEY = "theme_preference_key"

fun SharedPreferences.saveThemePreference(themePreference: ThemePreference) {
    edit().putString(THEME_PREFERENCE_KEY, themePreference.name).apply()
}

fun SharedPreferences.getSavedThemePreference(): ThemePreference {
    val savedThemePreferenceKey = getString(THEME_PREFERENCE_KEY, null) ?: return ThemePreference.SYSTEM_DEFAULT
    return ThemePreference.valueOf(savedThemePreferenceKey)
}

enum class ThemePreference(
    @StringRes val visibleNameResId: Int
) {
    SYSTEM_DEFAULT(R.string.system_default),
    DARK(R.string.dark),
    LIGHT(R.string.light);

    fun convertToSystemAbbr(): Int {
        return when (this) {
            SYSTEM_DEFAULT -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
            DARK -> AppCompatDelegate.MODE_NIGHT_YES
            LIGHT -> AppCompatDelegate.MODE_NIGHT_NO
        }
    }

    fun convertToThemeListItem(isSelected: Boolean): ThemeListItem {
        return ThemeListItem(name, visibleNameResId, isSelected)
    }
}
