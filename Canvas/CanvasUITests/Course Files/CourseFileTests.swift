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

enum FilesList {
    static func file(id: String) -> Element {
        return app.find(id: "file-list.file-list-row.cell-file-\(id)")
    }
}

class CourseFileTests: CanvasUITests {
    func testPreviewCourseFile() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.files.tap()

        FilesList.file(id: "10528").waitToExist()
        FilesList.file(id: "10528").tap()

        // need be on the next page before checking for image
        sleep(3)
        app.find(type: .image).waitToExist()
    }

    func testLinkToPreviewOpensFile() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.pages.tap()
        PagesList.page(index: 2).tap()
        XCUIElementWrapper(app.links.firstMatch).tap()
        app.find(type: .image).waitToExist()
    }
}
