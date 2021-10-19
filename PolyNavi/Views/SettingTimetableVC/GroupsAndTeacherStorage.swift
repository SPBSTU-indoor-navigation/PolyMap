//
//  GroupsAndTeacherStorage.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 17.10.2021.
//

import Foundation

enum TimetableFillter {
    case groups
    case teachers
}

class GroupsAndTeacherStorage {
    
    static let shared = GroupsAndTeacherStorage()
    
    private var institute: String? = nil
    private var groupNumber: String? = nil
    private var teachersName: String? = nil
    private var fillter: TimetableFillter = .groups
    
    public func getInstituteStringWithStatus() -> String {
        return institute ?? L10n.Settings.statusOfInstitute
    }
    
    public func getGroupStringWithStatus() -> String {
        return groupNumber ?? L10n.Settings.statusOfGroup
    }
}
