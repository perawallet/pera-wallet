package com.algorand.android.usecase

import com.algorand.android.modules.swap.assetswap.domain.repository.AssetSwapRepository
import javax.inject.Inject
import javax.inject.Named

class UpdateSwapQuoteExceptionUseCase @Inject constructor(
    @Named(AssetSwapRepository.INJECTION_NAME)
    private val assetSwapRepository: AssetSwapRepository,
) {
    suspend fun updateSwapQuoteException(quoteId: Long, exceptionText: String?) {
        assetSwapRepository.updateSwapQuoteException(quoteId, exceptionText)
    }
}
