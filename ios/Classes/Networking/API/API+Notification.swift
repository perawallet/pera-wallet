// Copyright 2019 Algorand, Inc.

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

import Magpie

extension AlgorandAPI {
    @discardableResult
    func registerDevice(
        with draft: DeviceRegistrationDraft,
        then handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func updateDevice(
        with draft: DeviceUpdateDraft,
        then handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/\(draft.id)/")
            .method(.put)
            .headers(mobileApiHeaders())
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func unregisterDevice(with draft: DeviceDeletionDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/")
            .method(.delete)
            .headers(mobileApiHeaders())
            .body(draft)
            .build()
            .send()
    }
    
    @discardableResult
    func getNotifications(
        for id: String,
        with cursorQuery: CursorQuery,
        then handler: @escaping (Response.ModelResult<PaginatedList<NotificationMessage>>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/\(id)/notifications/")
            .headers(mobileApiHeaders())
            .query(cursorQuery)
            .completionHandler(handler)
            .build()
            .send()
    }

    @discardableResult
    func updateNotificationFilter(
        with draft: NotificationFilterDraft,
        then handler: @escaping (Response.Result<NotificationFilterResponse, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/\(draft.deviceId)/accounts/\(draft.accountAddress)/")
            .headers(mobileApiHeaders())
            .method(.patch)
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
}
