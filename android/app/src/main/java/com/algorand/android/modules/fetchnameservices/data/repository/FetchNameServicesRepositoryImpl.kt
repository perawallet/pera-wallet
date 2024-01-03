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

package com.algorand.android.modules.fetchnameservices.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.fetchnameservices.data.mapper.NameServicesDTOMapper
import com.algorand.android.modules.fetchnameservices.data.model.FetchNameServicesRequestBody
import com.algorand.android.modules.fetchnameservices.domain.model.NameServiceDTO
import com.algorand.android.modules.fetchnameservices.domain.repository.FetchNameServicesRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler

class FetchNameServicesRepositoryImpl(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val nameServicesDTOMapper: NameServicesDTOMapper
) : FetchNameServicesRepository {

    override suspend fun fetchGivenAccountsNameServices(accountAddresses: List<String>): Result<List<NameServiceDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.readAccountsNameServices(
                fetchNameServicesRequestBody = FetchNameServicesRequestBody(
                    accountAddresses = accountAddresses
                )
            )
        }.map { fetchNameServicesResponse ->
            fetchNameServicesResponse.results?.map { nameServiceResultResponse ->
                nameServicesDTOMapper.mapToNameServicesDTO(nameServiceResultResponse)
            }.orEmpty()
        }
    }
}
