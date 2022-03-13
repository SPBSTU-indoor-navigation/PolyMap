//
//  BottomSheet.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 13.03.2022.
//

@testable import PolyNavi
import XCTest

class BottomSheet: XCTestCase, BottomSheetDelegate {

    var transition: BottomSheetTransition!
    var bottomSheet: BottomSheetViewController!
    
    var delegatedProgress: CGFloat = 0
    var delegatedState: BottomSheetViewController.VerticalSize = .big
    var animComplition = false
    
    override func setUpWithError() throws {
        let vc = UIViewController()
        vc.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        
        transition = BottomSheetTransition(operation: .push, fromState: .big, size: .big, duration: 0.3, complition: { self.animComplition = true})
        bottomSheet = BottomSheetViewController(parentVC: vc, rootViewController: SearchVC())
        bottomSheet.bottomSheetDelegate = self
    }
    
    func testPosition() {
        let height = 500.0
        
        XCTAssertEqual(bottomSheet.position(for: .small), height - BottomSheetViewController.Constants.smallHeight, accuracy: 0.01)
        XCTAssertEqual(bottomSheet.position(for: .medium), height - BottomSheetViewController.Constants.mediumHeight, accuracy: 0.01)
        XCTAssertEqual(bottomSheet.position(for: .big), 20, accuracy: 0.01)
    }
    
    func testProgress() throws {
        bottomSheet.applyProgress(vc: nil, current: 0, from: 0, to: 1)
        XCTAssertEqual(delegatedProgress, 1, accuracy: 0.01)
        
        bottomSheet.applyProgress(vc: nil, current: 0.8, from: 0, to: 1)
        XCTAssertEqual(delegatedProgress, 0.2, accuracy: 0.01)
        
        bottomSheet.applyProgress(vc: nil, current: 1, from: 0, to: 1)
        XCTAssertEqual(delegatedProgress, 0, accuracy: 0.01)
    }
    
    func testChangeState() {
        for state: BottomSheetViewController.VerticalSize in [.big, .medium, .small] {
            bottomSheet.change(verticalSize: state, animated: false)
            XCTAssertEqual(delegatedState, state)
        }
        
        for state: BottomSheetViewController.VerticalSize in [.big, .medium, .small] {
            bottomSheet.change(verticalSize: state, animated: true)
            XCTAssertEqual(delegatedState, state)
        }
    }
    
    func testPushPopVC() {
        bottomSheet.change(verticalSize: .small, animated: false)
        bottomSheet.pushViewController(UIViewController(), animated: true)
        
        bottomSheet.popViewController(animated: true)
        XCTAssertEqual(bottomSheet.state, .small)
    }
    
    func testNextState() {
        bottomSheet.change(verticalSize: .small, animated: false)
        
        bottomSheet._endAnimation(velocity: 0)
        XCTAssertEqual(bottomSheet.state, .small)
        
        bottomSheet.change(verticalSize: .small, animated: false)
        bottomSheet._endAnimation(velocity: -10000)
        XCTAssertEqual(bottomSheet.state, .big)
        
        bottomSheet.change(verticalSize: .small, animated: false)
        bottomSheet._endAnimation(velocity: -2000)
        XCTAssertEqual(bottomSheet.state, .medium)
        
        bottomSheet.change(verticalSize: .big, animated: false)
        bottomSheet._endAnimation(velocity: 2000)
        XCTAssertEqual(bottomSheet.state, .medium)
        
        bottomSheet.change(verticalSize: .big, animated: false)
        bottomSheet._endAnimation(velocity: 10000)
        XCTAssertEqual(bottomSheet.state, .small)
    }
    
    func testTransitionVerticalMask() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
        
        let mask = transition.verticalMask(for: view, container: container, radius: 5, isOpen: false)
        
        XCTAssertEqual(mask.frame.size, CGSize(width: 500, height: 801))
    }
    
    func testTransitionHorizontalMask() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        let mask = transition.horizontalMask(for: view, container: container, radius: 5, isOpen: false)
        
        XCTAssertEqual(mask.frame.size, CGSize(width: 800, height: 550))
    }
    
    func onStateChange(from: BottomSheetViewController.VerticalSize, to: BottomSheetViewController.VerticalSize) {
        delegatedState = to
    }
    
    func onSizeChange(from: BottomSheetViewController.HorizontalSize?, to: BottomSheetViewController.HorizontalSize) { }
    
    func onProgressChange(progress: CGFloat) {
        delegatedProgress = progress
    }

}
