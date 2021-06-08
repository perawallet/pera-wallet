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

package com.algorand.android.database

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.algorand.android.models.User
import kotlinx.coroutines.flow.Flow

@Dao
interface ContactDao {
    @Query("SELECT * FROM user")
    fun getAll(): List<User>

    @Query("SELECT * FROM user")
    fun getAllAsFlow(): Flow<List<User>>

    @Query("SELECT * FROM user WHERE name LIKE '%' || :nameQuery || '%'")
    suspend fun getUsersWithNameFiltered(nameQuery: String): List<User>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUsers(userList: List<User>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertContact(contact: User)

    @Update(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateContact(contact: User)

    @Query("DELETE FROM user WHERE id = :contactDatabaseId")
    suspend fun deleteContact(contactDatabaseId: Int)

    @Query("SELECT * FROM user")
    fun getAllLiveData(): LiveData<List<User>>

    @Query("DELETE FROM user")
    suspend fun deleteAllContacts()

    @Query("SELECT * FROM user WHERE public_key = :address")
    suspend fun getContactByAddress(address: String): User?
}
