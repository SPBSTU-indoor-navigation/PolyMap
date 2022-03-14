//
//  MapInfoPagesTest.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 14.03.2022.
//

import XCTest
@testable import PolyNavi

class MapInfoPagesTest: XCTestCase {
    var unitDetail: UnitDetailVC!
    var mapSearchInfo: SearchVC!
    var mapDetailInfo: MapDetailInfo!
    
    override func setUpWithError() throws {
        unitDetail = UnitDetailVC(closable: true)
        mapSearchInfo = SearchVC(closable: false)
        
        mapDetailInfo = MapDetailInfo()
        mapDetailInfo.title = "title"
        mapDetailInfo.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: true))
        mapDetailInfo.sections.append(MapDetailInfo.Detail(phone: "111", email: "email", website: "website", address: "address"))
        mapDetailInfo.sections.append(MapDetailInfo.Report(favorite: true, report: true))
        
        unitDetail.viewDidLoad()
    }
    
    func testNumberOfSection() {
        unitDetail.view.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        XCTAssertEqual(unitDetail.numberOfSections(in: unitDetail.tableView), 0)
        
        let detail = MapDetailInfo()
        detail.title = "title"
        unitDetail.configurate(mapDetailInfo: detail)
        
        XCTAssertEqual(unitDetail.numberOfSections(in: unitDetail.tableView), 0)
        
        detail.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: true))
        unitDetail.configurate(mapDetailInfo: detail)
        XCTAssertEqual(unitDetail.numberOfSections(in: unitDetail.tableView), 1)
        
        detail.sections.append(MapDetailInfo.Detail(phone: "111", email: "email", website: "website", address: nil))
        unitDetail.configurate(mapDetailInfo: detail)
        XCTAssertEqual(unitDetail.numberOfSections(in: unitDetail.tableView), 2)
    }
    
    func testViewForHeaderInSection() {
        unitDetail.configurate(mapDetailInfo: mapDetailInfo)
        XCTAssertEqual(unitDetail.tableView(unitDetail.tableView, viewForHeaderInSection: 0), nil)
        XCTAssertEqual(unitDetail.tableView(unitDetail.tableView, viewForHeaderInSection: 2), nil)
        let header = unitDetail.tableView(unitDetail.tableView, viewForHeaderInSection: 1)
        XCTAssert(header is TitleHeader)
    }
    
    func testHeightForHeaderInSection() {
        unitDetail.configurate(mapDetailInfo: mapDetailInfo)
        XCTAssertEqual(unitDetail.tableView(unitDetail.tableView, heightForHeaderInSection: 0), 0)
        XCTAssertEqual(unitDetail.tableView(unitDetail.tableView, heightForHeaderInSection: 1), UITableView.automaticDimension)
    }
    
    func testWillSelectRowAt() {
        unitDetail.configurate(mapDetailInfo: mapDetailInfo)
        let first = IndexPath(item: 0, section: 0)
        XCTAssertEqual(unitDetail.tableView(unitDetail.tableView, willSelectRowAt: first), first)
    }
    
    func testCellForRowAt() {
        unitDetail.configurate(mapDetailInfo: mapDetailInfo)
        
        func cellFor(_ indexPath: IndexPath) -> UITableViewCell {
            return unitDetail.tableView(unitDetail.tableView, cellForRowAt: indexPath)
        }
        
        
        XCTAssert(cellFor(IndexPath(item: 0, section: 0)) is RouteInfoCell)
        XCTAssert(cellFor(IndexPath(item: 0, section: 1)) is DetailCell)
        XCTAssert(cellFor(IndexPath(item: 2, section: 1)) is DetailCell)
        
    }
    
    func testCancelEdit() {
        mapSearchInfo.searchBarShouldBeginEditing(mapSearchInfo.searchBar)
        XCTAssert(mapSearchInfo.isSearch)
        
        mapSearchInfo.searchBarCancelButtonClicked(mapSearchInfo.searchBar)
        XCTAssertFalse(mapSearchInfo.isSearch)
    }
    
    func testStateChange() {
        mapSearchInfo.searchBarShouldBeginEditing(mapSearchInfo.searchBar)
        mapSearchInfo.onStateChange(verticalSize: .medium)
        XCTAssertFalse(mapSearchInfo.isSearch)
    }

}
