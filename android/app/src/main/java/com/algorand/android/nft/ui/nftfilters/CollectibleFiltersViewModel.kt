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

package com.algorand.android.nft.ui.nftfilters

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.nft.ui.nftfilters.model.CollectibleFiltersPreview
import com.algorand.android.nft.ui.nftfilters.usecase.CollectibleFiltersPreviewUseCase
import com.algorand.android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class CollectibleFiltersViewModel @Inject constructor(
    private val collectibleFiltersPreviewUseCase: CollectibleFiltersPreviewUseCase
) : BaseViewModel() {

    private val _collectibleFiltersPreviewFlow = MutableStateFlow<CollectibleFiltersPreview?>(null)
    val collectibleFiltersPreviewFlow get() = _collectibleFiltersPreviewFlow

    init {
        initCollectibleFiltersPreviewFlow()
    }

    private fun initCollectibleFiltersPreviewFlow() {
        viewModelScope.launch {
            _collectibleFiltersPreviewFlow.emit(collectibleFiltersPreviewUseCase.getCollectibleFiltersPreviewFlow())
        }
    }

    fun onDisplayOptedInNFTsSwitchChanged(isChecked: Boolean) {
        _collectibleFiltersPreviewFlow.update {
            it?.copy(displayOptedInNFTsPreference = isChecked)
        }
    }

    fun onDisplayWatchAccountNFTsSwitchChanged(isChecked: Boolean) {
        _collectibleFiltersPreviewFlow.update {
            it?.copy(displayWatchAccountNFTsPreference = isChecked)
        }
    }

    fun saveChanges() {
        with(_collectibleFiltersPreviewFlow.value ?: return) {
            with(collectibleFiltersPreviewUseCase) {
                viewModelScope.launch(Dispatchers.IO) {
                    saveDisplayOptedInNFTsPreference(displayOptedInNFTsPreference)
                    saveDisplayWatchAccountNFTsPreference(displayWatchAccountNFTsPreference)
                    _collectibleFiltersPreviewFlow.update { it?.copy(onNavigateBackEvent = Event(Unit)) }
                }
            }
        }
    }
}
