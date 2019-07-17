//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation

enum Announcements {
    static func announcement(index: Int) -> Element {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }
}

enum AnnouncementDetail {
    static var text: Element {
        return app.find(label: "This is the third announcement")
    }
}

class AnnouncementTest: CanvasUITests {
    func testAnnouncementsMatchWebOrder() {
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "262").tap()

        CourseNavigation.announcements.tap()

        Announcements.announcement(index: 0).waitToExist()
        XCTAssert(Announcements.announcement(index: 0).label.contains("Announcement Three"))
        XCTAssert(Announcements.announcement(index: 1).label.contains("Announcement Two"))
        XCTAssert(Announcements.announcement(index: 2).label.contains("Announcement One"))
    }

    func testViewAnnouncement() {
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "262").tap()

        CourseNavigation.announcements.tap()

        Announcements.announcement(index: 0).waitToExist()
        Announcements.announcement(index: 0).tapAt(.zero)

        AnnouncementDetail.text.waitToExist()
        XCTAssert(AnnouncementDetail.text.exists)
    }

    func testPreviewAnouncementAttachment() {
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "262").tap()
        CourseNavigation.announcements.tap()

        Announcements.announcement(index: 0).waitToExist()
        Announcements.announcement(index: 0).tapAt(.zero)
        XCUIElementWrapper(app.buttons["run.jpg"]).tap()
        app.find(type: .image).waitToExist()
    }
}
