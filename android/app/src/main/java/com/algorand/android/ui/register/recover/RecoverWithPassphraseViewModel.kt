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

package com.algorand.android.ui.register.recover

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.utils.PassphraseKeywordUtils
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class RecoverWithPassphraseViewModel @ViewModelInject constructor(
    private val accountManager: AccountManager,
) : BaseViewModel() {

    private val passphraseKeywordUtils = PassphraseKeywordUtils()

    var mnemonic: String = ""
    val newUpdateFlow = MutableSharedFlow<Pair<Int, String>>()
    val validationFlow = MutableSharedFlow<Pair<Int, Boolean>>()
    val suggestionWordsFlow = MutableStateFlow<Pair<Int, List<String>>>(Pair(0, listOf()))

    init {
        viewModelScope.launch(Dispatchers.Default) {
            newUpdateFlow.collect { (index, word) ->
                onNewUpdate(index, word)
            }
        }
    }

    private suspend fun onNewUpdate(index: Int, word: String) {
        checkValidation(index, word)
        handleKeywordSuggestor(index, word)
    }

    private fun handleKeywordSuggestor(index: Int, word: String) {
        val suggestedWords = passphraseKeywordUtils.getSuggestedWords(SUGGESTED_WORD_COUNT, word)
        suggestionWordsFlow.value = Pair(index, suggestedWords)
    }

    private suspend fun checkValidation(index: Int, word: String) {
        validationFlow.emit(Pair(index, passphraseKeywordUtils.isWordInKeywords(word)))
    }

    companion object {
        private const val SUGGESTED_WORD_COUNT = 3
    }
}
