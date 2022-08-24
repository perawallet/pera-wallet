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

package com.algorand.android.modules.nftdomain.domain.usecase

import com.algorand.android.modules.nftdomain.domain.mapper.NftDomainSearchResultMapper
import com.algorand.android.modules.nftdomain.domain.mapper.NftDomainServiceMapper
import com.algorand.android.modules.nftdomain.domain.model.NftDomainSearchResult
import com.algorand.android.modules.nftdomain.domain.repository.NftDomainSearchRepository
import javax.inject.Inject
import javax.inject.Named

class GetNftDomainSearchResultUseCase @Inject constructor(
    @Named(NftDomainSearchRepository.INJECTION_NAME)
    private val nftDomainSearchRepository: NftDomainSearchRepository,
    private val nftDomainSearchResultMapper: NftDomainSearchResultMapper,
    private val nftDomainServiceMapper: NftDomainServiceMapper
) {

    suspend fun getNftDomainSearchResults(query: String): List<NftDomainSearchResult> {
        val nftDomainSearchResultList = mutableListOf<NftDomainSearchResult>()
        val normalizedQuery = query.trim().lowercase()
        nftDomainSearchRepository.getSearchResults(normalizedQuery).use(
            onSuccess = { nftDomainSearchResultDtoList ->
                nftDomainSearchResultDtoList.forEach { searchResultDTO ->
                    with(searchResultDTO) {
                        if (!name.isNullOrBlank() && !accountAddress.isNullOrBlank()) {
                            val service = nftDomainServiceMapper.mapToNftDomainService(service)
                            val searchResult = nftDomainSearchResultMapper.mapToNftDomainSearchResult(
                                name,
                                accountAddress,
                                service
                            )
                            nftDomainSearchResultList.add(searchResult)
                        }
                    }
                }
            }
        )
        return nftDomainSearchResultList
    }
}
