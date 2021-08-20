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

package com.algorand.android.ui.register

import android.os.Bundle
import android.view.View
import androidx.navigation.navGraphViewModels
import com.algorand.algosdk.mobile.Mobile
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentBackupPassphraseBinding
import com.algorand.android.models.Account
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.BackupPassphraseFragmentDirections.Companion.actionBackupPassphraseToPassphraseQuestion
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.disableScreenCapture
import com.algorand.android.utils.enableScreenCapture
import com.algorand.android.utils.setupMnemonic
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BackupPassphraseFragment : DaggerBaseFragment(R.layout.fragment_backup_passphrase) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        backgroundColor = R.color.tertiaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    private val loginNavigationViewModel: LoginNavigationViewModel by navGraphViewModels(R.id.loginNavigation) {
        defaultViewModelProviderFactory
    }

    private val binding by viewBinding(FragmentBackupPassphraseBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupPassphrase()
        binding.nextButton.setOnClickListener { onNextClick() }
    }

    override fun onResume() {
        super.onResume()
        activity?.disableScreenCapture()
    }

    override fun onPause() {
        super.onPause()
        activity?.enableScreenCapture()
    }

    private fun getMnemonicString(): String? {
        try {
            val secretKeyByteArray: ByteArray?
            if (loginNavigationViewModel.tempAccount == null ||
                loginNavigationViewModel.tempAccount?.getSecretKey() == null
            ) {
                secretKeyByteArray = Mobile.generateSK()
                val publicKey = Mobile.generateAddressFromSK(secretKeyByteArray)
                val tempAccount = Account.create(publicKey, Account.Detail.Standard(secretKeyByteArray))
                loginNavigationViewModel.setTempAccount(tempAccount, CreationType.CREATE)
            } else {
                secretKeyByteArray = loginNavigationViewModel.tempAccount?.getSecretKey()
            }
            return Mobile.mnemonicFromPrivateKey(secretKeyByteArray)
        } catch (exception: Exception) {
            navBack()
        }
        return null
    }

    private fun setupPassphrase() {
        getMnemonicString()?.let { mnemonicString ->
            setupMnemonic(mnemonicString, binding.passphraseLeftColumnTextView, binding.passphraseRightColumnTextView)
        }
    }

    private fun onNextClick() {
        nav(actionBackupPassphraseToPassphraseQuestion())
    }
}
