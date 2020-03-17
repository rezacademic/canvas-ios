//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core
@testable import TestsFoundation

class ConferenceListViewControllerTests: CoreTestCase {
    let course1 = ContextModel(.course, id: "1")
    lazy var controller = ConferenceListViewController.create(context: course1)

    override func setUp() {
        super.setUp()
        Clock.mockNow(DateComponents(calendar: .current, year: 2020, month: 3, day: 14).date!)
        environment.mockStore = false
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(controller.course, value: .make())
        api.mock(controller.conferences, value: GetConferencesRequest.Response(conferences: [
            .make(id: "1"),
            .make(id: "2"),
            .make(ended_at: Clock.now, id: "3"),
            .make(id: "4", started_at: Clock.now),
        ]))
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.titleSubtitleView.title, "Conferences")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 1)

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConferenceListCell
        XCTAssertEqual(cell?.titleLabel.text, "test conference")
        XCTAssertEqual(cell?.statusLabel.text, "In Progress")
        XCTAssertEqual(cell?.statusLabel.textColor, .named(.textSuccess))
        XCTAssertEqual(cell?.detailsLabel.text, "test description")

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ConferenceListCell
        XCTAssertEqual(cell?.statusLabel.text, "Not Started")
        XCTAssertEqual(cell?.statusLabel.textColor, .named(.textDark))

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConferenceListCell
        XCTAssertEqual(cell?.statusLabel.text, "Concluded Mar 14 at 12:00 AM")
        XCTAssertEqual(cell?.statusLabel.textColor, .named(.textDark))

        api.mock(controller.conferences, value: .init(conferences: [.make(title: "Pandemic playthrough") ]))
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false) // stops refreshing

        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConferenceListCell
        XCTAssertEqual(cell?.titleLabel.text, "Pandemic playthrough")
    }

    func testPaginatedRefresh() {
        controller.view.layoutIfNeeded()
        api.mock(controller.conferences, value: .init(conferences: [.make()]), response: HTTPURLResponse(next: "/courses/1/conferences?page=2"))
        api.mock(GetNextRequest(path: "/courses/1/conferences?page=2"), value: GetConferencesRequest.Response(conferences: [.make(id: "2")]))
        let tableView = controller.tableView!
        tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let loading = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? LoadingCell
        XCTAssertNotNil(loading)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ConferenceListCell
        XCTAssertEqual(cell.titleLabel.text, "test conference")
    }
}
