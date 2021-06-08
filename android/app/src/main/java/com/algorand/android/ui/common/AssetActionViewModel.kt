/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.network.getAsResourceError
import com.algorand.android.repository.AssetRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class AssetActionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val assetRepository: AssetRepository
) : BaseViewModel() {

    val assetInformationLiveData = MutableLiveData<Resource<AssetInformation>>()

    fun getAssetDescription(assetId: Long) {
        assetInformationLiveData.value = Resource.Loading
        viewModelScope.launch(Dispatchers.IO) {
            when (val result = assetRepository.getAssetDescription(assetId)) {
                is Result.Success -> {
                    accountCacheManager.setAssetDescription(assetId, result.data.assetParams)
                    assetInformationLiveData.postValue(
                        Resource.Success(result.data.assetParams.convertToAssetInformation(assetId))
                    )
                }
                is Result.Error -> {
                    assetInformationLiveData.postValue(result.getAsResourceError())
                }
            }
        }
    }
}
