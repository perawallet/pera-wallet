/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.SendAlgoNavigationDirections
import com.algorand.android.core.AccountManager
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetSupportRequest
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.Result
import com.algorand.android.models.TargetUser
import com.algorand.android.models.User
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.ui.model.RequestOptInConfirmationArgs
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.ContactRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.exceptions.GlobalException
import com.algorand.android.utils.exceptions.NavigationException
import com.algorand.android.utils.exceptions.WarningException
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.getUserIfSavedLocally
import com.algorand.android.utils.validator.AccountTransactionValidator
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow

@Suppress("LongParameterList")
class ReceiverAccountSelectionUseCase @Inject constructor(
    private val contactRepository: ContactRepository,
    private val accountCacheManager: AccountCacheManager,
    private val accountTransactionValidator: AccountTransactionValidator,
    private val assetRepository: AssetRepository,
    private val accountManager: AccountManager,
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    accountInformationUseCase: AccountInformationUseCase
) : BaseSendAccountSelectionUseCase(accountInformationUseCase) {

    fun getToAccountList(query: String, assetId: Long): Flow<List<BaseAccountSelectionListItem>> {
        val contactList = fetchContactList(query)
        val accountList = fetchAccountList(assetId, query)
        return combine(accountList, contactList) { accounts, contacts ->
            mutableListOf<BaseAccountSelectionListItem>().apply {
                if (accounts.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.my_accounts))
                    addAll(accounts)
                }
                if (contacts.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.contacts))
                    addAll(contacts)
                }
            }
        }
    }

    private fun fetchContactList(query: String) = flow {
        val contacts = accountSelectionListUseCase.createAccountSelectionListContactItems().filter {
            it.displayName.contains(query, true) || it.publicKey.contains(query, true)
        }
        emit(contacts)
    }

    private fun fetchAccountList(assetId: Long, query: String) = flow {
        val localAccounts = accountSelectionListUseCase.createAccountSelectionListAccountItemsFilteredByAssetId(
            showAssetCount = false,
            showHoldings = false,
            shouldIncludeWatchAccounts = true,
            showFailedAccounts = false,
            assetId = assetId
        ).filter { it.displayName.contains(query, true) || it.publicKey.contains(query, true) }
        emit(localAccounts)
    }

    fun isAccountAddressValid(toAccountPublicKey: String): Result<String> {
        return accountTransactionValidator.isAccountAddressValid(toAccountPublicKey)
    }

    @SuppressWarnings("ReturnCount", "LongMethod")
    suspend fun checkToAccountTransactionRequirements(
        accountInformation: AccountInformation,
        assetId: Long,
        fromAccountPublicKey: String,
        amount: BigInteger
    ): Result<TargetUser> {
        val isSelectedAssetValid = accountTransactionValidator.isSelectedAssetValid(fromAccountPublicKey, assetId)
        if (!isSelectedAssetValid) {
            // TODO: 18.03.2022 Find better exception message
            return Result.Error(Exception())
        }

        val isSelectedAssetSupported = accountTransactionValidator.isSelectedAssetSupported(
            accountInformation,
            assetId
        )
        val selectedAsset = accountCacheManager.getAssetInformation(fromAccountPublicKey, assetId)

        if (!isSelectedAssetSupported) {
            val nextDirection = HomeNavigationDirections.actionGlobalRequestOptInConfirmationBottomSheet(
                RequestOptInConfirmationArgs(
                    fromAccountPublicKey,
                    accountInformation.address,
                    assetId,
                    getAssetOrCollectibleNameOrNull(assetId)
                )
            )
            return Result.Error(NavigationException(nextDirection))
        }

        if (assetId == ALGORAND_ID) {
            val minBalance = accountInformation.getMinAlgoBalance()
            val toAccountSelectedAssetBalance = accountInformation.getBalance(assetId)
            val isSendingAmountValid = accountTransactionValidator.isSendingAmountLesserThanMinimumBalance(
                toAccountSelectedAssetBalance,
                amount,
                minBalance
            )
            if (isSendingAmountValid) {
                val warningBodyMessage = AnnotatedString(
                    R.string.you_re_trying_to_send,
                    listOf("amount" to (minBalance - toAccountSelectedAssetBalance).formatAsAlgoString())
                )
                return Result.Error(WarningException(R.string.warning, warningBodyMessage))
            }
        }

        val fromAccountCacheData = accountCacheManager.getCacheData(fromAccountPublicKey)
        val isCloseTransactionToSameAccount = accountTransactionValidator.isCloseTransactionToSameAccount(
            fromAccountCacheData,
            accountInformation.address,
            selectedAsset,
            amount
        )

        if (isCloseTransactionToSameAccount) {
            return Result.Error(GlobalException(descriptionRes = R.string.you_can_not_send_your))
        }

        val isAccountNewlyOpenedAndBalanceInvalid = accountTransactionValidator.isAccountNewlyOpenedAndBalanceInvalid(
            accountInformation,
            amount,
            assetId
        )
        if (isAccountNewlyOpenedAndBalanceInvalid) {
            // TODO: 18.02.2022 Move all navigation logic into the presentation layer
            return Result.Error(
                NavigationException(
                    SendAlgoNavigationDirections.actionGlobalSingleButtonBottomSheet(
                        titleAnnotatedString = AnnotatedString(R.string.minimum_amount_required),
                        descriptionAnnotatedString = AnnotatedString(R.string.this_is_the_first_transaction),
                        buttonStringResId = R.string.i_understand,
                        drawableResId = R.drawable.ic_info,
                        drawableTintResId = R.color.error_tint_color
                    )
                )
            )
        }

        val toAccountPublicKey = accountInformation.address
        val contact = handleIfToAccountPublicKeyIntoLocal(toAccountPublicKey)
        val toAccountCacheData = accountCacheManager.getCacheData(toAccountPublicKey)
        val targetUser = TargetUser(contact, toAccountPublicKey, toAccountCacheData)
        return Result.Success(targetUser)
    }

    private suspend fun sendAssetSupportRequest(requestedAddress: String?, fromAddress: String?, assetId: Long) {
        if (requestedAddress == null || fromAddress == null) return
        assetRepository.postAssetSupportRequest(AssetSupportRequest(fromAddress, requestedAddress, assetId))
    }

    private suspend fun handleIfToAccountPublicKeyIntoLocal(publicKey: String): User? {
        return getUserIfSavedLocally(
            contactList = contactRepository.getContacts().first(),
            accountList = accountManager.getAccounts(),
            nonOwnerPublicKey = publicKey
        )
    }

    fun getAssetInformation(assetId: Long, publicKey: String): AssetInformation? {
        val ownedAssetData = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, publicKey)
        return AssetInformation.createAssetInformation(ownedAssetData ?: return null)
    }

    fun getAssetOrCollectibleNameOrNull(assetId: Long): String? {
        return simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data?.fullName
            ?: simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data?.fullName
    }
}
