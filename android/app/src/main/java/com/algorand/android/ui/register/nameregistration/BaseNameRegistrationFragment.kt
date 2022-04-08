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

package com.algorand.android.ui.register.nameregistration

import android.os.Bundle
import android.view.View
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import com.algorand.android.MainViewModel
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNameRegistrationBinding
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.removeKeyboardToggleListener
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showKeyboard
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseNameRegistrationFragment : DaggerBaseFragment(R.layout.fragment_name_registration) {

    private val mainViewModel: MainViewModel by activityViewModels()
    private val nameRegistrationViewModel: NameRegistrationViewModel by viewModels()

    private val binding by viewBinding(FragmentNameRegistrationBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private var keyboardToggleListener: KeyboardToggleListener? = null

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val onKeyboardToggleAction: (shown: Boolean) -> Unit = { keyboardShown ->
        if (keyboardShown) {
            with(binding) {
                scrollView.smoothScrollTo(0, (nameInputLayout.y - nameInputLayout.height).toInt())
            }
        }
    }

    abstract val accountCreation: AccountCreation?
    abstract fun navToNextFragment()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            nextButton.setOnClickListener { onNextButtonClick() }
            nameInputLayout.apply {
                text = nameRegistrationViewModel.accountPublicKey.toShortenedAddress()
                addTrailingIcon(drawableRes = R.drawable.ic_close, onIconClick = { text = "" })
                post {
                    requestFocus()
                    showKeyboard()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        keyboardToggleListener = addKeyboardToggleListener(binding.root, onKeyboardToggleAction)
    }

    override fun onPause() {
        super.onPause()
        view?.hideKeyboard()
        keyboardToggleListener?.removeKeyboardToggleListener(binding.root)
    }

    private fun onNextButtonClick() {
        binding.nextButton.setOnClickListener(null)
        accountCreation?.tempAccount?.let { registeredAccount ->
            if (nameRegistrationViewModel.isThereAnyAccountWithThisPublicKey(registeredAccount.address).not()) {
                registeredAccount.name = binding.nameInputLayout.text.ifBlank {
                    registeredAccount.address.toShortenedAddress()
                }
                mainViewModel.addAccount(registeredAccount, accountCreation?.creationType)
                navToNextFragment()
            } else {
                context?.showAlertDialog(getString(R.string.error), getString(R.string.this_account_already_exists))
            }
        }
    }
}
