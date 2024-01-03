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

import com.algorand.android.R
import com.algorand.android.SendAlgoNavigationDirections
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.AssetSupportRequest
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.Result
import com.algorand.android.models.TargetUser
import com.algorand.android.models.User
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.ui.model.RequestOptInConfirmationArgs
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.ContactRepository
import com.algorand.android.ui.send.receiveraccount.ReceiverAccountSelectionFragmentDirections
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.exceptions.GlobalException
import com.algorand.android.utils.exceptions.NavigationException
import com.algorand.android.utils.exceptions.WarningException
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.validator.AccountTransactionValidator
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flow

@Suppress("LongParameterList")
class ReceiverAccountSelectionUseCase @Inject constructor(
    private val contactRepository: ContactRepository,
    private val accountCacheManager: AccountCacheManager,
    private val accountTransactionValidator: AccountTransactionValidator,
    private val assetRepository: AssetRepository,
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val assetDataProviderDecider: AssetDrawableProviderDecider, // TODO Remove decider after refactor AssetInfo
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    accountInformationUseCase: AccountInformationUseCase
) : BaseSendAccountSelectionUseCase(accountInformationUseCase) {

    fun getToAccountList(
        query: String,
        latestCopiedMessage: String?
    ): Flow<List<BaseAccountSelectionListItem>> {
        val contactList = fetchContactList(query)
        val accountList = fetchAccountList(query)
        val nftDomainAccountList = fetchNftDomainAccountList(query)
        val queriedAddress = query.takeIf { it.isValidAddress() }
        return combine(
            accountList,
            contactList,
            nftDomainAccountList
        ) { accounts, contacts, nftDomainAccounts ->
            mutableListOf<BaseAccountSelectionListItem>().apply {
                createPasteItem(latestCopiedMessage)?.run { add(this) }
                createQueriedAccountItem(
                    accountAddresses = accounts.map { it.publicKey },
                    contactAddresses = contacts.map { it.publicKey },
                    queriedAddress = queriedAddress
                )?.run {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.account))
                    add(this)
                }
                if (nftDomainAccounts.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.matched_accounts))
                    addAll(nftDomainAccounts)
                }
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

    private fun createPasteItem(latestCopiedMessage: String?): BaseAccountSelectionListItem.PasteItem? {
        return latestCopiedMessage.takeIf { it.isValidAddress() }?.let { copiedAccount ->
            BaseAccountSelectionListItem.PasteItem(copiedAccount)
        }
    }

    private fun createQueriedAccountItem(
        queriedAddress: String?,
        accountAddresses: List<String>,
        contactAddresses: List<String>
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountItem? {
        if (queriedAddress.isNullOrBlank()) return null
        val shouldInsertQueriedAccount = shouldInsertQueriedAccount(
            accountAddresses = accountAddresses,
            contactAddresses = contactAddresses,
            queriedAccount = queriedAddress
        )
        if (!shouldInsertQueriedAccount) return null
        return accountSelectionListUseCase.createAccountSelectionItemFromAccountAddress(
            accountAddress = queriedAddress
        )
    }

    private fun shouldInsertQueriedAccount(
        accountAddresses: List<String>,
        contactAddresses: List<String>,
        queriedAccount: String?
    ): Boolean {
        return !accountAddresses.contains(queriedAccount) && !contactAddresses.contains(queriedAccount)
    }

    private fun fetchContactList(query: String) = flow {
        val contacts = accountSelectionListUseCase.createAccountSelectionListContactItems().filter {
            it.displayName.contains(query, true) || it.publicKey.contains(query, true)
        }
        emit(contacts)
    }

    private fun fetchNftDomainAccountList(query: String) = flow {
        val nftDomainAccounts = accountSelectionListUseCase.createAccountSelectionNftDomainItems(query)
        emit(nftDomainAccounts)
    }

    private fun fetchAccountList(query: String) = flow {
        val localAccounts = accountSelectionListUseCase.createAccountSelectionListAccountItems(
            showHoldings = false,
            showFailedAccounts = false
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
        fromAccountAddress: String,
        amount: BigInteger,
        nftDomainAddress: String?,
        nftDomainServiceLogoUrl: String?
    ): Result<TargetUser> {
        val isSelectedAssetValid = accountTransactionValidator.isSelectedAssetValid(fromAccountAddress, assetId)
        if (!isSelectedAssetValid) {
            // TODO: 18.03.2022 Find better exception message
            return Result.Error(Exception())
        }

        val isSelectedAssetSupported = accountTransactionValidator.isSelectedAssetSupported(
            accountInformation,
            assetId
        )
        val selectedAsset = getAssetInformation(assetId = assetId, accountAddress = fromAccountAddress)

        if (!isSelectedAssetSupported) {
            val nextDirection = ReceiverAccountSelectionFragmentDirections
                .actionReceiverAccountSelectionFragmentToRequestOptInConfirmationNavigation(
                    RequestOptInConfirmationArgs(
                        fromAccountAddress,
                        accountInformation.address,
                        assetId,
                        getAssetOrCollectibleNameOrNull(assetId)
                    )
                )
            return Result.Error(NavigationException(nextDirection))
        }

        if (assetId == ALGO_ID) {
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

        val fromAccountCacheData = accountCacheManager.getCacheData(fromAccountAddress)

        val isSendingMaxAmountToSameAccount = accountTransactionValidator.isSendingMaxAmountToTheSameAccount(
            fromAccount = fromAccountAddress,
            toAccount = accountInformation.address,
            maxAmount = selectedAsset?.amount ?: BigInteger.ZERO,
            amount = amount,
            isAlgo = selectedAsset?.isAlgo() ?: false
        )

        if (isSendingMaxAmountToSameAccount) {
            return Result.Error(GlobalException(descriptionRes = R.string.you_can_not_send_your))
        }

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
        val contact = getContactByAddressIfExists(toAccountPublicKey)
        val toAccountCacheData = accountCacheManager.getCacheData(toAccountPublicKey)
        val targetUser = TargetUser(
            contact = contact,
            publicKey = toAccountPublicKey,
            account = toAccountCacheData,
            nftDomainAddress = nftDomainAddress,
            nftDomainServiceLogoUrl = nftDomainServiceLogoUrl,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(fromAccountAddress)
        )
        return Result.Success(targetUser)
    }

    private suspend fun sendAssetSupportRequest(requestedAddress: String?, fromAddress: String?, assetId: Long) {
        if (requestedAddress == null || fromAddress == null) return
        assetRepository.postAssetSupportRequest(AssetSupportRequest(fromAddress, requestedAddress, assetId))
    }

    private suspend fun getContactByAddressIfExists(accountAddress: String): User? {
        return contactRepository.getAllContacts().firstOrNull { it.publicKey == accountAddress }
    }

    fun getAssetInformation(assetId: Long, accountAddress: String): AssetInformation? {
        val ownedAssetData = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, accountAddress)
        return AssetInformation.createAssetInformation(
            baseOwnedAssetData = ownedAssetData ?: return null,
            assetDrawableProvider = assetDataProviderDecider.getAssetDrawableProvider(assetId)
        )
    }

    fun getAssetOrCollectibleNameOrNull(assetId: Long): String? {
        return simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data?.fullName
            ?: simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data?.fullName
    }
}
