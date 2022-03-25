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

package com.algorand.android.ui.settings

import android.app.NotificationManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.BuildConfig
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseBottomBarFragment
import com.algorand.android.databinding.FragmentSettingsBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet.Companion.WARNING_CONFIRMATION_KEY
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openSupportCenterUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.preference.isRewardsActivated
import com.algorand.android.utils.preference.setRewardsPreference
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class SettingsFragment : BaseBottomBarFragment(R.layout.fragment_settings) {

    @Inject
    lateinit var aead: Aead

    @Inject
    lateinit var gson: Gson

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val settingsViewModel: SettingsViewModel by viewModels()

    private val binding by viewBinding(FragmentSettingsBinding::bind)

    override val fragmentConfiguration = FragmentConfiguration(
        isBottomBarNeeded = true
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initDialogSavedStateListener()
        with(binding) {
            securityListItem.setOnClickListener { onSecurityClick() }
            notificationListItem.setOnClickListener { onNotificationClick() }
            walletConnectListItem.setOnClickListener { onWalletConnectSessionsClick() }
            rewardsSwitch.isChecked = sharedPref.isRewardsActivated()
            initSwitchChangeListeners()
            languageListItem.setOnClickListener { onLanguageClick() }
            currencyListItem.setOnClickListener { onCurrencyClick() }
            themeListItem.setOnClickListener { onThemeClick() }
            supportCenterListItem.setOnClickListener { onSupportCenterClick() }
            rateListItem.setOnClickListener { onRateClick() }
            termsAndServicesListItem.setOnClickListener { onTermsAndServicesClick() }
            privacyPolicyListItem.setOnClickListener { onPrivacyPolicyClick() }
            developerListItem.setOnClickListener { onDeveloperSettingsClick() }
            logoutButton.setOnClickListener { onLogoutClick() }
            versionCodeTextView.text = getString(R.string.version_format, BuildConfig.VERSION_NAME)
        }
    }

    private fun onSupportCenterClick() {
        context?.openSupportCenterUrl()
    }

    private fun onSecurityClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToSecurityFragment())
    }

    private fun initSwitchChangeListeners() {
        binding.rewardsSwitch.setOnCheckedChangeListener { _, isChecked ->
            sharedPref.setRewardsPreference(isChecked)
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.settingsFragment) {
            useSavedStateValue<Boolean>(WARNING_CONFIRMATION_KEY) {
                settingsViewModel.deleteAllData(
                    context?.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager,
                    ::onDeleteAllDataCompleted
                )
            }
        }
    }

    private fun onDeleteAllDataCompleted() {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleAnnotatedString = AnnotatedString(R.string.your_data_has_been),
                drawableResId = R.drawable.ic_check_72dp
            )
        )
    }

    private fun onDeveloperSettingsClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToDeveloperSettingsFragment())
    }

    private fun onCurrencyClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToCurrencySelectionFragment())
    }

    private fun onLanguageClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToLanguageSelectionFragment())
    }

    private fun onThemeClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToThemeSelectionFragment())
    }

    private fun onNotificationClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToNotificationSettingsFragment(showDoneButton = false))
    }

    private fun onRateClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToRateExperienceBottomSheet())
    }

    private fun onWalletConnectSessionsClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToWalletConnectSessionsFragment())
    }

    private fun onLogoutClick() {
        val warningConfirmation = WarningConfirmation(
            titleRes = R.string.delete_all_data,
            descriptionRes = R.string.you_are_about_to_delete,
            drawableRes = R.drawable.ic_trash,
            positiveButtonTextRes = R.string.yes_remove_all_accounts,
            negativeButtonTextRes = R.string.keep_it
        )
        nav(SettingsFragmentDirections.actionSettingsFragmentToWarningConfirmationNavigation(warningConfirmation))
    }

    private fun onTermsAndServicesClick() {
        context?.openTermsAndServicesUrl()
    }

    private fun onPrivacyPolicyClick() {
        context?.openPrivacyPolicyUrl()
    }
}
