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

package com.algorand.android.modules.fetchnameservices.domain.usecase

import com.algorand.android.modules.fetchnameservices.domain.mapper.NameServiceMapper
import com.algorand.android.modules.fetchnameservices.domain.model.NameService
import com.algorand.android.modules.fetchnameservices.domain.repository.FetchNameServicesRepository
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class FetchGivenAccountsNameServicesUseCase @Inject constructor(
    @Named(FetchNameServicesRepository.INJECTION_NAME)
    private val fetchNameServicesRepository: FetchNameServicesRepository,
    private val nameServiceMapper: NameServiceMapper
) {

    suspend operator fun invoke(accountAddresses: List<String>): Flow<DataResource<List<NameService>>> {
        return flow {
            emit(DataResource.Loading())
            fetchNameServicesRepository.fetchGivenAccountsNameServices(accountAddresses).use(
                onSuccess = { nameServiceDTOList ->
                    val nameServiceList = nameServiceDTOList.map { nameServiceDTO ->
                        nameServiceMapper.mapToNameService(nameServiceDTO)
                    }
                    emit(DataResource.Success(nameServiceList))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
        }
    }
}
