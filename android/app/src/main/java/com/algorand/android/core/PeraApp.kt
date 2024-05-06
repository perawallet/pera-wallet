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
import androidx.appcompat.app.AppCompatDelegate
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.multidex.MultiDex
import com.algorand.android.migration.MigrationManager
import com.algorand.android.modules.autolockmanager.ui.AutoLockManager
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.modules.pendingintentkeeper.ui.PendingIntentKeeper
import com.algorand.android.utils.coremanager.ApplicationStatusObserver
import com.algorand.android.utils.preference.getSavedThemePreference
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject

@HiltAndroidApp
open class PeraApp : Application() {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    @Inject
    lateinit var migrationManager: MigrationManager

    @Inject
    lateinit var firebaseTokenManager: FirebaseTokenManager

    @Inject
    lateinit var autoLockManager: AutoLockManager

    @Inject
    lateinit var walletConnectInitializer: WalletConnectInitializer

    @Inject
    lateinit var applicationStatusObserver: ApplicationStatusObserver

    @Inject
    lateinit var pendingIntentKeeper: PendingIntentKeeper

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun onCreate() {
        super.onCreate()
        migrationManager.makeMigrations()

        AppCompatDelegate.setDefaultNightMode(sharedPref.getSavedThemePreference().convertToSystemAbbr())
        accountManager.initAccounts()
        initializeWalletConnect()
        bindApplicationLifecycleAwareComponents()
        bindActivityLifecycleAwareComponents()
    }

    private fun initializeWalletConnect() {
        walletConnectInitializer.initialize(this, ProcessLifecycleOwner.get().lifecycle)
    }

    private fun bindApplicationLifecycleAwareComponents() {
        with(ProcessLifecycleOwner.get().lifecycle) {
            addObserver(autoLockManager)
            addObserver(applicationStatusObserver)
            addObserver(firebaseTokenManager)
            addObserver(pendingIntentKeeper)
        }
    }

    private fun bindActivityLifecycleAwareComponents() {
        registerActivityLifecycleCallbacks(autoLockManager)
    }

    // https://issuetracker.google.com/issues/141726323
    // if theme is changed via quick-settings, nothing changes with NIGHT_MODE_FOLLOW_SYSTEM
    // so, added to fix this issue.
    // this issue can be fixed if implementation of localization is changed.
    override fun onConfigurationChanged(newConfig: Configuration) {
        applicationContext.resources.configuration.uiMode = newConfig.uiMode
        super.onConfigurationChanged(newConfig)
    }
}
