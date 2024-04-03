package com.algorand.android.ui.register.registerintro

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.databinding.FragmentRegisterTypeSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterIntroPreview
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.browser.openPrivacyPolicyUrl
import com.algorand.android.utils.browser.openTermsAndServicesUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.filterNotNull

// TODO: 16.02.2022 login_navigation graph should be separated into multiple graphs
@AndroidEntryPoint
class RegisterIntroFragment : DaggerBaseFragment(R.layout.fragment_register_type_selection) {

    private val registerIntroViewModel: RegisterIntroViewModel by viewModels()

    private val binding by viewBinding(FragmentRegisterTypeSelectionBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiary_background)

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.primary_background)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        statusBarConfiguration = statusBarConfiguration
    )

    private val registerIntroPreviewCollector: suspend (RegisterIntroPreview) -> Unit = {
        binding.titleTextView.setText(it.titleRes)
        configureToolbar(it.isCloseButtonVisible, it.isSkipButtonVisible)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            createAccountSelectionItem.setOnClickListener { navToBackupPassphraseInfoNavigation() }
            recoveryAccountSelectionItem.setOnClickListener { navToAccountRecoveryTypeSelectionFragment() }
            watchAccountSelectionItem.setOnClickListener { navToWatchAccountInfoFragment() }
        }
        setupPolicyText()
    }

    fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            registerIntroViewModel.registerIntroPreviewFlow.filterNotNull(),
            registerIntroPreviewCollector
        )
    }

    private fun navToBackupPassphraseInfoNavigation() {
        registerIntroViewModel.logOnboardingWelcomeAccountCreateClickEvent()
        nav(
            RegisterIntroFragmentDirections.actionRegisterIntroFragmentToBackupPassphraseInfoNavigation(
                publicKeysOfAccountsToBackup = emptyArray()
            )
        )
    }

    private fun navToAccountRecoveryTypeSelectionFragment() {
        registerIntroViewModel.logOnboardingWelcomeAccountRecoverClickEvent()
        nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToAccountRecoveryTypeSelectionFragment())
    }

    private fun navToWatchAccountInfoFragment() {
        registerIntroViewModel.logOnboardingCreateWatchAccountClickEvent()
        nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToWatchAccountInfoFragment())
    }

    private fun configureToolbar(isCloseButtonVisible: Boolean, isSkipButtonVisible: Boolean) {
        getAppToolbar()?.let { toolbar ->
            if (isCloseButtonVisible) {
                toolbar.configureStartButton(R.drawable.ic_close, ::navBack)
            }
            if (isSkipButtonVisible) {
                toolbar.setEndButton(button = TextButton(R.string.skip, onClick = ::onSkipClick))
            }
        }
    }

    private fun setupPolicyText() {
        binding.policyTextView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.link_primary)
            val termAndConditionsString = AnnotatedString(
                stringResId = R.string.by_creating_account,
                customAnnotationList = listOf(
                    "terms_click" to getCustomClickableSpan(linkTextColor) { context?.openTermsAndServicesUrl() },
                    "privacy_click" to getCustomClickableSpan(linkTextColor) { context?.openPrivacyPolicyUrl() }
                )
            )
            highlightColor = ContextCompat.getColor(context, R.color.transparent)
            movementMethod = LinkMovementMethod.getInstance()
            text = context.getXmlStyledString(termAndConditionsString)
        }
    }

    private fun onSkipClick() {
        registerIntroViewModel.logOnboardingCreateAccountSkipClickEvent()
        registerIntroViewModel.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }
}
