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

package com.algorand.android.ui.contacts

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.ContactDao
import com.algorand.android.models.User
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class ContactsViewModel @ViewModelInject constructor(
    private val contractsDao: ContactDao
) : BaseViewModel() {
    val contactsListLiveData = MutableLiveData<List<User>>()

    init {
        updateContactsListLiveDataWithSearchQuery("")
    }

    fun updateContactsListLiveDataWithSearchQuery(searchQuery: String) {
        viewModelScope.launch(Dispatchers.IO) {
            val filteredUserList = contractsDao.getUsersWithNameFiltered(searchQuery)
            withContext(Dispatchers.Main) {
                contactsListLiveData.value = filteredUserList
            }
        }
    }
}
