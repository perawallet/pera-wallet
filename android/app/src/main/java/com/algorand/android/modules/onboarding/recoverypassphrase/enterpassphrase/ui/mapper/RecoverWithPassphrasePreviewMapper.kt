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

package com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.ui.mapper

import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.ui.model.RecoverWithPassphrasePreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class RecoverWithPassphrasePreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToRecoverWithPassphrasePreview(
        passphraseInputGroupConfiguration: PassphraseInputGroupConfiguration,
        suggestedWords: List<String>,
        isRecoveryEnabled: Boolean,
        showLoadingDialogEvent: Event<Unit>? = null,
        onRestorePassphraseInputGroupEvent: Event<PassphraseInputGroupConfiguration>? = null,
        onDisplayWrongMnemonicEvent: Event<AnnotatedString>? = null,
        navToImportRekeyedAccountEvent: Event<Pair<AccountCreation, List<String>>>? = null,
        onAccountNotFoundEvent: Event<AnnotatedString>? = null,
        navToNameRegistrationEvent: Event<AccountCreation>? = null,
        onGlobalErrorEvent: Event<Int>? = null,
        showErrorEvent: Event<AnnotatedString>? = null
    ): RecoverWithPassphrasePreview {
        return RecoverWithPassphrasePreview(
            passphraseInputGroupConfiguration = passphraseInputGroupConfiguration,
            suggestedWords = suggestedWords,
            isRecoveryEnabled = isRecoveryEnabled,
            showLoadingDialogEvent = showLoadingDialogEvent,
            onRestorePassphraseInputGroupEvent = onRestorePassphraseInputGroupEvent,
            onDisplayWrongMnemonicEvent = onDisplayWrongMnemonicEvent,
            onAccountNotFoundEvent = onAccountNotFoundEvent,
            navToNameRegistrationEvent = navToNameRegistrationEvent,
            navToImportRekeyedAccountEvent = navToImportRekeyedAccountEvent,
            onGlobalErrorEvent = onGlobalErrorEvent,
            showErrorEvent = showErrorEvent
        )
    }
}
