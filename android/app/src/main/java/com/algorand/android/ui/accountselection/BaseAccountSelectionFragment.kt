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

package com.algorand.android.ui.accountselection

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseAccountSelectionBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getTextFromClipboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseAccountSelectionFragment : BaseFragment(R.layout.fragment_base_account_selection) {

    protected abstract val toolbarConfiguration: ToolbarConfiguration

    protected abstract fun onAccountSelected(publicKey: String)

    protected abstract fun initObservers()

    protected open fun onCopiedItemHandled(copiedMessage: String?) {}

    protected open val isSearchBarVisible: Boolean = false

    protected open val onSearchBarTextChangeListener: (String) -> Unit = {
        binding.transferButton.isVisible = it.isValidAddress()
    }

    protected open val onSearchBarCustomButtonClickListener: () -> Unit = {}

    private val binding by viewBinding(FragmentBaseAccountSelectionBinding::bind)

    private val accountSelectionListener = object : AccountSelectionAdapter.Listener {
        override fun onAccountItemClick(publicKey: String) {
            onAccountSelected(publicKey)
        }

        override fun onContactItemClick(publicKey: String) {
            onAccountSelected(publicKey)
        }

        override fun onPasteItemClick(publicKey: String) {
            updateSearchBarText(publicKey)
        }
    }

    protected val accountAdapter = AccountSelectionAdapter(accountSelectionListener)

    private val windowFocusChangeListener = ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
        if (hasFocus) onCopiedItemHandled(context?.getTextFromClipboard()?.toString())
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            accountsRecyclerView.adapter = accountAdapter
            searchView.apply {
                isVisible = isSearchBarVisible
                setOnTextChanged(onSearchBarTextChangeListener)
                setOnCustomButtonClick(onSearchBarCustomButtonClickListener)
            }
            transferButton.setOnClickListener { onAccountSelected(binding.searchView.text) }
        }
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.addOnWindowFocusChangeListener(windowFocusChangeListener)
        }
        onCopiedItemHandled(context?.getTextFromClipboard()?.toString())
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            view?.viewTreeObserver?.removeOnWindowFocusChangeListener(windowFocusChangeListener)
        }
    }

    protected fun updateSearchBarText(text: String) {
        binding.searchView.text = text
    }

    protected fun showProgress() {
        binding.progressBar.root.show()
    }

    protected fun hideProgress() {
        binding.progressBar.root.hide()
    }
}
