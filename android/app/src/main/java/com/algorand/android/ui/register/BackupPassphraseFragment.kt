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

package com.algorand.android.ui.register

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.algosdk.sdk.Sdk
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.databinding.FragmentBackupPassphraseBinding
import com.algorand.android.models.Account
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.BackupPassphraseFragmentDirections.Companion.actionBackupPassphraseFragmentToBackupPassphraseAccountNameNavigation
import com.algorand.android.utils.disableScreenCapture
import com.algorand.android.utils.enableScreenCapture
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BackupPassphraseFragment : DaggerBaseFragment(R.layout.fragment_backup_passphrase) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        backgroundColor = R.color.tertiary_background
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    private val binding by viewBinding(FragmentBackupPassphraseBinding::bind)

    private val backupPassphraseViewModel: BackupPassphraseViewModel by viewModels()

    private val args: BackupPassphraseFragmentArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        customizeToolbar()
        setupPassphrase()
        binding.nextButton.setOnClickListener { onNextClick() }
    }

    private fun customizeToolbar() {
        if (args.accountCreation != null) {
            getAppToolbar()?.setEndButton(button = TextButton(R.string.skip, onClick = ::onSkipClick))
        }
    }

    override fun onResume() {
        super.onResume()
        activity?.disableScreenCapture()
    }

    override fun onStop() {
        super.onStop()
        if (view?.hasWindowFocus() == true) {
            activity?.enableScreenCapture()
        }
    }

    private fun setupPassphrase() {
        val secretKey = (args.accountCreation?.tempAccount?.detail as? Account.Detail.Standard)?.secretKey
            ?: backupPassphraseViewModel.getAccountSecretKey(args.publicKeyOfAccountToBackup)
        secretKey?.let {
            try {
                val mnemonic = Sdk.mnemonicFromPrivateKey(it) ?: throw Exception("Mnemonic cannot be null.")
                binding.passphraseBoxView.setPassphrases(mnemonic)
            } catch (exception: Exception) {
                navBack()
            }
        } ?: run { navBack() }
    }

    private fun onNextClick() {
        navToPassphraseValidaitonFragment()
    }

    private fun onSkipClick() {
        navToBackupPassphraseAccountNameNavigation()
    }

    private fun navToPassphraseValidaitonFragment() {
        backupPassphraseViewModel.logOnboardingNextClickEvent()
        nav(
            BackupPassphraseFragmentDirections.actionBackupPassphraseFragmentToPassphraseValidationFragment(
                args.publicKeyOfAccountToBackup,
                args.accountCreation
            )
        )
    }

    private fun navToBackupPassphraseAccountNameNavigation() {
        backupPassphraseViewModel.logOnboardingNextClickEvent()
        args.accountCreation?.let { accountCreation ->
            nav(actionBackupPassphraseFragmentToBackupPassphraseAccountNameNavigation(accountCreation))
        }
    }
}
