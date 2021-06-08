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

package com.algorand.android.ui.accounts

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.DialogViewPassphraseBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.disableScreenCapture
import com.algorand.android.utils.enableScreenCapture
import com.algorand.android.utils.setupMnemonic
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import mnemonic.Mnemonic

@AndroidEntryPoint
class ViewPassphraseBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.dialog_view_passphrase,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    @Inject
    lateinit var accountManager: AccountManager

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.view_passphrase,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private val binding by viewBinding(DialogViewPassphraseBinding::bind)

    private val args: ViewPassphraseBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.viewPassphraseToolbar.configure(toolbarConfiguration)
        setupPassphraseLayout()
    }

    private fun setupPassphraseLayout() {
        accountManager.getAccount(args.accountPublicKey)?.getSecretKey()?.let {
            try {
                val mnemonic = Mnemonic.fromPrivateKey(it) ?: throw Exception("Mnemonic cannot be null.")
                setupMnemonic(mnemonic, binding.passphraseLeftColumnTextView, binding.passphraseRightColumnTextView)
            } catch (exception: Exception) {
                navBack()
            }
        } ?: run { navBack() }
    }

    override fun onResume() {
        super.onResume()
        activity?.disableScreenCapture()
    }

    override fun onPause() {
        super.onPause()
        activity?.enableScreenCapture()
    }
}
