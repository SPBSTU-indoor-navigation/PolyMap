import XCTest
@testable import PolyNavi

class TimetableTest: XCTestCase {
    
    let timeTableProvider = TimetableProvider.shared
    let groupNumber: Int = 33843 // our group number - 3530904/80105
    let facultyNumber: Int = 95 // Institute of Computer Science and Technology
    let teacherNumber: Int = 5034 // Kotlirova Lina Pavlovna
    
    override func setUp() async throws {}
    
    func testLoadFaculties() {
        let loadFaculties = expectation(description: "Correct loading of faculties")
        timeTableProvider.loadFaculties { resp in
            switch resp {
            case .successWith(let data):
                if data.faculties.count == 0 { XCTFail("Count equal zero") }
                loadFaculties.fulfill()
            default:
                XCTFail("No internet")
            }
        }
        
        wait(for: [loadFaculties], timeout: 5)
    }
    
    func testLoadGroups() {
        let loadGroups = expectation(description: "Load group and find our group")
        let correctFacultyNumber = Faculty(id: 95, name: "", abbr: "")
        let incorrectFacultyNumber = Faculty(id: 3228, name: "", abbr: "")
        
        timeTableProvider.loadGroups(faculty: correctFacultyNumber) { resp in
            switch resp {
            case .successWith(let data):
                if data.groups.count == 0 { XCTFail("Count equal zero") }
                let group = data.groups
                let findGroup = group.first(where: { $0.id == self.groupNumber })
                if findGroup == nil {
                    XCTFail("Don't find group")
                }
                loadGroups.fulfill()
            default:
                XCTFail("Unable to load groups")
            }
        }
        
        let loadIncorectGroup = expectation(description: "Load group and find our group")
        
        timeTableProvider.loadGroups(faculty: incorrectFacultyNumber) { resp in
            switch resp {
            case .successWith(let _):
                XCTFail("Don't find group")
            default:
                loadIncorectGroup.fulfill()
            }
        }
        
        wait(for: [loadGroups, loadIncorectGroup], timeout: 5)
    }
    
    func testLoadTeacher() {
        let loadTeacher = expectation(description: "Loaded correct info about teacher")
        timeTableProvider.loadTeachers { res in
            switch res {
            case.successWith(let data):
                if data.teachers.count == 0 { XCTFail(" Zero teachers count" ) }
                
                let teachers = data.teachers
                let tryToFoundKnownTeachersID = teachers.first(where: { $0.id == self.teacherNumber })
                if tryToFoundKnownTeachersID == nil {
                    XCTFail("Didn't find known teacher id")
                }
                loadTeacher.fulfill()
            default:
                XCTFail("error loading")
            }
        }
        
        wait(for: [loadTeacher], timeout: 5)
    }
    
    func testTimetableRequest() {
        let loadGroupTimetableWithCache = expectation(description: "Success load of groups timetable from network or cash")
        
        timeTableProvider.loadTimetabe(id: groupNumber, filter: .groups, startDate: Date(), fromCache: true) { res in
            switch res {
            case .successWith(let data):
                guard
                    let groupID = data.group?.id,
                    groupID == self.groupNumber
                else {
                    XCTFail("Incorrect group number")
                    return
                }
                loadGroupTimetableWithCache.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        let loadTeacherTimetableWithCache = expectation(description: "Success load of teachers timetable from network or cash")
        
        timeTableProvider.loadTimetabe(id: teacherNumber, filter: .teachers, startDate: Date(), fromCache: true) { res in
            switch res {
            case.successWith(let data):
                guard
                    let teacher = data.teacher?.id,
                    teacher == self.teacherNumber
                else {
                    XCTFail("Incorrect teacher number")
                    return
                }
                loadTeacherTimetableWithCache.fulfill()
            default:
                XCTFail("Loading error")
            }
            
        }
        
        let loadGroupTimetableFromNetwork = expectation(description: "Success load of group timetable from network")
        let zombieGroup = Group(id: groupNumber, kind: 1, level: 1, name: "", spec: "", type: "", year: 1)
        timeTableProvider.loadTimetable(group: zombieGroup) { res in
            switch res {
            case.successWith(let data):
                guard
                    let groupID = data.group?.id,
                    groupID == self.groupNumber
                else {
                    XCTFail("Incorrect group number")
                    return
                }
                loadGroupTimetableFromNetwork.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        let loadTeacherTimetableFromNetwork = expectation(description: "Success load of teacher timetable from netweork")
        let zombieTeacher = Teacher(id: teacherNumber, oid: 1, full_name: "", first_name: "", middle_name: "", last_name: "", grade: "", chair: "")
        timeTableProvider.loadTimetable(teacher: zombieTeacher) { res in
            switch res {
            case .successWith(let data):
                guard
                    let teacherID = data.teacher?.id,
                    teacherID == self.teacherNumber
                else {
                    XCTFail("Incorrect teacher number")
                    return
                }
                loadTeacherTimetableFromNetwork.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        wait(
            for: [
                loadGroupTimetableWithCache,
                loadTeacherTimetableWithCache,
                loadGroupTimetableFromNetwork,
                loadTeacherTimetableFromNetwork
            ],
            timeout: 5
        )
    }
}
