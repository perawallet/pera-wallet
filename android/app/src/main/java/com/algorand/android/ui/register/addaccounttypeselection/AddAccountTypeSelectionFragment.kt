package com.algorand.android.ui.register.addaccounttypeselection

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAddAccountTypeSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterFlowType
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.addaccounttypeselection.AddAccountTypeSelectionFragmentDirections.Companion.actionAddAccountTypeSelectionFragmentToPairLedgerNavigation
import com.algorand.android.ui.register.addaccounttypeselection.AddAccountTypeSelectionFragmentDirections.Companion.actionAddAccountTypeSelectionFragmentToRegisterInfoFragment
import com.algorand.android.ui.registerinfo.RegisterInfoFragment
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AddAccountTypeSelectionFragment : DaggerBaseFragment(R.layout.fragment_add_account_type_selection) {

    private val binding by viewBinding(FragmentAddAccountTypeSelectionBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        backgroundColor = R.color.tertiaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        statusBarConfiguration = statusBarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.createNewAccountSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.CREATE_WITH_PASSPHRASE)
        }
        binding.pairLedgerSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.PAIR_LEDGER)
        }
        binding.watchAccountSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.WATCH)
        }
    }

    private fun onRegisterTypeSelected(registerFlowType: RegisterFlowType) {
        when (registerFlowType) {
            RegisterFlowType.CREATE_WITH_PASSPHRASE -> {
                nav(actionAddAccountTypeSelectionFragmentToRegisterInfoFragment(RegisterInfoFragment.Type.BACKUP))
            }
            RegisterFlowType.PAIR_LEDGER -> {
                nav(actionAddAccountTypeSelectionFragmentToPairLedgerNavigation())
            }
            RegisterFlowType.WATCH -> {
                nav(actionAddAccountTypeSelectionFragmentToRegisterInfoFragment(RegisterInfoFragment.Type.WATCH))
            }
        }
    }
}
