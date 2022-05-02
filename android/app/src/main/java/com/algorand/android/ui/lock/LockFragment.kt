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

package com.algorand.android.ui.lock

import android.app.NotificationManager
import android.content.Context
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.databinding.FragmentLockBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet.Companion.WARNING_CONFIRMATION_KEY
import com.algorand.android.ui.splash.LauncherActivity
import com.algorand.android.utils.finishAffinityFromFragment
import com.algorand.android.utils.getNavigationBackStackCount
import com.algorand.android.utils.getTimeAsMinSecondPair
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LockFragment : DaggerBaseFragment(R.layout.fragment_lock) {

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiary_background)

    override val fragmentConfiguration = FragmentConfiguration(statusBarConfiguration = statusBarConfiguration)

    private val lockViewModel: LockViewModel by viewModels()

    private val binding by viewBinding(FragmentLockBinding::bind)

    private var countDownTimer: CountDownTimer? = null

    private var lockAttemptCount = 0

    private var penaltyRemainingTime: Long = 0L

    private var biometricHandler: Handler? = null

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.passwordView.onNewDigit(number, onNewDigitAdded = { isNewDigitAdded, isPasswordFilled ->
                if (!isNewDigitAdded) return@onNewDigit
                if (isPasswordFilled) {
                    val givenPassword = binding.passwordView.getPassword()
                    if (lockViewModel.getCurrentPassword() == givenPassword) {
                        onEnteredCorrectPassword()
                    } else {
                        setLockAttemptCount(lockAttemptCount + 1)
                        binding.passwordView.clearWithAnimation()
                    }
                }
            })
        }

        override fun onBackspaceClick() {
            binding.passwordView.removeLastDigit()
        }
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            activity?.finish()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            dialPad.setDialPadListener(dialPadListener)
            deleteAllDataButton.setOnClickListener { onDeleteAllDataClick() }
        }
    }

    override fun onStart() {
        super.onStart()
        if (lockViewModel.isPinCodeEnabled().not()) {
            handleNextNavigation()
        }
    }

    private fun handleNextNavigation() {
        if (activity?.getNavigationBackStackCount() == 0) {
            nav(LockFragmentDirections.actionLockFragmentToHomeNavigation())
        } else {
            navBack()
        }
    }

    override fun onResume() {
        super.onResume()
        initDialogSavedStateListener()
        setRemainingTime(lockViewModel.getLockPenaltyRemainingTime())
        setLockAttemptCount(lockViewModel.getLockAttemptCount())
        showShowBiometricAuthenticationIfNeed()
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.lockFragment) {
            useSavedStateValue<Boolean>(WARNING_CONFIRMATION_KEY) {
                lockAttemptCount = 0
                penaltyRemainingTime = 0L
                lockViewModel.deleteAllData(
                    context?.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager,
                    ::onDeleteAllDataCompleted
                )
            }
        }
    }

    private fun showShowBiometricAuthenticationIfNeed() {
        if (lockViewModel.shouldShowBiometricDialog()) {
            biometricHandler = Handler()
            biometricHandler?.post {
                activity?.showBiometricAuthentication(
                    getString(R.string.app_name),
                    getString(R.string.please_scan_your_fingerprint_or),
                    getString(R.string.cancel),
                    successCallback = { onEnteredCorrectPassword() }
                )
            }
        }
    }

    private fun setLockAttemptCount(newLockAttemptCount: Int) {
        if (lockAttemptCount != newLockAttemptCount && newLockAttemptCount != 0 &&
            newLockAttemptCount % PENALTY_PER_ATTEMPT == 0
        ) {
            setRemainingTime((newLockAttemptCount / PENALTY_PER_ATTEMPT) * PENALTY_TIME)
        }
        lockAttemptCount = newLockAttemptCount
    }

    private fun setRemainingTime(newRemainingTime: Long) {
        handleRemainingTime(penaltyRemainingTime, newRemainingTime)
        penaltyRemainingTime = newRemainingTime
    }

    private fun handleRemainingTime(previousRemainingTime: Long, remainingTime: Long) {
        val isPenaltyTimeStartedNow = previousRemainingTime == 0L && remainingTime != 0L

        if (previousRemainingTime != remainingTime) {
            val (minutes, seconds) = remainingTime.getTimeAsMinSecondPair()
            binding.remainingTimeTextView.text = getString(R.string.min_seconds_template, minutes, seconds)
        }

        val isUserComePenaltyFromBackground = remainingTime != 0L && countDownTimer == null
        if (isPenaltyTimeStartedNow || isUserComePenaltyFromBackground) {
            startCountdownTimer(remainingTime)
        }
    }

    override fun onPause() {
        biometricHandler?.removeCallbacksAndMessages(null)
        clearCountDownTimer()
        lockViewModel.setLockAttemptCount(lockAttemptCount)
        lockViewModel.setLockPenaltyRemainingTime(penaltyRemainingTime)
        binding.passwordView.cancelAnimations()
        super.onPause()
    }

    private fun clearCountDownTimer() {
        countDownTimer?.cancel()
        countDownTimer = null
    }

    private fun startCountdownTimer(timeRemaining: Long) {
        countDownTimer = object : CountDownTimer(timeRemaining, TIMER_INTERVAL) {
            override fun onFinish() {
                penaltyRemainingTime = 0
                setupLockUI(isEntryBlocked = false)
            }

            override fun onTick(millisUntilFinished: Long) {
                setRemainingTime(millisUntilFinished)
            }
        }.start()

        setupLockUI(isEntryBlocked = true)
    }

    private fun setupLockUI(isEntryBlocked: Boolean) {
        with(binding) {
            penaltyGroup.isVisible = isEntryBlocked
            passwordGroup.isVisible = !isEntryBlocked
        }
    }

    private fun onDeleteAllDataClick() {
        val warningConfirmation = WarningConfirmation(
            titleRes = R.string.delete_all_data,
            descriptionRes = R.string.you_are_about_to_delete,
            drawableRes = R.drawable.ic_trash,
            positiveButtonTextRes = R.string.yes_remove_all_accounts,
            negativeButtonTextRes = R.string.keep_it
        )
        nav(LockFragmentDirections.actionLockFragmentToWarningConfirmationNavigation(warningConfirmation))
    }

    private fun onDeleteAllDataCompleted() {
        context?.let {
            it.startActivity(LauncherActivity.newIntent(it))
            it.finishAffinityFromFragment()
        }
    }

    private fun onEnteredCorrectPassword() {
        lockAttemptCount = 0
        penaltyRemainingTime = 0
        handleNextNavigation()
    }

    companion object {
        private const val TIMER_INTERVAL = 500L
        private const val PENALTY_PER_ATTEMPT = 5
        private const val PENALTY_TIME = 30000L
    }
}
