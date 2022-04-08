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

package com.algorand.android.core

import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import android.content.res.Resources
import androidx.appcompat.app.AppCompatDelegate
import androidx.multidex.MultiDex
import com.akexorcist.localizationactivity.core.LocalizationApplicationDelegate
import com.algorand.android.BuildConfig
import com.algorand.android.utils.preference.getSavedThemePreference
import com.google.android.play.core.missingsplits.MissingSplitsManagerFactory
import dagger.hilt.android.HiltAndroidApp
import java.util.Locale
import javax.inject.Inject

@HiltAndroidApp
open class PeraApp : Application() {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val localizationDelegate = LocalizationApplicationDelegate()

    override fun attachBaseContext(base: Context) {
        localizationDelegate.setDefaultLanguage(base, Locale.getDefault())
        super.attachBaseContext(localizationDelegate.attachBaseContext(base))
        if (BuildConfig.DEBUG) {
            MultiDex.install(this)
        }
    }

    override fun onCreate() {
        super.onCreate()
        // https://developer.android.com/guide/app-bundle/sideload-check
        if (MissingSplitsManagerFactory.create(this).disableAppIfMissingRequiredSplits()) {
            // Skip app initialization because missing required drawables.
            return
        }
        AppCompatDelegate.setDefaultNightMode(sharedPref.getSavedThemePreference().convertToSystemAbbr())
        accountManager.initAccounts()
    }

    // https://issuetracker.google.com/issues/141726323
    // if theme is changed via quick-settings, nothing changes with NIGHT_MODE_FOLLOW_SYSTEM
    // so, added to fix this issue.
    // this issue can be fixed if implementation of localization is changed.
    override fun onConfigurationChanged(newConfig: Configuration) {
        applicationContext.resources.configuration.uiMode = newConfig.uiMode
        super.onConfigurationChanged(newConfig)
        localizationDelegate.onConfigurationChanged(this)
    }

    override fun getApplicationContext(): Context {
        return localizationDelegate.getApplicationContext(super.getApplicationContext())
    }

    override fun getResources(): Resources {
        return localizationDelegate.getResources(baseContext, super.getResources())
    }
}
