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

package com.algorand.android.mapper

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.WCArbitraryData
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectArbitraryDataSigner
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.usecase.AccountAlgoAmountUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.extensions.mapNotNull
import com.algorand.android.utils.multiplyOrZero
import java.math.BigInteger
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class WalletConnectArbitraryDataMapper @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val errorProvider: WalletConnectErrorProvider,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper
) {

    fun createWalletConnectArbitraryData(
        peerMeta: WalletConnectPeerMeta,
        arbitraryData: WCArbitraryData,
    ): WalletConnectArbitraryData? {
        return with(arbitraryData) {
            val accountDetail = arbitraryData.signer?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val wcAccount = WalletConnectAccount.create(
                account = accountDetail?.account,
                accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                    accountAddress = accountDetail?.account?.address.orEmpty()
                )
            )
            val signerAddress = accountDetail?.account?.address.orEmpty()
            val signerAccountData = signerAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val amount = signerAccountData?.accountInformation?.amount ?: BigInteger.ZERO
            val ownedAsset = signerAccountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                    AssetInformation.ALGO_ID,
                    accountDetail.account.address
                )
            }

            val walletConnectAssetInformation = createWalletConnectAssetInformation(ownedAsset, amount)
            val wcSigner = signer?.let {
                WalletConnectArbitraryDataSigner.create(
                    signerAccountType = signerAccountData?.account?.type,
                    signer,
                    errorProvider
                )
            }

            WalletConnectArbitraryData(
                chainId = arbitraryData.chainId,
                data = arbitraryData.data,
                message = arbitraryData.message,
                peerMeta = peerMeta,
                signerAccount = wcAccount,
                signer = wcSigner,
                signerAlgoBalance = walletConnectAssetInformation
            )
        }
    }

    private fun createWalletConnectAssetInformation(
        ownedAsset: BaseAccountAssetData.BaseOwnedAssetData?,
        amount: BigInteger
    ): WalletConnectAssetInformation? {
        if (ownedAsset == null) return null
        val safeAmount = amount.toBigDecimal().movePointLeft(ownedAsset.decimals).multiplyOrZero(ownedAsset.usdValue)
        return walletConnectAssetInformationMapper.mapToWalletConnectAssetInformation(ownedAsset, safeAmount)
    }
}
