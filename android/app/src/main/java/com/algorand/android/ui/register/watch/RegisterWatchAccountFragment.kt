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

package com.algorand.android.ui.register.watch

import android.os.Bundle
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import com.algorand.android.MainNavigationDirections
import com.algorand.android.MainViewModel
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterWatchAccountBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.utils.SingleButtonBottomSheet.Companion.ACCEPT_KEY
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RegisterWatchAccountFragment : DaggerBaseFragment(R.layout.fragment_register_watch_account) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.create_a_watch,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::onBackClick
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val registerWatchAccountViewModel: RegisterWatchAccountViewModel by viewModels()

    private val mainViewModel: MainViewModel by activityViewModels()

    private val binding by viewBinding(FragmentRegisterWatchAccountBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initSavedStateListeners()
        binding.scanQrButton.setOnClickListener { onScanQrClick() }
        binding.confirmationButton.setOnClickListener { onNextClick() }
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.registerWatchAccountFragment) {
            useSavedStateValue<Boolean>(ACCEPT_KEY) {
                nav(RegisterWatchAccountFragmentDirections.actionGlobalToHomeNavigation())
            }
            useSavedStateValue<DecodedQrCode>(QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    binding.addressEditText.setText(decodedQrCode.address)
                }
            }
        }
    }

    private fun onNextClick() {
        val enteredAddress = binding.addressEditText.text.toString()
        if (enteredAddress.isValidAddress()) {
            if (registerWatchAccountViewModel.isThereAccountWithAddress(enteredAddress).not()) {
                val newWatchAccount = Account.create(enteredAddress, Account.Detail.Watch)
                mainViewModel.addAccount(newWatchAccount, CreationType.WATCH)
                showAccountAddedBottomSheet()
            } else {
                context?.showAlertDialog(getString(R.string.error), getString(R.string.this_account_already_exists))
            }
        } else {
            context?.showAlertDialog(getString(R.string.error), getString(R.string.entered_address_is_not_valid))
        }
    }

    private fun showAccountAddedBottomSheet() {
        nav(
            MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                titleResId = R.string.account_verified,
                drawableResId = R.drawable.ic_check_sign,
                descriptionAnnotatedString = AnnotatedString(R.string.account_verified_message),
                buttonTextResId = R.string.go_to_home,
                isResultNeeded = true
            )
        )
    }

    private fun onScanQrClick() {
        nav(
            RegisterWatchAccountFragmentDirections.actionRegisterWatchAccountFragmentToQrCodeScannerFragment(
                scanReturnType = listOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK).toTypedArray()
            )
        )
    }

    private fun onBackClick() {
        view?.hideKeyboard()
        navBack()
    }
}
