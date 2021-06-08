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

package com.algorand.android.ui.lock

import android.content.Context
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.ContactDao
import com.algorand.android.utils.AccountCacheManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class LockViewModel @ViewModelInject constructor(
    private val contactDao: ContactDao,
    private val accountManager: AccountManager,
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    private var resetJob: Job? = null

    fun resetAllData(context: Context?) {
        if (resetJob != null) {
            return
        }

        resetJob = viewModelScope.launch(Dispatchers.IO) {
            contactDao.deleteAllContacts()
            withContext(Dispatchers.Main) {
                accountManager.removeAllDataAndStartFromLogin(context, accountCacheManager)
            }
        }
    }
}
