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

package com.algorand.android.modules.inapppin.pin.ui

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.view.isGone
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.InAppPinNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.FragmentInAppPinBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.inapppin.deletealldata.ui.DeleteAllDataConfirmationBottomSheet.Companion.DELETE_ALL_DATA_CONFIRMATION_KEY
import com.algorand.android.ui.splash.LauncherActivity
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.setFragmentNavigationResult
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class InAppPinFragment : BaseFragment(R.layout.fragment_in_app_pin) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val inAppPinViewModel by viewModels<InAppPinViewModel>()

    private val binding by viewBinding(FragmentInAppPinBinding::bind)

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            activity?.finish()
        }
    }

    private val sixDigitPasswordViewListener = object : SixDigitPasswordView.Listener {
        override fun onPinCodeCompleted(pinCode: String) {
            inAppPinViewModel.onPinCodeEntered(pinCode)
        }
    }

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.pinEntryLayout.sixDigitPasswordView.onNewDigit(number)
        }

        override fun onBackspaceClick() {
            binding.pinEntryLayout.sixDigitPasswordView.removeLastDigit()
        }
    }

    private val backPressDispatchersStateCollector: suspend (Boolean?) -> Unit = { isEnabled ->
        onBackPressedCallback.isEnabled = isEnabled == true
    }

    private val restartActivityEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { onRestartActivity() }
    }

    private val removeAllDataEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToDeleteAllDataConfirmationBottomSheet() }
    }

    private val popInAppPinNavigationEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { popInAppPinNavigationUp() }
    }

    private val askBiometricAuthEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { askBiometricAuth() }
    }

    private val onPinCodeIncorrectEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { binding.pinEntryLayout.sixDigitPasswordView.clearWithAnimation() }
    }

    private val penaltyTimeStartEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { inAppPinViewModel.onStartPenaltyTime() }
    }

    private val pinPenaltyPreviewVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.pinPenaltyLayout.root.isVisible = isVisible == true
        binding.pinEntryLayout.root.isGone = isVisible == true
    }

    private val pinEntryPreviewVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.pinEntryLayout.root.isVisible = isVisible == true
        binding.pinPenaltyLayout.root.isGone = isVisible == true
    }

    private val formattedRemainingPenaltyTimeCollector: suspend (String?) -> Unit = { formattedTime ->
        binding.pinPenaltyLayout.remainingTimeTextView.text = formattedTime
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        initObservers()
        initUi()
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(DELETE_ALL_DATA_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) inAppPinViewModel.onDeletionOfAllDataConfirmed()
        }
    }

    private fun initUi() {
        initPinPenaltyPreviewLayout()
        initPinEntryPreviewLayout()
    }

    private fun initObservers() {
        with(inAppPinViewModel.inAppPinPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.isBackPressDispatchersEnabled },
                collection = backPressDispatchersStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isPinEntryPreviewVisible },
                collection = pinEntryPreviewVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinEntryPreview?.askBiometricAuthEvent },
                collection = askBiometricAuthEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinEntryPreview?.popInAppPinNavigationEvent },
                collection = popInAppPinNavigationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinEntryPreview?.onPinCodeIncorrectEvent },
                collection = onPinCodeIncorrectEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinEntryPreview?.onStartPenaltyTimeEvent },
                collection = penaltyTimeStartEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isPinPenaltyPreviewVisible },
                collection = pinPenaltyPreviewVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinPenaltyPreview?.formattedRemainingPenaltyTime },
                collection = formattedRemainingPenaltyTimeCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinPenaltyPreview?.removeAllDataEvent },
                collection = removeAllDataEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.pinPenaltyPreview?.restartActivityEvent },
                collection = restartActivityEventCollector
            )
        }
    }

    private fun initPinPenaltyPreviewLayout() {
        binding.pinPenaltyLayout.deleteAllDataButton.setOnClickListener {
            inAppPinViewModel.onRemoveAllDataClick()
        }
    }

    private fun initPinEntryPreviewLayout() {
        with(binding.pinEntryLayout) {
            sixDigitPasswordView.setListener(sixDigitPasswordViewListener)
            dialPadView.setDialPadListener(dialPadListener)
        }
    }

    private fun popInAppPinNavigationUp() {
        setFragmentNavigationResult(IN_APP_PIN_CONFIRMATION_KEY, true)
        nav(InAppPinNavigationDirections.actionInAppPinNavigationPop())
    }

    private fun askBiometricAuth() {
        activity?.showBiometricAuthentication(
            titleText = getString(R.string.app_name),
            descriptionText = getString(R.string.please_scan_your_fingerprint_or),
            negativeButtonText = getString(R.string.cancel),
            successCallback = { inAppPinViewModel.onBiometricAuthSucceed() }
        )
    }

    private fun onRestartActivity() {
        with(activity ?: return) {
            startActivity(LauncherActivity.newIntent(this))
            finishAffinity()
        }
    }

    private fun navToDeleteAllDataConfirmationBottomSheet() {
        nav(InAppPinFragmentDirections.actionInAppPinFragmentToDeleteAllDataConfirmationBottomSheet())
    }

    companion object {
        const val IN_APP_PIN_CONFIRMATION_KEY = "inAppPinConfirmationKey"
    }
}
