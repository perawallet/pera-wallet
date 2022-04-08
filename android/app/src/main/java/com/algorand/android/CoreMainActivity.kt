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

package com.algorand.android

import android.content.SharedPreferences
import android.os.Bundle
import android.os.PersistableBundle
import android.view.View
import androidx.annotation.IdRes
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.navigation.NavController
import androidx.navigation.NavDirections
import androidx.navigation.fragment.NavHostFragment
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseActivity
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.database.ContactDao
import com.algorand.android.databinding.ActivityMainBinding
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.notification.PeraNotificationManager
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.BETANET_NETWORK_SLUG
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import com.algorand.android.utils.coremanager.AccountDetailCacheManager
import com.algorand.android.utils.coremanager.AlgoPriceManager
import com.algorand.android.utils.coremanager.AssetCacheManager
import com.algorand.android.utils.coremanager.BlockPollingManager
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.navigateSafe
import com.algorand.android.utils.preference.getRegisterSkip
import com.algorand.android.utils.setupWithNavController
import com.algorand.android.utils.showDarkStatusBarIcons
import com.algorand.android.utils.showLightStatusBarIcons
import com.algorand.android.utils.viewbinding.viewBinding
import javax.inject.Inject
import kotlin.properties.Delegates

abstract class CoreMainActivity : BaseActivity() {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var indexerInterceptor: IndexerInterceptor

    @Inject
    lateinit var peraNotificationManager: PeraNotificationManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    @Inject
    lateinit var contactsDao: ContactDao

    @Inject
    lateinit var sharedPref: SharedPreferences

    lateinit var navController: NavController

    protected val binding by viewBinding(ActivityMainBinding::inflate)

    @Inject
    lateinit var algoPriceManager: AlgoPriceManager

    @Inject
    lateinit var blockPollingManager: BlockPollingManager

    @Inject
    lateinit var accountDetailCacheManager: AccountDetailCacheManager

    @Inject
    lateinit var assetCacheManager: AssetCacheManager

    var isBottomBarNavigationVisible by Delegates.observable(true) { _, oldValue, newValue ->
        if (newValue != oldValue) {
            binding.bottomNavigationView.isVisible = newValue
            binding.sendReceiveTabBarView.apply {
                if (newValue) visibility = View.VISIBLE else hideWithoutAnimation()
            }
        }
    }

    var statusBarConfiguration: StatusBarConfiguration by Delegates.observable(
        StatusBarConfiguration()
    ) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            handleStatusBarChanges(newValue)
            handleStatusBarIconColorChanges(oldValue, newValue)
        }
    }

    private var isConnectedToTestNet: Boolean by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            handleStatusBarChanges(statusBarConfiguration)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        navController = (supportFragmentManager.findFragmentById(binding.navigationHostFragment.id) as NavHostFragment)
            .navController
        startNavigation()
        if (savedInstanceState != null) {
            isBottomBarNavigationVisible = savedInstanceState.getBoolean(IS_BOTTOM_BAR_VISIBLE_KEY)
        }
        checkIfConnectedToTestNet()

        initializeCoreManagers()
    }

    private fun initializeCoreManagers() {
        with(lifecycle) {
            addObserver(algoPriceManager)
            addObserver(blockPollingManager)
            addObserver(accountDetailCacheManager)
            addObserver(assetCacheManager)
        }
    }

    private fun startNavigation() {
        with(navController) {
            graph = navInflater.inflate(R.navigation.main_navigation).apply {
                startDestination = getStartDestinationFragmentId()
            }
            binding.bottomNavigationView.setupWithNavController(this)
        }
    }

    private fun getStartDestinationFragmentId(): Int {
        return if (accountManager.isThereAnyRegisteredAccount() || sharedPref.getRegisterSkip()) {
            R.id.lockFragment
        } else {
            R.id.loginNavigation
        }
    }

    private fun handleStatusBarChanges(statusBarConfiguration: StatusBarConfiguration) {
        val intendedStatusBarColor =
            if (statusBarConfiguration.showNodeStatus && isConnectedToTestNet) {
                R.color.testnet
            } else {
                statusBarConfiguration.backgroundColor
            }

        window?.statusBarColor = ContextCompat.getColor(this, intendedStatusBarColor)
    }

    private fun handleStatusBarIconColorChanges(
        oldStatusBarConfiguration: StatusBarConfiguration,
        newStatusBarConfiguration: StatusBarConfiguration
    ) {
        if (oldStatusBarConfiguration.showLightStatusBarIcons != newStatusBarConfiguration.showLightStatusBarIcons) {
            if (newStatusBarConfiguration.showLightStatusBarIcons) {
                showLightStatusBarIcons()
            } else {
                showDarkStatusBarIcons()
            }
        }
    }

    fun checkIfConnectedToTestNet() {
        isConnectedToTestNet = indexerInterceptor.currentActiveNode?.networkSlug == TESTNET_NETWORK_SLUG ||
            indexerInterceptor.currentActiveNode?.networkSlug == BETANET_NETWORK_SLUG
    }

    fun navBack() {
        navController.navigateUp()
    }

    fun nav(directions: NavDirections, onError: (() -> Unit)? = null) {
        navController.navigateSafe(directions, onError)
    }

    fun setBottomNavigationBarSelectedItem(@IdRes itemRes: Int) {
        binding.bottomNavigationView.selectedItemId = itemRes
    }

    fun getToolbar(): CustomToolbar {
        return binding.toolbar
    }

    fun showGlobalError(errorMessage: CharSequence?, title: String? = null) {
        val safeTitle = title ?: getString(R.string.error_default_title)
        val safeErrorMessage = errorMessage ?: getString(R.string.unknown_error)
        binding.slidingTopErrorView?.addErrorMessage(safeTitle, safeErrorMessage)
    }

    fun showForegroundNotification(notificationMetadata: NotificationMetadata) {
        binding.foregroundNotificationView?.addNotification(notificationMetadata)
    }

    fun showProgress() {
        binding.progressBar.root.show()
    }

    fun hideProgress() {
        binding.progressBar.root.hide()
    }

    override fun onSaveInstanceState(outState: Bundle, outPersistentState: PersistableBundle) {
        outState.putBoolean(IS_BOTTOM_BAR_VISIBLE_KEY, isBottomBarNavigationVisible)
        super.onSaveInstanceState(outState, outPersistentState)
    }

    companion object {
        private const val IS_BOTTOM_BAR_VISIBLE_KEY = "is_bottom_bar_visible"
    }
}
