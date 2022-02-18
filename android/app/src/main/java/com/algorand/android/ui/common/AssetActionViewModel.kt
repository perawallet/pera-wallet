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

package com.algorand.android.ui.common

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class AssetActionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val assetDetailUseCase: SimpleAssetDetailUseCase
) : BaseViewModel() {

    val assetInformationLiveData = MutableLiveData<Resource<AssetInformation>>()

    fun fetchAssetDescription(assetId: Long) {
        assetInformationLiveData.value = Resource.Loading
        viewModelScope.launch(Dispatchers.IO) {
            assetDetailUseCase.fetchAssetById(listOf(assetId)).collect {
                when (it) {
                    is DataResource.Success -> {
                        val asset = it.data.firstOrNull() ?: return@collect
                        assetDetailUseCase.cacheAsset(CacheResult.Success.create(asset))
                        assetInformationLiveData.postValue(Resource.Success(asset.convertToAssetInformation()))
                    }
                    is DataResource.Error -> {
                        // TODO Handle error case
                        // assetInformationLiveData.postValue(Resource.Error.Api(it.exception))
                    }
                }
            }
        }
    }

    fun getAssetDescription(assetId: Long): AssetInformation? {
        return accountCacheManager.getAssetDescription(assetId)?.convertToAssetInformation()
    }
}
