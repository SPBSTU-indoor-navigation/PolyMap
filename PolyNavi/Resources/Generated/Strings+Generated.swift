// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum ChoosingSearchController {
    /// Search
    internal static let searchPlaceholder = L10n.tr("Localizable", "ChoosingSearchController.searchPlaceholder")
  }

  internal enum MapInfo {
    internal enum Detail {
      /// Address
      internal static let address = L10n.tr("Localizable", "MapInfo.Detail.Address")
      /// Email
      internal static let email = L10n.tr("Localizable", "MapInfo.Detail.Email")
      /// Phone
      internal static let phone = L10n.tr("Localizable", "MapInfo.Detail.Phone")
      /// Website
      internal static let website = L10n.tr("Localizable", "MapInfo.Detail.Website")
    }
    internal enum Report {
      /// Favorites
      internal static let favorites = L10n.tr("Localizable", "MapInfo.Report.Favorites")
      /// Report an Issue
      internal static let issue = L10n.tr("Localizable", "MapInfo.Report.Issue")
    }
    internal enum Route {
      /// From
      internal static let from = L10n.tr("Localizable", "MapInfo.Route.From")
      /// Plan
      internal static let plan = L10n.tr("Localizable", "MapInfo.Route.Plan")
      /// Route
      internal static let route = L10n.tr("Localizable", "MapInfo.Route.Route")
      /// To
      internal static let to = L10n.tr("Localizable", "MapInfo.Route.To")
      internal enum Info {
        /// On paved roads
        internal static let asphalt = L10n.tr("Localizable", "MapInfo.Route.Info.Asphalt")
        /// Distance
        internal static let distance = L10n.tr("Localizable", "MapInfo.Route.Info.Distance")
        /// Fast pace
        internal static let fastTime = L10n.tr("Localizable", "MapInfo.Route.Info.FastTime")
        /// From:
        internal static let from = L10n.tr("Localizable", "MapInfo.Route.Info.From")
        /// Indoor
        internal static let indoor = L10n.tr("Localizable", "MapInfo.Route.Info.Indoor")
        /// Outdoor
        internal static let outdoor = L10n.tr("Localizable", "MapInfo.Route.Info.Outdoor")
        /// Parameters
        internal static let parameters = L10n.tr("Localizable", "MapInfo.Route.Info.Parameters")
        /// Search
        internal static let search = L10n.tr("Localizable", "MapInfo.Route.Info.Search")
        /// Allow service routes
        internal static let serviceRoute = L10n.tr("Localizable", "MapInfo.Route.Info.ServiceRoute")
        /// Time
        internal static let time = L10n.tr("Localizable", "MapInfo.Route.Info.Time")
        /// Route
        internal static let title = L10n.tr("Localizable", "MapInfo.Route.Info.Title")
        /// To:
        internal static let to = L10n.tr("Localizable", "MapInfo.Route.Info.To")
      }
    }
    internal enum Search {
      /// Buildings
      internal static let buildings = L10n.tr("Localizable", "MapInfo.Search.Buildings")
      /// No suggestion found
      internal static let emptySearchResult = L10n.tr("Localizable", "MapInfo.Search.EmptySearchResult")
      /// Favorites
      internal static let favorites = L10n.tr("Localizable", "MapInfo.Search.Favorites")
      /// Recent
      internal static let recent = L10n.tr("Localizable", "MapInfo.Search.Recent")
      /// Today
      internal static let today = L10n.tr("Localizable", "MapInfo.Search.Today")
    }
  }

  internal enum Settings {
    /// Select group
    internal static let settingOfGroup = L10n.tr("Localizable", "Settings.settingOfGroup")
    /// Select teacher
    internal static let settingOfTeacher = L10n.tr("Localizable", "Settings.settingOfTeacher")
    /// None
    internal static let statusOfGroup = L10n.tr("Localizable", "Settings.statusOfGroup")
    /// None
    internal static let statusOfInstitute = L10n.tr("Localizable", "Settings.statusOfInstitute")
    /// Settings
    internal static let title = L10n.tr("Localizable", "Settings.title")
    /// Group
    internal static let titleOfGroupCell = L10n.tr("Localizable", "Settings.titleOfGroupCell")
    /// Groups
    internal static let titleOfGroupsView = L10n.tr("Localizable", "Settings.titleOfGroupsView")
    /// Institute
    internal static let titleOfInstituteCell = L10n.tr("Localizable", "Settings.titleOfInstituteCell")
    /// Teacher
    internal static let titleOfTeacherCell = L10n.tr("Localizable", "Settings.titleOfTeacherCell")
    /// Teachers
    internal static let titleOfTeachersView = L10n.tr("Localizable", "Settings.titleOfTeachersView")
  }

  internal enum Timetable {
    /// Odd
    internal static let dataOddWeek = L10n.tr("Localizable", "Timetable.dataOddWeek")
    /// Even
    internal static let dateEvenWeek = L10n.tr("Localizable", "Timetable.dateEvenWeek")
    /// Settings
    internal static let editButton = L10n.tr("Localizable", "Timetable.editButton")
    /// Refresh
    internal static let emptyViewRefreshButton = L10n.tr("Localizable", "Timetable.emptyViewRefreshButton")
    /// No classes this week. You can chill out!
    internal static let emptyWeek = L10n.tr("Localizable", "Timetable.emptyWeek")
    /// Download
    internal static let iCal = L10n.tr("Localizable", "Timetable.iCal")
    /// Break
    internal static let lessonsBreak = L10n.tr("Localizable", "Timetable.lessonsBreak")
    /// No classes
    internal static let notHaveCurrentDay = L10n.tr("Localizable", "Timetable.notHaveCurrentDay")
    /// Timetable
    internal static let title = L10n.tr("Localizable", "Timetable.title")
    /// Today
    internal static let toTodayTimetable = L10n.tr("Localizable", "Timetable.toTodayTimetable")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
