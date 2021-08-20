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

package com.algorand.android.ui.settings

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.BuildConfig
import com.algorand.android.R
import com.algorand.android.core.BaseActivity
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.FragmentSettingsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet.Companion.WARNING_CONFIRMATION_KEY
import com.algorand.android.ui.settings.SettingsFragmentDirections.Companion.actionSettingsFragmentToChangePasswordFragment
import com.algorand.android.ui.settings.SettingsFragmentDirections.Companion.actionSettingsFragmentToWarningConfirmationBottomSheet
import com.algorand.android.utils.openApplicationPageOnStore
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openSupportCenterUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.preference.isBiometricActive
import com.algorand.android.utils.preference.isRewardsActivated
import com.algorand.android.utils.preference.setBiometricRegistrationPreference
import com.algorand.android.utils.preference.setRewardsPreference
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class SettingsFragment : DaggerBaseFragment(R.layout.fragment_settings) {

    @Inject
    lateinit var aead: Aead

    @Inject
    lateinit var gson: Gson

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val settingsViewModel: SettingsViewModel by viewModels()

    private val binding by viewBinding(FragmentSettingsBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.settings,
        type = CustomToolbar.Type.TAB_TOOLBAR
    )

    override val fragmentConfiguration = FragmentConfiguration(
        isBottomBarNeeded = true, toolbarConfiguration = toolbarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initDialogSavedStateListener()
        with(binding) {
            biometricSwitch.isChecked = sharedPref.isBiometricActive()
            rewardsSwitch.isChecked = sharedPref.isRewardsActivated()
            initSwitchChangeListeners()
            notificationListItem.setOnClickListener { onNotificationClick() }
            themeListItem.setOnClickListener { onThemeClick() }
            currencyListItem.setOnClickListener { onCurrencyClick() }
            languageListItem.setOnClickListener { onLanguageClick() }
            developerListItem.setOnClickListener { onDeveloperSettingsClick() }
            supportCenterListItem.setOnClickListener { onSupportCenterClick() }
            changePasswordListItem.setOnClickListener { onChangePasswordClick() }
            termsAndServicesListItem.setOnClickListener { onTermsAndServicesClick() }
            privacyPolicyListItem.setOnClickListener { onPrivacyPolicyClick() }
            walletConnectListItem.setOnClickListener { onWalletConnectSessionsClick() }
            rateListItem.setOnClickListener { onRateClick() }
            logoutButton.setOnClickListener { onLogoutClick() }
            versionCodeTextView.text = getString(R.string.version_format, BuildConfig.VERSION_NAME)
        }
    }

    override fun onResume() {
        super.onResume()
        setLanguage()
        setCurrency()
        setTheme()
    }

    private fun setLanguage() {
        val currentLang = (activity as BaseActivity).getCurrentLanguage()
        val displayLang = currentLang.getDisplayLanguage(currentLang).capitalize()
        binding.languageListItem.setSecondaryTextView(displayLang)
    }

    private fun setCurrency() {
        binding.currencyListItem.setSecondaryTextView(settingsViewModel.getCurrencyPreference())
    }

    private fun setTheme() {
        binding.themeListItem.setSecondaryTextView(
            resources.getString(settingsViewModel.getThemePreference().visibleNameResId)
        )
    }

    private fun initSwitchChangeListeners() {
        binding.biometricSwitch.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                sharedPref.setBiometricRegistrationPreference(isChecked)
            } else {
                checkBiometricAuthentication()
            }
        }
        binding.rewardsSwitch.setOnCheckedChangeListener { _, isChecked ->
            sharedPref.setRewardsPreference(isChecked)
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.settingsFragment) {
            useSavedStateValue<Boolean>(WARNING_CONFIRMATION_KEY) {
                settingsViewModel.resetAllData(context)
            }
        }
    }

    private fun onSupportCenterClick() {
        context?.openSupportCenterUrl()
    }

    private fun checkBiometricAuthentication() {
        activity?.showBiometricAuthentication(
            getString(R.string.app_name),
            getString(R.string.please_scan_your_fingerprint_or),
            getString(R.string.cancel),
            successCallback = { sharedPref.setBiometricRegistrationPreference(true) }
        )
    }

    private fun onDeveloperSettingsClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToDeveloperSettingsFragment())
    }

    private fun onChangePasswordClick() {
        nav(actionSettingsFragmentToChangePasswordFragment())
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
        nav(SettingsFragmentDirections.actionSettingsFragmentToNotificationFilterFragment(showDoneButton = false))
    }

    private fun onRateClick() {
        context?.openApplicationPageOnStore()
    }

    private fun onWalletConnectSessionsClick() {
        nav(SettingsFragmentDirections.actionSettingsFragmentToWalletConnectSessionsFragment())
    }

    private fun onLogoutClick() {
        nav(
            actionSettingsFragmentToWarningConfirmationBottomSheet(
                titleTextResId = R.string.delete_all_data,
                descriptionTextResId = R.string.are_you_sure,
                drawableResId = R.drawable.ic_trash,
                positiveButtonTextResId = R.string.delete,
                negativeButtonTextResId = R.string.keep_it
            )
        )
    }

    private fun onTermsAndServicesClick() {
        context?.openTermsAndServicesUrl()
    }

    private fun onPrivacyPolicyClick() {
        context?.openPrivacyPolicyUrl()
    }
}
