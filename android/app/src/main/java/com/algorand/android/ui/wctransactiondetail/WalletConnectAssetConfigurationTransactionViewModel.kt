/*
 * Copyright 2019 Algorand, Inc.
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

package com.algorand.android.ui.wctransactiondetail

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetParams
import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAccountsInfo
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.models.WalletConnectTransactionInfo
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.decodeBase64IfUTF8
import java.math.BigInteger

class WalletConnectAssetConfigurationTransactionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val indexerInterceptor: AlgodInterceptor
) : BaseWalletConnectTransactionViewModel() {

    fun getTransactionInfo(transaction: BaseAssetConfigurationTransaction) {
        val transactionInfo = with(transaction) {
            val decodedSenderAddress = senderAddress.decodedAddress ?: return
            val accountCache = accountCacheManager.getCacheData(decodedSenderAddress)
            val fromDisplayAddress = BaseWalletConnectDisplayedAddress.create(decodedSenderAddress, accountCacheData)

            when (this) {
                // TODO: 28.09.2021 We must create something like `TransactionInfoBuilder` interface and it's model
                //  class and use it to to reduce usage of when
                is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> {
                    WalletConnectTransactionInfo(
                        fromDisplayedAddress = fromDisplayAddress,
                        dappName = peerMeta.name,
                        accountTypeImageResId = accountCache?.getImageResource(),
                        rekeyToAccountAddress = formattedRekeyToAccountAddress,
                        closeToAccountAddress = formattedCloseToAccountAddress,
                        assetDecimal = assetDecimal,
                        unitName = unitName,
                        assetName = assetName,
                    )
                }
                is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> {
                    WalletConnectTransactionInfo(
                        fromDisplayedAddress = fromDisplayAddress,
                        dappName = peerMeta.name,
                        accountTypeImageResId = accountCache?.getImageResource(),
                        accountBalance = accountCacheManager.getAssetInformation(decodedSenderAddress, assetId)?.amount,
                        assetInformation = createAssetInformation(assetId, assetParams),
                        rekeyToAccountAddress = formattedRekeyToAccountAddress,
                        closeToAccountAddress = formattedCloseToAccountAddress,
                        assetDecimal = assetDecimal,
                        showAssetDeletionWarning = true
                    )
                }
                is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                    WalletConnectTransactionInfo(
                        fromDisplayedAddress = fromDisplayAddress,
                        dappName = peerMeta.name,
                        accountTypeImageResId = accountCache?.getImageResource(),
                        accountBalance = accountCacheManager.getAssetInformation(decodedSenderAddress, assetId)?.amount,
                        assetInformation = createAssetInformation(assetId, assetParams),
                        rekeyToAccountAddress = formattedRekeyToAccountAddress,
                        closeToAccountAddress = formattedCloseToAccountAddress,
                        assetDecimal = assetDecimal
                    )
                }
            }
        }
        transactionInfoLiveData.value = transactionInfo
    }

    fun getAccountsInfo(transaction: BaseAssetConfigurationTransaction) {
        val accountsInfo = with(transaction) {
            when (this) {
                is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> {
                    WalletConnectAccountsInfo(
                        amount = totalAmount,
                        fee = walletConnectTransactionParams.fee,
                        createdAssetDecimal = decimals,
                        isFrozen = isFrozen,
                        managerAddress = BaseWalletConnectDisplayedAddress.create(
                            managerAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        reserveAddress = BaseWalletConnectDisplayedAddress.create(
                            reserveAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        frozenAddress = BaseWalletConnectDisplayedAddress.create(
                            frozenAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        clawbackAddress = BaseWalletConnectDisplayedAddress.create(
                            clawbackAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        transactionAmountDecimal = assetDecimal
                    )
                }
                is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> {
                    WalletConnectAccountsInfo(fee = walletConnectTransactionParams.fee)
                }
                is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                    WalletConnectAccountsInfo(
                        fee = walletConnectTransactionParams.fee,
                        managerAddress = BaseWalletConnectDisplayedAddress.create(
                            managerAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        reserveAddress = BaseWalletConnectDisplayedAddress.create(
                            reserveAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        frozenAddress = BaseWalletConnectDisplayedAddress.create(
                            frozenAddress?.decodedAddress.orEmpty(), accountCacheData
                        ),
                        clawbackAddress = BaseWalletConnectDisplayedAddress.create(
                            clawbackAddress?.decodedAddress.orEmpty(), accountCacheData
                        )
                    )
                }
            }
        }
        accountsInfoLiveData.value = accountsInfo
    }

    fun getExtras(transaction: BaseAssetConfigurationTransaction) {
        val extras = with(transaction) {
            when (this) {
                is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> {
                    WalletConnectExtras(
                        note = note,
                        rawTransaction = rawTransactionPayload,
                        assetUrl = url,
                        metadataHash = metadataHash?.decodeBase64IfUTF8()
                    )
                }
                is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> {
                    WalletConnectExtras(
                        note = note,
                        rawTransaction = rawTransactionPayload,
                        assetId = assetId,
                        assetUrl = url ?: assetParams?.url,
                        networkSlug = indexerInterceptor.currentActiveNode?.networkSlug
                    )
                }
                is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                    WalletConnectExtras(
                        note = note,
                        rawTransaction = rawTransactionPayload,
                        assetId = assetId,
                        assetUrl = url ?: assetParams?.url,
                        networkSlug = indexerInterceptor.currentActiveNode?.networkSlug
                    )
                }
            }
        }
        extrasLiveData.value = extras
    }

    private fun createAssetInformation(assetId: Long, assetParams: AssetParams?): AssetInformation? {
        if (assetParams == null) return null
        val defaultAssetHolding = AssetHolding(assetId, BigInteger.ZERO, false)
        return AssetInformation.createAssetInformation(defaultAssetHolding, assetParams)
    }
}
