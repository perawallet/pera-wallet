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
import androidx.fragment.app.activityViewModels
import androidx.navigation.navGraphViewModels
import com.algorand.android.LoginNavigationDirections.Companion.actionGlobalToHomeNavigation
import com.algorand.android.MainViewModel
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNameRegistrationBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showKeyboard
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class NameRegistrationFragment : DaggerBaseFragment(R.layout.fragment_name_registration) {

    @Inject
    lateinit var accountManager: AccountManager

    private val loginNavigationViewModel: LoginNavigationViewModel by navGraphViewModels(R.id.loginNavigation) {
        defaultViewModelProviderFactory
    }

    private val mainViewModel: MainViewModel by activityViewModels()

    private val binding by viewBinding(FragmentNameRegistrationBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.name_your_account,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.nextButton.setOnClickListener { onNextButtonClick() }
        binding.nameEditText.apply {
            post {
                requestFocus()
                showKeyboard()
            }
        }
    }

    private fun onNextButtonClick() {
        binding.nextButton.setOnClickListener(null)
        loginNavigationViewModel.tempAccount?.let { registeredAccount ->
            if (accountManager.isThereAnyAccountWithPublicKey(registeredAccount.address).not()) {
                var accountName = binding.nameEditText.text.toString()
                if (accountName.isBlank()) {
                    accountName = registeredAccount.address.toShortenedAddress()
                }
                registeredAccount.name = accountName
                mainViewModel.addAccount(registeredAccount, loginNavigationViewModel.creationType)
                nav(actionGlobalToHomeNavigation())
            } else {
                context?.showAlertDialog(getString(R.string.error), getString(R.string.this_account_already_exists))
            }
        }
    }
}
