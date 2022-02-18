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

package com.algorand.android.sharedpref

import android.content.SharedPreferences

abstract class SharedPrefLocalSource<K>(protected val sharedPref: SharedPreferences) {

    abstract val key: String

    abstract fun getData(defaultValue: K): K

    abstract fun getDataOrNull(): K?

    abstract fun saveData(data: K)

    private var listenerList: MutableSet<OnChangeListener<K>> = mutableSetOf()

    fun clear() {
        sharedPref.edit().remove(key).apply()
        triggerListener { it.onValueChanged(null) }
    }

    fun addListener(listener: OnChangeListener<K>) {
        listenerList.add(listener)
    }

    fun removeListener(listener: OnChangeListener<K>) {
        listenerList.remove(listener)
    }

    protected fun saveData(action: (SharedPreferences.Editor) -> Unit) {
        sharedPref.edit().apply {
            action(this)
        }.apply()
        triggerListener { it.onValueChanged(getDataOrNull()) }
    }

    private fun triggerListener(action: (OnChangeListener<K>) -> Unit) {
        listenerList.forEach { action(it) }
    }

    fun interface OnChangeListener<K> {
        fun onValueChanged(value: K?)
    }
}
