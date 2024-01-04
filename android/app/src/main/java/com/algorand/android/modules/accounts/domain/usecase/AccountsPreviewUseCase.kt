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

package com.algorand.android.modules.accounts.domain.usecase

import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.banner.domain.model.BaseBanner
import com.algorand.android.banner.domain.model.BaseBanner.GenericBanner
import com.algorand.android.banner.domain.model.BaseBanner.GovernanceBanner
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.banner.ui.mapper.BaseBannerItemMapper
import com.algorand.android.core.AccountManager
import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.mapper.AccountPreviewMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.mapper.AccountListItemMapper
import com.algorand.android.modules.accounts.domain.mapper.PortfolioValueItemMapper
import com.algorand.android.modules.accounts.domain.model.AccountPreview
import com.algorand.android.modules.accounts.domain.model.AccountValue
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.HeaderItem
import com.algorand.android.modules.accounts.domain.model.BasePortfolioValueItem
import com.algorand.android.modules.accounts.ui.AccountsFragmentDirections
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.notification.domain.usecase.NotificationStatusUseCase
import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.peraconnectivitymanager.ui.PeraConnectivityManager
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.modules.swap.reddot.domain.usecase.GetSwapFeatureRedDotVisibilityUseCase
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial.ACCOUNT_ADDRESS_COPY
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial.GIFT_CARDS
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial.SWAP
import com.algorand.android.modules.tutorialdialog.domain.usecase.TutorialUseCase
import com.algorand.android.notification.domain.usecase.GetAskNotificationPermissionEventFlowUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AssetCacheManagerUseCase
import com.algorand.android.usecase.NodeSettingsUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.Event
import com.algorand.android.utils.combine
import com.algorand.android.utils.extensions.getAssetHoldingList
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext

// TODO Refactor this class for performance and code quality
@Suppress("LongParameterList")
class AccountsPreviewUseCase @Inject constructor(
    private val parityUseCase: ParityUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountManager: AccountManager,
    private val accountPreviewMapper: AccountPreviewMapper,
    private val accountListItemMapper: AccountListItemMapper,
    private val bannersUseCase: BannersUseCase,
    private val baseBannerItemMapper: BaseBannerItemMapper,
    private val nodeSettingsUseCase: NodeSettingsUseCase,
    private val portfolioValueItemMapper: PortfolioValueItemMapper,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    private val currencyUseCase: CurrencyUseCase,
    private val notificationStatusUseCase: NotificationStatusUseCase,
    private val getSwapFeatureRedDotVisibilityUseCase: GetSwapFeatureRedDotVisibilityUseCase,
    private val tutorialUseCase: TutorialUseCase,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val assetCacheManagerUseCase: AssetCacheManagerUseCase,
    private val getAskNotificationPermissionEventFlowUseCase: GetAskNotificationPermissionEventFlowUseCase,
    private val peraConnectivityManager: PeraConnectivityManager,
    private val accountBackupStatusUseCase: AccountBackupStatusUseCase
) {

    suspend fun dismissTutorial(tutorialId: Int) {
        tutorialUseCase.dismissTutorial(tutorialId)
    }

    suspend fun getInitialAccountPreview(): AccountPreview {
        val isTestnetBadgeVisible = nodeSettingsUseCase.isSelectedNodeTestnet()
        val isDeviceConnectedToInternet = peraConnectivityManager.isConnectedToInternet()
        return if (isDeviceConnectedToInternet) {
            accountPreviewMapper.getFullScreenLoadingState(isTestnetBadgeVisible)
        } else {
            accountPreviewMapper.getAllAccountsErrorState(
                accountListItems = createAccountErrorItemList(),
                errorCode = null,
                isTestnetBadgeVisible = isTestnetBadgeVisible,
                errorPortfolioValueItem = portfolioValueItemMapper.mapToPortfolioValuesErrorItem()
            )
        }
    }

    suspend fun getAccountsPreview(initialState: AccountPreview): Flow<AccountPreview> {
        var lastState: AccountPreview = initialState
        return combine(
            parityUseCase.getSelectedCurrencyDetailCacheFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(),
            bannersUseCase.getBanner(),
            tutorialUseCase.getTutorial(),
            getAskNotificationPermissionEventFlowUseCase.invoke(),
            nodeSettingsUseCase.getAllNodeAsFlow(),
            assetCacheManagerUseCase.getAssetCacheStatusFlow()
        ) { selectedCurrencyParityCache, accountDetailCache, banner, tutorial, notificationPermissionEvent, _, _ ->
            val isTestnetBadgeVisible = nodeSettingsUseCase.isSelectedNodeTestnet()
            val localAccounts = accountManager.getAccounts()
            if (localAccounts.isEmpty()) {
                return@combine accountPreviewMapper.getEmptyAccountListState(isTestnetBadgeVisible)
            }
            when (selectedCurrencyParityCache) {
                is CacheResult.Success -> {
                    processAccountsAndAssets(
                        accountDetailCache = accountDetailCache,
                        banner = banner,
                        isTestnetBadgeVisible = isTestnetBadgeVisible,
                        tutorial = tutorial,
                        notificationPermissionEvent = notificationPermissionEvent?.data
                    )
                }

                is CacheResult.Error -> getAlgoPriceErrorState(
                    selectedCurrencyDetailCache = selectedCurrencyParityCache,
                    previousState = lastState,
                    isTestnetBadgeVisible = isTestnetBadgeVisible
                )

                else -> accountPreviewMapper.getFullScreenLoadingState(isTestnetBadgeVisible)
            }.also { lastState = it }
        }
    }

    suspend fun onCloseBannerClick(bannerId: Long) {
        bannersUseCase.dismissBanner(bannerId)
    }

    suspend fun getSwapNavigationUpdatedPreview(previousState: AccountPreview): AccountPreview {
        var swapNavDirection: NavDirections? = null
        swapNavigationDestinationHelper.getSwapNavigationDestination(
            onNavToIntroduction = {
                swapNavDirection = AccountsFragmentDirections.actionAccountsFragmentToSwapIntroductionNavigation()
            },
            onNavToAccountSelection = {
                swapNavDirection = AccountsFragmentDirections.actionAccountsFragmentToSwapAccountSelectionNavigation()
            },
            onNavToSwap = { accountAddress ->
                swapNavDirection = AccountsFragmentDirections.actionAccountsFragmentToSwapNavigation(accountAddress)
            }
        )
        return swapNavDirection?.let { direction ->
            previousState.copy(swapNavigationDestinationEvent = Event(direction))
        } ?: previousState
    }

    fun getGiftCardsNavigationUpdatedPreview(previousState: AccountPreview): AccountPreview {
        return previousState.copy(
            giftCardsNavigationDestinationEvent = Event(
                AccountsFragmentDirections.actionAccountsFragmentToBidaliNavigation()
            )
        )
    }

    fun getNotBackedUpAccounts(): List<String> {
        return accountBackupStatusUseCase.getNotBackedUpAccounts()
    }

    private suspend fun getAlgoPriceErrorState(
        selectedCurrencyDetailCache: CacheResult.Error<SelectedCurrencyDetail>?,
        previousState: AccountPreview,
        isTestnetBadgeVisible: Boolean
    ): AccountPreview {
        val hasPreviousCachedValue = selectedCurrencyDetailCache?.data != null
        if (hasPreviousCachedValue) return previousState
        val accountErrorListItems = createAccountErrorItemList()
        val portfolioValuesError = portfolioValueItemMapper.mapToPortfolioValuesErrorItem()
        return accountPreviewMapper.getAllAccountsErrorState(
            accountListItems = accountErrorListItems,
            errorCode = selectedCurrencyDetailCache?.code,
            isTestnetBadgeVisible = isTestnetBadgeVisible,
            errorPortfolioValueItem = portfolioValuesError
        )
    }

    private suspend fun processAccountsAndAssets(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        banner: BaseBanner?,
        isTestnetBadgeVisible: Boolean,
        tutorial: Tutorial?,
        notificationPermissionEvent: Event<Unit>?
    ): AccountPreview {
        val areAllAccountsAreCached = accountDetailUseCase.areAllAccountsCached()
        return if (areAllAccountsAreCached) {
            processSuccessAccountCacheAndOthers(
                accountDetailCache = accountDetailCache,
                banner = banner,
                isTestnetBadgeVisible = isTestnetBadgeVisible,
                tutorial = tutorial,
                notificationPermissionEvent = notificationPermissionEvent
            )
        } else {
            accountPreviewMapper.getFullScreenLoadingState(isTestnetBadgeVisible)
        }
    }

    private suspend fun processSuccessAccountCacheAndOthers(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        banner: BaseBanner?,
        isTestnetBadgeVisible: Boolean,
        tutorial: Tutorial?,
        notificationPermissionEvent: Event<Unit>?
    ): AccountPreview {
        val isThereAnyAssetNeedsToBeCached = accountDetailCache.values.any {
            !it.data?.getAssetHoldingList().isNullOrEmpty()
        }
        return if (
            !assetCacheManagerUseCase.isCacheStatusAtLeastEmpty() &&
            isThereAnyAssetNeedsToBeCached
        ) {
            accountPreviewMapper.getFullScreenLoadingState(isTestnetBadgeVisible)
        } else {
            prepareAccountPreview(
                banner = banner,
                isTestnetBadgeVisible = isTestnetBadgeVisible,
                tutorial = tutorial,
                notificationPermissionEvent = notificationPermissionEvent
            )
        }
    }

    private suspend fun prepareAccountPreview(
        banner: BaseBanner?,
        isTestnetBadgeVisible: Boolean,
        tutorial: Tutorial?,
        notificationPermissionEvent: Event<Unit>?
    ): AccountPreview {
        return withContext(Dispatchers.Default) {
            var primaryAccountValue = BigDecimal.ZERO
            var secondaryAccountValue = BigDecimal.ZERO

            val baseAccountListItems = getBaseAccountListItems(onAccountValueCalculated = {
                primaryAccountValue += it.primaryAccountValue
                secondaryAccountValue += it.secondaryAccountValue
            }).apply {
                val bannerItem = getBannerItemOrNull(baseBanner = banner)
                // TODO: Remove test banner
                insertQuickActionsItem(this)
                getBackupBannerOrNull()?.also { backupBanner ->
                    add(BANNER_ITEM_INDEX, backupBanner)
                }
                if (bannerItem != null) add(BANNER_ITEM_INDEX, bannerItem)
            }
            val isThereAnyErrorInAccountCache =
                accountDetailUseCase.isThereAnyCachedErrorAccount(excludeWatchAccounts = true)
            val isThereAnySuccessInAccountCache =
                accountDetailUseCase.isThereAnyCachedSuccessAccount(excludeWatchAccounts = true)
            val portfolioValueItem = if (!isThereAnyErrorInAccountCache) {
                getPortfolioValueSuccessItem(primaryAccountValue, secondaryAccountValue)
            } else if (isThereAnySuccessInAccountCache) {
                getPortfolioValuePartialErrorItem(primaryAccountValue, secondaryAccountValue)
            } else {
                portfolioValueItemMapper.mapToPortfolioValuesErrorItem()
            }
            val giftCardsTutorialDisplayEvent = with(tutorial) {
                if (this == GIFT_CARDS) Event(id) else null
            }
            val swapTutorialDisplayEvent = with(tutorial) {
                if (this == SWAP) Event(id) else null
            }
            val accountAddressCopyDisplayEvent = with(tutorial) {
                if (this == ACCOUNT_ADDRESS_COPY) Event(id) else null
            }
            val hasNewNotification = notificationStatusUseCase.hasNewNotification()
            accountPreviewMapper.getSuccessAccountPreview(
                accountListItems = baseAccountListItems,
                isTestnetBadgeVisible = isTestnetBadgeVisible,
                portfolioValueItem = portfolioValueItem,
                hasNewNotification = hasNewNotification,
                onSwapTutorialDisplayEvent = swapTutorialDisplayEvent,
                onAccountAddressCopyTutorialDisplayEvent = accountAddressCopyDisplayEvent,
                onGiftCardsTutorialDisplayEvent = giftCardsTutorialDisplayEvent,
                notificationPermissionEvent = notificationPermissionEvent
            )
        }
    }

    private suspend fun insertQuickActionsItem(accountsList: MutableList<BaseAccountListItem>) {
        accountsList.add(
            index = QUICK_ACTIONS_ITEM_INDEX,
            element = accountListItemMapper.mapToQuickActionsItem(
                isSwapButtonSelected = getSwapFeatureRedDotVisibilityUseCase.getSwapFeatureRedDotVisibility()
            )
        )
    }

    private fun getBackupBannerOrNull(): BaseAccountListItem.BackupBannerItem? {
        val accounts = accountBackupStatusUseCase.getNotBackedUpAccounts()
        return if (accounts.isNotEmpty()) {
            BaseAccountListItem.BackupBannerItem(accounts)
        } else {
            null
        }
    }

    private fun getBannerItemOrNull(baseBanner: BaseBanner?): BaseAccountListItem.BaseBannerItem? {
        return baseBanner?.let { banner ->
            val isButtonVisible = !banner.buttonTitle.isNullOrBlank() && !banner.buttonUrl.isNullOrBlank()
            val isTitleVisible = !banner.title.isNullOrBlank()
            val isDescriptionVisible = !banner.description.isNullOrBlank()
            with(baseBannerItemMapper) {
                when (banner) {
                    is GovernanceBanner -> {
                        mapToGovernanceBannerItem(banner, isButtonVisible, isTitleVisible, isDescriptionVisible)
                    }

                    is GenericBanner -> {
                        mapToGenericBannerItem(banner, isButtonVisible, isTitleVisible, isDescriptionVisible)
                    }
                }
            }
        }
    }

    @SuppressWarnings("LongMethod")
    private suspend fun getBaseAccountListItems(
        onAccountValueCalculated: (AccountValue) -> Unit
    ): MutableList<BaseAccountListItem> {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrEmpty()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        val isPrimaryCurrencyAlgo = currencyUseCase.isPrimaryCurrencyAlgo()
        val isSecondaryCurrencyAlgo = !isPrimaryCurrencyAlgo
        val sortedAccountListItems = getSortedAccountsByPreferenceUseCase.getSortedAccountListItems(
            sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
            onLoadedAccountConfiguration = {
                val accountBalance = getAccountValueUseCase.getAccountValue(this).also { accountValue ->
                    if (account.type != Account.Type.WATCH) {
                        onAccountValueCalculated.invoke(accountValue)
                    }
                }
                val isBackedUp = account.isBackedUp
                accountItemConfigurationMapper.mapTo(
                    accountAddress = account.address,
                    accountDisplayName = getAccountDisplayNameUseCase.invoke(account.address),
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(account.address),
                    accountType = account.type,
                    accountPrimaryValueText = accountBalance.primaryAccountValue.formatAsCurrency(
                        symbol = selectedCurrencySymbol,
                        isCompact = true,
                        isFiat = !isPrimaryCurrencyAlgo
                    ),
                    accountSecondaryValueText = accountBalance.secondaryAccountValue.formatAsCurrency(
                        symbol = secondaryCurrencySymbol,
                        isCompact = true,
                        isFiat = !isSecondaryCurrencyAlgo
                    ),
                    accountPrimaryValue = accountBalance.primaryAccountValue,
                    accountSecondaryValue = accountBalance.secondaryAccountValue,
                    startSmallIconResource = if (isBackedUp) null else R.drawable.ic_error_negative
                )
            }, onFailedAccountConfiguration = {
                this?.run {
                    accountItemConfigurationMapper.mapTo(
                        accountAddress = address,
                        accountDisplayName = getAccountDisplayNameUseCase.invoke(address),
                        accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(address),
                        showWarningIcon = true
                    )
                }
            }
        )
        val baseAccountList = sortedAccountListItems.map { accountListItem ->
            if (accountListItem.itemConfiguration.showWarning == true) {
                accountListItemMapper.mapToErrorAccountItem(
                    accountListItem = accountListItem,
                    canCopyable = accountListItem.itemConfiguration.accountType != Account.Type.WATCH
                )
            } else {
                accountListItemMapper.mapToAccountItem(
                    accountListItem = accountListItem,
                    canCopyable = accountListItem.itemConfiguration.accountType != Account.Type.WATCH
                )
            }
        }
        return mutableListOf<BaseAccountListItem>().apply {
            if (baseAccountList.isNotEmpty()) {
                add(HeaderItem(R.string.accounts))
                addAll(baseAccountList)
            }
        }
    }

    private fun getPortfolioValueSuccessItem(
        primaryAccountValue: BigDecimal,
        secondaryAccountValue: BigDecimal
    ): BasePortfolioValueItem.SuccessPortfolioValueItem {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        return portfolioValueItemMapper.mapToPortfolioValuesSuccessItem(
            formattedPrimaryAccountValue = primaryAccountValue.formatAsCurrency(selectedCurrencySymbol),
            formattedSecondaryAccountValue = secondaryAccountValue.formatAsCurrency(secondaryCurrencySymbol)
        )
    }

    private fun getPortfolioValuePartialErrorItem(
        primaryAccountValue: BigDecimal,
        secondaryAccountValue: BigDecimal
    ): BasePortfolioValueItem.PartialErrorPortfolioValueItem {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        return portfolioValueItemMapper.mapToPortfolioValuesPartialErrorItem(
            formattedPrimaryAccountValue = primaryAccountValue.formatAsCurrency(selectedCurrencySymbol),
            formattedSecondaryAccountValue = secondaryAccountValue.formatAsCurrency(secondaryCurrencySymbol)
        )
    }

    private suspend fun createAccountErrorItemList(): List<BaseAccountListItem> {
        val sortedAccountListItems = getSortedAccountsByPreferenceUseCase.getSortedAccountListItems(
            sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
            onLoadedAccountConfiguration = {
                accountItemConfigurationMapper.mapTo(
                    accountAddress = account.address,
                    accountDisplayName = getAccountDisplayNameUseCase.invoke(account.address),
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(account.address),
                    accountType = account.type,
                    showWarningIcon = true
                )
            },
            onFailedAccountConfiguration = {
                this?.run {
                    accountItemConfigurationMapper.mapTo(
                        accountAddress = address,
                        accountDisplayName = getAccountDisplayNameUseCase.invoke(address),
                        accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(address),
                        accountType = type,
                        showWarningIcon = true
                    )
                }
            }
        )
        if (sortedAccountListItems.isEmpty()) return emptyList()
        return mutableListOf<BaseAccountListItem>().apply {
            add(HeaderItem(R.string.accounts))
            val baseAccountList = sortedAccountListItems.map { accountListItem ->
                if (accountListItem.itemConfiguration.showWarning == true) {
                    accountListItemMapper.mapToErrorAccountItem(
                        accountListItem = accountListItem,
                        canCopyable = accountListItem.itemConfiguration.accountType != Account.Type.WATCH
                    )
                } else {
                    accountListItemMapper.mapToAccountItem(
                        accountListItem = accountListItem,
                        canCopyable = accountListItem.itemConfiguration.accountType != Account.Type.WATCH
                    )
                }
            }
            addAll(baseAccountList)
            insertQuickActionsItem(this)
        }
    }

    companion object {
        private const val QUICK_ACTIONS_ITEM_INDEX = 0
        private const val BANNER_ITEM_INDEX = 1
    }
}
