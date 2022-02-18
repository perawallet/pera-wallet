/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.accountdetail.nfts

import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.models.FragmentConfiguration
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AccountNftsFragment : BaseFragment(R.layout.fragment_account_nfts) {
    override val fragmentConfiguration = FragmentConfiguration()

    companion object {
        fun newInstance(): AccountNftsFragment {
            return AccountNftsFragment()
        }
    }
}
