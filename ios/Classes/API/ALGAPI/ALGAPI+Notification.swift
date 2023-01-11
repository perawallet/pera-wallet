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

//
//  API+Notification.swift

import MagpieCore
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    func registerDevice(
        _ draft: DeviceRegistrationDraft,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.devices)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    func unregisterDevice(
        _ draft: DeviceUpdateDraft,
        from network: ALGAPI.Network,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.deviceDetail, args: draft.id)
            .method(.put)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func updateDevice(
        _ draft: DeviceUpdateDraft,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.deviceDetail, args: draft.id)
            .method(.put)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func revokeDevice(
        _ draft: DeviceDeletionDraft,
        onCompleted handler: @escaping (Response.ErrorModelResult<HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.devices)
            .method(.delete)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func getNotifications(
        _ id: String,
        with cursorQuery: CursorQuery,
        onCompleted handler: @escaping (Response.ModelResult<NotificationMessageList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.notifications, args: id)
            .method(.get)
            .query(cursorQuery)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func updateNotificationFilter(
        _ draft: NotificationFilterDraft,
        onCompleted handler: @escaping (Response.Result<NotificationFilterResponse, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.deviceAccountUpdate, args: draft.deviceId, draft.accountAddress)
            .method(.patch)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func fetchNotificationStatus(
        _ draft: NotificationStatusFetchDraft,
        onCompleted handler: @escaping (Response.Result<NotificationStatus, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.deviceNotificationStatus, args: draft.deviceId)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func updateNotificationStatus(
        _ draft: NotificationStatusUpdateDraft,
        onCompleted handler: @escaping (Response.Result<LastSeenNotificationStatus, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.lastSeenNotificationStatus, args: draft.deviceId)
            .method(.put)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }
}
