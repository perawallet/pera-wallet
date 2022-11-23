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

package com.algorand.android.modules.swap.confirmswap.domain.usecase

import com.algorand.android.modules.algosdk.domain.usecase.ParseTransactionMsgPackUseCase
import com.algorand.android.modules.swap.assetswap.domain.repository.AssetSwapRepository
import com.algorand.android.modules.swap.confirmswap.domain.factory.SwapTransactionItemFactory
import com.algorand.android.modules.swap.confirmswap.domain.mapper.SignedSwapSingleTransactionDataMapper
import com.algorand.android.modules.swap.confirmswap.domain.mapper.UnsignedSwapSingleTransactionDataMapper
import com.algorand.android.modules.swap.confirmswap.domain.model.SignedSwapSingleTransactionData
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransactionDTO
import com.algorand.android.modules.swap.confirmswap.domain.model.UnsignedSwapSingleTransactionData
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.NetworkSlugUseCase
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.decodeBase64
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.collectLatest

class CreateSwapQuoteTransactionsUseCase @Inject constructor(
    @Named(AssetSwapRepository.INJECTION_NAME)
    private val assetSwapRepository: AssetSwapRepository,
    private val unsignedSwapQuoteTransactionMapper: UnsignedSwapSingleTransactionDataMapper,
    private val signedSwapQuoteTransactionMapper: SignedSwapSingleTransactionDataMapper,
    private val swapTransactionItemFactory: SwapTransactionItemFactory,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val networkSlugUseCase: NetworkSlugUseCase,
    private val parseTransactionMsgPackUseCase: ParseTransactionMsgPackUseCase
) {

    suspend fun createQuoteTransactions(
        quoteId: Long,
        accountAddress: String
    ): DataResource<List<SwapQuoteTransaction>> {
        // TODO Change this result implementation. Use flow if possible
        var result: DataResource<List<SwapQuoteTransaction>>? = null
        assetSwapRepository.createQuoteTransactions(quoteId).collectLatest {
            it.use(
                onSuccess = { swapQuoteTransactionDtoList ->
                    val swapQuoteTransactionList = createSwapQuoteTransactionList(
                        accountAddress,
                        swapQuoteTransactionDtoList
                    )

                    result = DataResource.Success(swapQuoteTransactionList)
                },
                onFailed = { exception, code ->
                    result = DataResource.Error.Api<List<SwapQuoteTransaction>>(exception, code)
                }
            )
        }
        return result ?: DataResource.Error.Local<List<SwapQuoteTransaction>>(IllegalArgumentException())
    }

    private fun createSwapQuoteTransactionList(
        accountAddress: String,
        swapQuoteTransactionDtoList: List<SwapQuoteTransactionDTO>
    ): List<SwapQuoteTransaction> {
        return swapQuoteTransactionDtoList.mapIndexed { parentListIndex, swapQuoteTransactionDTO ->
            val signedSingleTransactions = createSingleSignedTransactions(swapQuoteTransactionDTO, parentListIndex)
            val unsignedSingleTransactions = createUnsignedSingleTransactions(
                swapQuoteTransactionDTO = swapQuoteTransactionDTO,
                parentListIndex = parentListIndex,
                accountAddress = accountAddress
            )
            swapTransactionItemFactory.createTransaction(
                purpose = swapQuoteTransactionDTO.purpose,
                transactionGroupId = swapQuoteTransactionDTO.transactionGroupId,
                unsignedTransactions = unsignedSingleTransactions,
                signedTransactions = signedSingleTransactions,
                transactionNetworkSlug = networkSlugUseCase.getActiveNodeSlug().orEmpty()
            )
        }
    }

    private fun createSingleSignedTransactions(
        swapQuoteTransactionDTO: SwapQuoteTransactionDTO,
        parentListIndex: Int
    ): MutableList<SignedSwapSingleTransactionData> {
        return swapQuoteTransactionDTO.signedTransactions
            ?.mapIndexed { index, signedTransaction ->
                signedSwapQuoteTransactionMapper.mapToSignedSwapSingleTransactionData(
                    parentListIndex = parentListIndex,
                    transactionListIndex = index,
                    signedTransactionMsgPack = signedTransaction?.decodeBase64()
                )
            }.orEmpty().toMutableList()
    }

    private fun createUnsignedSingleTransactions(
        swapQuoteTransactionDTO: SwapQuoteTransactionDTO,
        parentListIndex: Int,
        accountAddress: String
    ): List<UnsignedSwapSingleTransactionData> {
        return swapQuoteTransactionDTO.transactions
            ?.mapIndexed { index, unsignedTransaction ->
                unsignedSwapQuoteTransactionMapper.mapToUnsignedSwapSingleTransactionData(
                    parentListIndex = parentListIndex,
                    transactionListIndex = index,
                    transactionMsgPack = unsignedTransaction,
                    accountAddress = accountAddress,
                    accountAuthAddress = getAccountAuthAddressIfExist(accountAddress),
                    rawTransaction = unsignedTransaction?.decodeBase64()
                        ?.run { parseTransactionMsgPackUseCase.parse(this) }
                )
            }.orEmpty()
    }

    // TODO For the first release, we will disable validation due to TinymanV2 transition
    private fun areAllTransactionsValid(txnList: List<SwapQuoteTransaction>): Boolean {
        return txnList.all { it.areTransactionsInQuoteValid() }
    }

    private fun getAccountAuthAddressIfExist(accountAddress: String): String? {
        return accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data?.accountInformation?.rekeyAdminAddress
    }
}
