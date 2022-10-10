package com.algorand.android.modules.collectibles.action.optin

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.models.AssetAction
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.assets.action.base.BaseAssetActionViewModel
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetAssetDetailUseCase
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.GetFormattedTransactionFeeAmountUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class CollectibleOptInActionViewModel @Inject constructor(
    private val accountAddressUseCase: AccountAddressUseCase,
    private val getFormattedTransactionFeeAmountUseCase: GetFormattedTransactionFeeAmountUseCase,
    assetDetailUseCase: SimpleAssetDetailUseCase,
    simpleCollectibleUseCase: SimpleCollectibleUseCase,
    getAssetDetailUseCase: GetAssetDetailUseCase,
    verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    savedStateHandle: SavedStateHandle
) : BaseAssetActionViewModel(
    assetDetailUseCase,
    simpleCollectibleUseCase,
    getAssetDetailUseCase,
    verificationTierConfigurationDecider
) {

    private val assetAction: AssetAction = savedStateHandle.getOrThrow(ASSET_ACTION_KEY)

    val accountAddress: String = assetAction.publicKey.orEmpty()
    val assetName: AssetName = AssetName.create(assetAction.asset?.fullName)
    override val assetId: Long = assetAction.assetId

    init {
        fetchAssetDescription(assetId)
    }

    // TODO: Create [AssetActionUseCase] and get the whole UI related things from there
    fun getAccountName(): BaseAccountAddress.AccountAddress {
        return accountAddressUseCase.createAccountAddress(accountAddress)
    }

    fun getTransactionFee(): String {
        return getFormattedTransactionFeeAmountUseCase.getTransactionFee()
    }
}
