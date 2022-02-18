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

package com.algorand.android.utils

import android.content.Context
import androidx.biometric.BiometricConstants.ERROR_CANCELED
import androidx.biometric.BiometricConstants.ERROR_HW_NOT_PRESENT
import androidx.biometric.BiometricConstants.ERROR_HW_UNAVAILABLE
import androidx.biometric.BiometricConstants.ERROR_LOCKOUT_PERMANENT
import androidx.biometric.BiometricConstants.ERROR_NEGATIVE_BUTTON
import androidx.biometric.BiometricConstants.ERROR_NO_BIOMETRICS
import androidx.biometric.BiometricConstants.ERROR_UNABLE_TO_PROCESS
import androidx.biometric.BiometricConstants.ERROR_USER_CANCELED
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.BIOMETRIC_SUCCESS
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import com.google.firebase.crashlytics.FirebaseCrashlytics

fun Context.isBiometricAvailable(): Boolean {
    return BiometricManager.from(this).canAuthenticate() == BIOMETRIC_SUCCESS
}

fun FragmentActivity.showBiometricAuthentication(
    titleText: String,
    descriptionText: String,
    negativeButtonText: String,
    successCallback: () -> Unit,
    failCallBack: (() -> Unit)? = null,
    hardwareErrorCallback: (() -> Unit)? = null
) {
    if (BiometricManager.from(this).canAuthenticate() == BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE) {
        hardwareErrorCallback?.invoke()
        return
    }

    val biometricExecutor = { command: Runnable ->
        try {
            command.run()
        } catch (exception: Exception) {
            FirebaseCrashlytics.getInstance().recordException(exception)
            exception.printStackTrace()
        }
    }

    val biometricAuthenticationCallback = object : BiometricPrompt.AuthenticationCallback() {
        @Suppress("ComplexCondition")
        override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
            if (errorCode == ERROR_HW_NOT_PRESENT ||
                errorCode == ERROR_HW_UNAVAILABLE ||
                errorCode == ERROR_LOCKOUT_PERMANENT ||
                errorCode == ERROR_CANCELED ||
                errorCode == ERROR_UNABLE_TO_PROCESS ||
                errorCode == ERROR_NO_BIOMETRICS ||
                errorCode == ERROR_NEGATIVE_BUTTON ||
                errorCode == ERROR_USER_CANCELED
            ) {
                hardwareErrorCallback?.invoke()
            }
        }

        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            super.onAuthenticationSucceeded(result)
            successCallback.invoke()
        }

        override fun onAuthenticationFailed() {
            super.onAuthenticationFailed()
            failCallBack?.invoke()
        }
    }

    val biometricPromptInfo by lazy {
        BiometricPrompt.PromptInfo.Builder()
            .setTitle(titleText)
            .setDescription(descriptionText)
            .setNegativeButtonText(negativeButtonText)
            .build()
    }

    try {
        BiometricPrompt(this, biometricExecutor, biometricAuthenticationCallback).authenticate(biometricPromptInfo)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        exception.printStackTrace()
    }
}
