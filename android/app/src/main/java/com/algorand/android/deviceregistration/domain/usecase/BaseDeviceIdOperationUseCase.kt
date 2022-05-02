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

package com.algorand.android.deviceregistration.domain.usecase

import com.algorand.android.BuildConfig
import com.algorand.android.core.AccountManager
import java.util.Locale

open class BaseDeviceIdOperationUseCase(private val accountManager: AccountManager) {

    protected fun getAccountPublicKeys(): List<String> {
        return accountManager.getAccounts().map { account -> account.address }
    }

    protected fun getLocaleLanguageCode(): String {
        return Locale.getDefault().language ?: Locale.ENGLISH.language
    }

    protected fun getApplicationName() = BuildConfig.APPLICATION_NAME

    companion object {
        const val PLATFORM_NAME = "android"
        const val REGISTER_DEVICE_FAIL_DELAY = 1500L
    }
}
