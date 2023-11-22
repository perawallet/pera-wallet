// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WatchAccountAdditionAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MacaroonForm

final class WatchAccountAdditionAPIDataController: WatchAccountAdditionDataController {
    var eventHandler: EventHandler?

    private lazy var apiThrottler: Throttler = .init(intervalInSeconds: 0.3)
    private lazy var nameServiceValidator: RegexValidator = .nameService()

    private var ongoingEndpointToLoadNameServices: EndpointOperatable?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private let session: Session
    private let pushNotificationController: PushNotificationController
    private let analytics: ALGAnalytics

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI,
        session: Session,
        pushNotificationController: PushNotificationController,
        analytics: ALGAnalytics
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
        self.session = session
        self.pushNotificationController = pushNotificationController
        self.analytics = analytics
    }

    deinit {
        cancelNameServiceSearchingIfNeeded()
    }
}

extension WatchAccountAdditionAPIDataController {
    func searchNameServicesIfNeeded(for searchQuery: String?) {
        guard let preparedQuery = prepareQueryForValidation(searchQuery),
              isQueryValidNameService(preparedQuery) else {
            cancelNameServiceSearchingIfNeeded()
            return
        }

        let nameServiceQuery = NameServiceQuery(name: preparedQuery)
        fetchNameServices(nameServiceQuery)
    }
    
    private func fetchNameServices(_ query: NameServiceQuery) {
        let task = {
            [weak self] in
            guard let self = self else {
                return
            }

            self.cancelOngoingNameServicesEndpoint()

            self.publish(.willLoadNameServices)

            self.ongoingEndpointToLoadNameServices = self.api.fetchNameServices(query) {
                [weak self] result in
                guard let self = self else { return }

                self.ongoingEndpointToLoadNameServices = nil

                switch result {
                case .success(let nameServiceList):
                    let nameServices = nameServiceList.results
                    self.publish(.didLoadNameServices(nameServices))
                case .failure:
                    self.publish(.didFailLoadingNameServices)
                }
            }
        }

        apiThrottler.performNext(task)
    }

    private func isQueryValidNameService(_ query: String?) -> Bool {
        let validationResult = nameServiceValidator.validate(query)
        return validationResult.isSuccess
    }

    private func prepareQueryForValidation(_ query: String?) -> String? {
        let preparedQuery = query?.trimmed().lowercased()
        return preparedQuery.unwrapNonEmptyString()
    }

    func cancelNameServiceSearchingIfNeeded() {
        let isNotSearching = ongoingEndpointToLoadNameServices.isNilOrFinished

        if isNotSearching {
            return
        }

        apiThrottler.cancelAll()
        cancelOngoingNameServicesEndpoint()
    }

    private func cancelOngoingNameServicesEndpoint() {
        ongoingEndpointToLoadNameServices?.cancel()
        ongoingEndpointToLoadNameServices = nil
    }
}

extension WatchAccountAdditionAPIDataController {
    func shouldEnableAddAction(_ input: String?) -> Bool {
        if let input = input,
           input.hasValidAddressLength &&
            input.isValidatedAddress {
            return true
        }

        return false
    }
}

extension WatchAccountAdditionAPIDataController {
    func createAccount(
        from address: String,
        with name: String
    ) -> AccountInformation {
        let account = AccountInformation(
            address: address,
            name: name,
            isWatchAccount: true,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(), 
            isBackedUp: true
        )
        let user: User

        if let authenticatedUser = session.authenticatedUser {
            user = authenticatedUser
            if authenticatedUser.account(address: address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }
            pushNotificationController.sendDeviceDetails()
        } else {
            user = User(accounts: [account])
        }

        session.authenticatedUser = user

        analytics.track(.registerAccount(registrationType: .watch))

        return account
    }
}

 extension WatchAccountAdditionAPIDataController {
     private func publish(_ event: WatchAccountAdditionDataControllerEvent) {
         asyncMain {
             [weak self] in
             guard let self = self else { return }

             self.eventHandler?(event)
         }
     }
 }
