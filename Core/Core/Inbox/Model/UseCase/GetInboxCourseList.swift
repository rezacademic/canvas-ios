//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public class GetInboxCourseList: CollectionUseCase {
    public typealias Model = InboxCourse

    public var cacheKey: String? { "inboxCourseList" }
    public var request: GetCurrentUserCoursesRequest {
        GetCurrentUserCoursesRequest(enrollmentState: .active, state: [.current_and_concluded], perPage: 100)
    }
    public var scope: Scope {
        let order = [
            NSSortDescriptor(key: #keyPath(InboxCourse.name), ascending: true)
        ]
        return Scope(predicate: .all, order: order)
    }
}
