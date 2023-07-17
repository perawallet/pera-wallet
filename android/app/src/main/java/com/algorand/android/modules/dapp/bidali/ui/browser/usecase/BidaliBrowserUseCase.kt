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

package com.algorand.android.modules.dapp.bidali.ui.browser.usecase

import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.TargetUser
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.dapp.bidali.domain.mapper.BidaliAssetMapper
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliPaymentRequestDTO
import com.algorand.android.modules.dapp.bidali.domain.model.MainnetBidaliSupportedCurrency
import com.algorand.android.modules.dapp.bidali.domain.model.TestnetBidaliSupportedCurrency
import com.algorand.android.modules.dapp.bidali.getCompiledBidaliJavascript
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.usecase.IsOnMainnetUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.formatAmountAsBigInteger
import com.algorand.android.utils.toBigDecimalOrZero
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class BidaliBrowserUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val bidaliAssetMapper: BidaliAssetMapper,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val isOnMainnetUseCase: IsOnMainnetUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    fun generateBidaliJavascript(accountAddress: String): String {
        return getCompiledBidaliJavascript(
            currencies = bidaliAssetMapper.mapFromOwnedAssetData(
                ownedAssetDataList = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true),
                isMainnet = isOnMainnetUseCase.invoke()
            ),
            isMainnet = isOnMainnetUseCase.invoke()
        )
    }

    fun getTransactionDataFromPaymentRequest(
        paymentRequest: BidaliPaymentRequestDTO,
        accountAddress: String
    ): TransactionData.Send? {
        // TODO handle cases when we can't find address or assets
        val selectedAccountCacheData = getAccountInformation(accountAddress) ?: return null
        val selectedAssetId = getAssetIdFromBidaliIdentifier(
            bidaliId = paymentRequest.protocol,
            isMainnet = isOnMainnetUseCase.invoke()
        ) ?: return null
        val selectedAsset = getAssetInformation(
            accountAddress,
            selectedAssetId
        ) ?: return null
        val amountAsBigInteger = getAmountAsBigInteger(
            paymentRequest.amount.toBigDecimalOrZero(),
            selectedAssetId
        ) ?: return null
        return TransactionData.Send(
            senderAccountAddress = selectedAccountCacheData.account.address,
            senderAccountDetail = selectedAccountCacheData.account.detail,
            senderAccountType = selectedAccountCacheData.account.type,
            senderAuthAddress = selectedAccountCacheData.authAddress,
            senderAccountName = selectedAccountCacheData.account.name,
            isSenderRekeyedToAnotherAccount = selectedAccountCacheData.isRekeyedToAnotherAccount(),
            minimumBalance = selectedAccountCacheData.getMinBalance(),
            amount = amountAsBigInteger,
            assetInformation = selectedAsset,
            xnote = paymentRequest.extraId,
            targetUser = TargetUser(
                publicKey = paymentRequest.address,
                accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountAddress)
            )
        )
    }

    private fun getAmountAsBigInteger(amount: BigDecimal, assetId: Long): BigInteger? {
        val assetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)
            ?: return null
        return amount.formatAmountAsBigInteger(assetDetail.data?.fractionDecimals ?: return null)
    }

    private fun getAccountInformation(publicKey: String): AccountCacheData? {
        return accountCacheManager.getCacheData(publicKey)
    }

    private fun getAssetInformation(publicKey: String, assetId: Long): AssetInformation? {
        val ownedAssetData = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, publicKey)
        return AssetInformation.createAssetInformation(
            baseOwnedAssetData = ownedAssetData ?: return null,
            assetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(assetId)
        )
    }

    private fun getAssetIdFromBidaliIdentifier(bidaliId: String, isMainnet: Boolean): Long? {
        return if (isMainnet) {
            MainnetBidaliSupportedCurrency.values().firstOrNull {
                it.key == bidaliId
            }?.assetId
        } else {
            TestnetBidaliSupportedCurrency.values().firstOrNull {
                it.key == bidaliId
            }?.assetId
        }
    }
}
