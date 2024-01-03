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

package com.algorand.android.modules.accountdetail.accountstatusdetail.ui.usecase

import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.decider.AccountStatusDetailPreviewDecider
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.mapper.AccountStatusDetailPreviewMapper
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.model.AccountStatusDetailPreview
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountOriginalStateIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.mapNotBlank
import javax.inject.Inject
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest

class AccountStatusDetailPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val createAccountOriginalStateIconDrawableUseCase: CreateAccountOriginalStateIconDrawableUseCase,
    private val accountStatusDetailPreviewMapper: AccountStatusDetailPreviewMapper,
    private val accountStatusDetailPreviewDecider: AccountStatusDetailPreviewDecider,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun getAccountStatusDetailPreviewFlow(accountAddress: String) = channelFlow {
        accountDetailUseCase.getAccountDetailCacheFlow(accountAddress).collectLatest { cachedAccountDetail ->
            val account = cachedAccountDetail?.data?.account
            val authAccountAddress = cachedAccountDetail?.data?.accountInformation?.rekeyAdminAddress
            val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account = account)
            val preview = accountStatusDetailPreviewMapper.mapToAccountStatusDetailPreview(
                titleString = accountStatusDetailPreviewDecider.decideTitleString(account = account),
                accountOriginalTypeDisplayName = accountDisplayNameUseCase.invoke(accountAddress = accountAddress),
                accountOriginalTypeIconDrawablePreview = createAccountOriginalStateIconDrawableUseCase.invoke(
                    accountAddress = accountAddress
                ),
                accountOriginalActionButton = AccountAssetItemButtonState.COPY,
                authAccountDisplayName = authAccountAddress?.mapNotBlank { _authAccountAddress ->
                    accountDisplayNameUseCase.invoke(accountAddress = _authAccountAddress)
                },
                authAccountIconDrawablePreview = authAccountAddress?.mapNotBlank { _authAccountAddress ->
                    createAccountIconDrawableUseCase.invoke(accountAddress = _authAccountAddress)
                },
                authAccountActionButton = accountStatusDetailPreviewDecider.decideAuthAccountActionButtonState(
                    account = account
                ),
                accountTypeDrawablePreview = createAccountIconDrawableUseCase.invoke(accountAddress = accountAddress),
                accountTypeString = accountStatusDetailPreviewDecider.decideAccountTypeString(account = account),
                descriptionAnnotatedString = accountStatusDetailPreviewDecider.decideDescriptionAnnotatedString(
                    account = account
                ),
                isRekeyToLedgerAccountAvailable = hasAccountAuthority,
                isRekeyToStandardAccountAvailable = hasAccountAuthority
            )
            send(preview)
        }
    }

    fun updatePreviewWithAddressCopyEvent(preview: AccountStatusDetailPreview?): AccountStatusDetailPreview? {
        return preview?.copy(copyAccountAddressToClipboardEvent = Event(Unit))
    }

    fun updatePreviewWithUndoRekeyNavigationEvent(preview: AccountStatusDetailPreview?): AccountStatusDetailPreview? {
        return preview?.copy(navToUndoRekeyNavigationEvent = Event(Unit))
    }
}
