/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.pinentry.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.ui.password.BasePasswordFragment
import com.algorand.android.ui.password.model.PasswordScreenType
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.showBiometricAuthentication
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WebExportPasswordFragment : BasePasswordFragment() {

    override val titleResId: Int = R.string.enter_your_six_digit_pin

    override val screenType: PasswordScreenType = PasswordScreenType.VerificationScreenType(
        navigationResultKey = WEB_EXPORT_PASSWORD_RESULT_KEY
    )

    private val webExportPasswordViewModel: WebExportPasswordViewModel by viewModels()

    private val webExportPasswordPreviewCollector: suspend (Event<Unit>?) -> Unit =
        {
            it?.consume()?.run {
                activity?.showBiometricAuthentication(
                    getString(R.string.app_name),
                    getString(R.string.please_scan_your_fingerprint_or),
                    getString(R.string.cancel),
                    successCallback = { handleNextNavigation() }
                )
            }
        }

    override fun handleNextNavigation() {
        nav(
            WebExportPasswordFragmentDirections
                .actionWebExportPasswordFragmentToWebExportAccountConfirmationFragment(
                    backupId = webExportPasswordViewModel.backupId,
                    encryptionKey = webExportPasswordViewModel.encryptionKey,
                    modificationKey = webExportPasswordViewModel.modificationKey,
                    accountList = webExportPasswordViewModel.accountList
                )
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            webExportPasswordViewModel.webExportPasswordPreviewFlow
                .map { it.navigateToShowBiometricAuthenticationEvent }
                .distinctUntilChanged(),
            webExportPasswordPreviewCollector
        )
    }

    companion object {
        const val WEB_EXPORT_PASSWORD_RESULT_KEY = "web_export_password_result"
    }
}
