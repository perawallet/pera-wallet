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

package com.algorand.android.ui.password

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.FragmentBasePasswordBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.password.model.PasswordScreenType
import com.algorand.android.utils.extensions.invisible
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

abstract class BasePasswordFragment : DaggerBaseFragment(R.layout.fragment_base_password) {

    protected abstract val titleResId: Int

    protected abstract val screenType: PasswordScreenType

    protected val binding by viewBinding(FragmentBasePasswordBinding::bind)

    private val lockPasswordViewModel: LockPasswordViewModel by viewModels()

    // If the screen type is ReEnterScreenType, we keep the first entered password here to check the re-entered password
    private var previousPassword by Delegates.observable<String?>(null) { _, _, newValue ->
        binding.passwordView.clear()
        if (newValue != null) {
            (screenType as? PasswordScreenType.ReEnterScreenType)?.apply {
                binding.headlineTextView.setText(nextScreenTitleResId)
            }
        } else {
            binding.headlineTextView.setText(titleResId)
        }
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() = onBackPressed()
    }

    private val toolbarConfiguration = ToolbarConfiguration(
        backgroundColor = R.color.primary_background,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.passwordView.onNewDigit(number)
        }

        override fun onBackspaceClick() {
            binding.passwordView.removeLastDigit()
        }
    }

    private val passwordViewListener = object : SixDigitPasswordView.Listener {
        override fun onPinCodeCompleted(pinCode: String) {
            when (screenType) {
                is PasswordScreenType.VerificationScreenType -> verifyPinCode(pinCode)
                is PasswordScreenType.ReEnterScreenType -> {
                    if (previousPassword == null) previousPassword = pinCode else verifyWithPreviousPinCode(pinCode)
                }
            }
        }

        override fun onNewPinAdded() {
            binding.passwordDidNotMatchTextView.invisible()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        previousPassword = null
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            dialpadView.setDialPadListener(dialPadListener)
            passwordView.setListener(passwordViewListener)
        }
    }

    override fun onPause() {
        binding.passwordView.cancelAnimations()
        super.onPause()
    }

    private fun verifyPinCode(pinCode: String) {
        if (lockPasswordViewModel.getPin() == pinCode) {
            screenType.navigationResultKey?.let { key -> setNavigationResult(key, true) }
            navBack()
        } else {
            binding.passwordView.clearWithAnimation()
            showPasswordDidNotMatchError()
        }
    }

    private fun verifyWithPreviousPinCode(pinCode: String) {
        if (previousPassword == pinCode) {
            lockPasswordViewModel.savePin(pin = pinCode)
            handleNextNavigation()
        } else {
            showPasswordDidNotMatchError()
        }
    }

    protected open fun handleNextNavigation() {
        screenType.navigationResultKey?.let { key -> setNavigationResult(key, true) }
        navBack()
    }

    private fun showPasswordDidNotMatchError() {
        with(binding) {
            passwordView.clearWithAnimation()
            passwordDidNotMatchTextView.show()
        }
    }

    protected open fun onBackPressed() {
        if (previousPassword != null) {
            previousPassword = null
            with(binding) {
                passwordView.clear()
                passwordDidNotMatchTextView.invisible()
            }
        } else {
            navBack()
        }
    }
}
