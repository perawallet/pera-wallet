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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.usecase

import com.algorand.android.R
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.basefoundaccount.information.ui.mapoer.BaseFoundAccountInformationItemMapper
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem
import com.algorand.android.modules.basefoundaccount.information.ui.usecase.BaseFoundAccountInformationItemUseCase
import com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.domain.usecase.GetRekeyedAccountUseCase
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.mapper.RekeyedAccountInformationPreviewMapper
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.model.RekeyedAccountInformationPreview
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.usecase.AccountAlgoAmountUseCase
import com.algorand.android.usecase.AccountAssetAmountUseCase
import com.algorand.android.usecase.AccountInformationUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.toShortenedAddress
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.flow

@SuppressWarnings("LongParameterList")
class RekeyedAccountInformationPreviewUseCase @Inject constructor(
    private val rekeyedAccountInformationPreviewMapper: RekeyedAccountInformationPreviewMapper,
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountInformationUseCase: AccountInformationUseCase,
    private val parityUseCase: ParityUseCase,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper,
    private val getRekeyedAccountUseCase: GetRekeyedAccountUseCase,
    baseFoundAccountInformationItemMapper: BaseFoundAccountInformationItemMapper
) : BaseFoundAccountInformationItemUseCase(baseFoundAccountInformationItemMapper) {

    fun getInitialRekeyedAccountInformationPreview(): RekeyedAccountInformationPreview {
        return rekeyedAccountInformationPreviewMapper.mapToRekeyedAccountInformationPreview(
            isLoading = true,
            foundAccountInformationItemList = emptyList()
        )
    }

    suspend fun getRekeyedAccountInformationPreviewFlow(
        accountAddress: String,
        coroutineScope: CoroutineScope,
        preview: RekeyedAccountInformationPreview
    ) = flow {
        accountInformationUseCase.getAccountInformationAndFetchAssets(
            publicKey = accountAddress,
            coroutineScope = coroutineScope
        ).use(
            onSuccess = { accountInformation ->
                lateinit var foundAccountInformationItemList: List<BaseFoundAccountInformationItem>
                getRekeyedAccountUseCase.invoke(accountAddress).useSuspended(
                    onSuccess = { rekeyedAccountInformation ->
                        foundAccountInformationItemList = createBaseFoundAccountInformationItemList(
                            accountInformation = accountInformation,
                            rekeyedAccounts = rekeyedAccountInformation
                        )
                    },
                    onFailed = {
                        foundAccountInformationItemList = createBaseFoundAccountInformationItemList(
                            accountInformation = accountInformation,
                            rekeyedAccounts = emptyList()
                        )
                    }
                )
                val copiedPreview = preview.copy(
                    isLoading = false,
                    foundAccountInformationItemList = foundAccountInformationItemList
                )

                emit(copiedPreview)
            }
        )
    }

    private fun createBaseFoundAccountInformationItemList(
        accountInformation: AccountInformation,
        rekeyedAccounts: List<AccountInformation>
    ): List<BaseFoundAccountInformationItem> {
        var primaryAccountValue = BigDecimal.ZERO
        var secondaryAccountValue = BigDecimal.ZERO
        val accountAssetDataList = accountInformation.assetHoldingMap.mapNotNull { (assetId, assetHolding) ->
            val assetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data ?: return@mapNotNull null
            accountAssetAmountUseCase.getAssetAmount(assetHolding, assetDetail)
        }
        val algoAssetItem = accountAlgoAmountUseCase.getAccountAlgoAmount(accountInformation).run {
            createAssetItem(
                baseAccountAssetData = this,
                onCalculationDone = { primaryValue, secondaryValue ->
                    primaryAccountValue += primaryValue
                    secondaryAccountValue += secondaryValue
                }
            )
        }

        val assetItemList = createAssetListItems(
            accountAssetData = accountAssetDataList,
            onCalculationDone = { primaryValue, secondaryValue ->
                primaryAccountValue += primaryValue
                secondaryAccountValue += secondaryValue
            }
        )

        val accountItem = createAccountItem(
            accountInformation = accountInformation,
            primaryAccountValue = primaryAccountValue,
            secondaryAccountValue = secondaryAccountValue
        )

        val authAccountItem = crateAuthAccount(accountInformation.rekeyAdminAddress)

        val rekeyedAccountItemList = rekeyedAccounts.map { it.address }.run { createRekeyedAccounts(this) }
        return mutableListOf<BaseFoundAccountInformationItem>().apply {
            add(createTitleItem(R.string.account_details))
            add(accountItem)

            add(createTitleItem(R.string.assets))
            if (algoAssetItem != null) {
                add(algoAssetItem)
            }
            addAll(assetItemList)

            if (authAccountItem != null) {
                add(createTitleItem(R.string.can_be_signed_by))
                add(authAccountItem)
            }

            if (rekeyedAccountItemList.isNotEmpty()) {
                add(createTitleItem(R.string.can_sign_for_these))
                addAll(rekeyedAccountItemList)
            }
        }
    }

    private fun createAssetListItems(
        accountAssetData: List<BaseAccountAssetData>,
        onCalculationDone: (BigDecimal, BigDecimal) -> Unit
    ): List<BaseFoundAccountInformationItem.AssetItem> {
        var primaryAssetsValue = BigDecimal.ZERO
        var secondaryAssetsValue = BigDecimal.ZERO
        return mutableListOf<BaseFoundAccountInformationItem.AssetItem>().apply {
            accountAssetData.forEach { accountAssetData ->
                val assetItem = createAssetItem(
                    baseAccountAssetData = accountAssetData,
                    onCalculationDone = { primaryValue, secondaryValue ->
                        primaryAssetsValue += primaryValue
                        secondaryAssetsValue += secondaryValue
                    }
                )
                if (assetItem != null) {
                    add(assetItem)
                }
            }
        }.also { onCalculationDone.invoke(primaryAssetsValue, secondaryAssetsValue) }
    }

    private fun createAssetItem(
        baseAccountAssetData: BaseAccountAssetData,
        onCalculationDone: (BigDecimal, BigDecimal) -> Unit
    ): BaseFoundAccountInformationItem.AssetItem? {
        return (baseAccountAssetData as? BaseAccountAssetData.BaseOwnedAssetData)?.run {
            createAssetItem(
                assetId = id,
                name = AssetName.create(name),
                shortName = AssetName.createShortName(shortName),
                verificationTierConfiguration = verificationTierConfigurationDecider
                    .decideVerificationTierConfiguration(verificationTier),
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                    assetId = id
                ),
                formattedPrimaryValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                formattedSecondaryValue = parityValueInSecondaryCurrency.getFormattedCompactValue()
            ).also {
                onCalculationDone.invoke(
                    parityValueInSelectedCurrency.amountAsCurrency,
                    parityValueInSecondaryCurrency.amountAsCurrency
                )
            }
        }
    }

    private fun createAccountItem(
        accountInformation: AccountInformation,
        primaryAccountValue: BigDecimal,
        secondaryAccountValue: BigDecimal
    ): BaseFoundAccountInformationItem.AccountItem {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        return createAccountItem(
            accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                accountName = accountInformation.address.toShortenedAddress(),
                accountAddress = accountInformation.address,
                nfDomainName = null,
                type = Account.Type.REKEYED
            ),
            accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                backgroundColorResId = R.color.wallet_4,
                iconTintResId = R.color.wallet_4_icon,
                iconResId = R.drawable.ic_rekey_shield
            ),
            formattedSecondaryValue = primaryAccountValue.formatAsCurrency(selectedCurrencySymbol),
            formattedPrimaryValue = secondaryAccountValue.formatAsCurrency(secondaryCurrencySymbol),
        )
    }

    private fun crateAuthAccount(rekeyAdminAddress: String?): BaseFoundAccountInformationItem.AccountItem? {
        return rekeyAdminAddress?.mapNotBlank { safeRekeyAdminAddress ->
            createAccountItem(
                accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                    accountName = safeRekeyAdminAddress.toShortenedAddress(),
                    accountAddress = safeRekeyAdminAddress,
                    nfDomainName = null,
                    type = Account.Type.STANDARD
                ),
                accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                    backgroundColorResId = R.color.wallet_4,
                    iconTintResId = R.color.wallet_4_icon,
                    iconResId = R.drawable.ic_wallet
                ),
                formattedSecondaryValue = null,
                formattedPrimaryValue = null
            )
        }
    }

    private fun createRekeyedAccounts(
        rekeyedAccountAddresses: List<String>
    ): List<BaseFoundAccountInformationItem.AccountItem> {
        return rekeyedAccountAddresses.map { rekeyedAccountAddress ->
            createAccountItem(
                accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                    accountName = rekeyedAccountAddress.toShortenedAddress(),
                    accountAddress = rekeyedAccountAddress,
                    nfDomainName = null,
                    type = Account.Type.REKEYED
                ),
                accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                    backgroundColorResId = R.color.wallet_4,
                    iconTintResId = R.color.wallet_4_icon,
                    iconResId = R.drawable.ic_rekey_shield
                ),
                formattedSecondaryValue = null,
                formattedPrimaryValue = null
            )
        }
    }
}
