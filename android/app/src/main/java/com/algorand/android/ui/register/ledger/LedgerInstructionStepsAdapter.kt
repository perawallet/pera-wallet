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

package com.algorand.android.ui.register.ledger

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView

class LedgerInstructionStepsAdapter : RecyclerView.Adapter<LedgerInstructionStepViewHolder>() {

    private val stepsList = mutableListOf<Int>()

    fun setItems(newStepsList: List<Int>) {
        stepsList.apply {
            clear()
            addAll(newStepsList)
        }
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LedgerInstructionStepViewHolder {
        return LedgerInstructionStepViewHolder.create(parent)
    }

    override fun getItemCount() = stepsList.size

    override fun onBindViewHolder(holder: LedgerInstructionStepViewHolder, position: Int) {
        holder.bind(stepsList[position], position)
    }
}
