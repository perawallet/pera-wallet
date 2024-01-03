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

package com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.baseresult.ui.BaseResultFragment
import com.algorand.android.modules.baseresult.ui.BaseResultViewModel
import com.algorand.android.modules.baseresult.ui.adapter.BaseResultAdapter
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AsbAccountRestoreResultFragment : BaseResultFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::popImportBackupNavigationUp
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)
    override val baseResultAdapter = BaseResultAdapter(accountItemListener)
    override val baseResultViewModel: BaseResultViewModel get() = asbAccountRestoreResultViewModel

    private val asbAccountRestoreResultViewModel by viewModels<AsbAccountRestoreResultViewModel>()

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            popImportBackupNavigationUp()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    override fun initUi() {
        super.initUi()
        binding.primaryActionButton.apply {
            setText(R.string.explore_pera_mobile)
            setOnClickListener { popImportBackupNavigationUp() }
            show()
        }
    }

    private fun popImportBackupNavigationUp() {
        nav(AsbAccountRestoreResultFragmentDirections.actionAsbAccountRestoreResultFragmentToHomeNavigation())
    }
}
