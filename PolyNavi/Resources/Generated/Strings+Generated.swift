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
    internal enum ExclRoute {
      internal enum Info {
        /// Finish exclusive mode
        internal static let close = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.Close")
        internal enum CloseAlert {
          /// Cancel
          internal static let cancel = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.Cancel")
          /// Finish
          internal static let end = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.End")
          /// Finish the exclusive mode will erase the route from the map. To re-view you will need to re-open the invitation
          internal static let message = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.Message")
          /// Finish exclusive mode
          internal static let title = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.Title")
        }
      }
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
        /// Route information
        internal static let routeInformation = L10n.tr("Localizable", "MapInfo.Route.Info.RouteInformation")
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

  internal enum Share {
    /// Generate
    internal static let create = L10n.tr("Localizable", "Share.Create")
    /// You can create a QR code associated with this route
    internal static let mainInfo = L10n.tr("Localizable", "Share.MainInfo")
    /// Code generation
    internal static let navigationTitle = L10n.tr("Localizable", "Share.NavigationTitle")
    internal enum BadgeVariant {
      /// Use logo
      internal static let badge = L10n.tr("Localizable", "Share.BadgeVariant.Badge")
      /// No logo
      internal static let circle = L10n.tr("Localizable", "Share.BadgeVariant.Circle")
      /// It is recommended to use the code with the logo, except in cases where it is impossible to meet the requirements for free space or if the code will be placed on disposable products
      internal static let info = L10n.tr("Localizable", "Share.BadgeVariant.Info")
      /// Badge variant
      internal static let title = L10n.tr("Localizable", "Share.BadgeVariant.Title")
    }
    internal enum CodeVariant {
      /// AppClip
      internal static let appClip = L10n.tr("Localizable", "Share.CodeVariant.AppClip")
      /// The QR code can contain a route from any one point to any other\n\nAppClip code can contain a route starting only at the main entrance to the campus, but it looks more beautiful
      internal static let info = L10n.tr("Localizable", "Share.CodeVariant.Info")
      /// QR
      internal static let qr = L10n.tr("Localizable", "Share.CodeVariant.QR")
      /// Code variant
      internal static let title = L10n.tr("Localizable", "Share.CodeVariant.Title")
    }
    internal enum ColorVariant {
      /// Color
      internal static let title = L10n.tr("Localizable", "Share.ColorVariant.Title")
      internal enum Preset {
        /// Black / White
        internal static let blackWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.blackWhite")
        /// Blue / White
        internal static let blueWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.blueWhite")
        /// Grey / White
        internal static let grayWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.grayWhite")
        /// Green / White
        internal static let greenWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.greenWhite")
        /// Indigo / White
        internal static let indigoWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.indigoWhite")
        /// Orange / White
        internal static let orangeWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.orangeWhite")
        /// Purple / White
        internal static let purpleWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.purpleWhite")
        /// Red / White
        internal static let redWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.redWhite")
        /// Teal / White
        internal static let tealWhite = L10n.tr("Localizable", "Share.ColorVariant.Preset.tealWhite")
        /// White / Black
        internal static let whiteBlack = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteBlack")
        /// White / Blue
        internal static let whiteBlue = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteBlue")
        /// White / Grey
        internal static let whiteGray = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteGray")
        /// White / Green
        internal static let whiteGreen = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteGreen")
        /// White / Indigo
        internal static let whiteIndigo = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteIndigo")
        /// White / Orange
        internal static let whiteOrange = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteOrange")
        /// White / Purple
        internal static let whitePurple = L10n.tr("Localizable", "Share.ColorVariant.Preset.whitePurple")
        /// White / Red
        internal static let whiteRed = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteRed")
        /// White / Teal
        internal static let whiteTeal = L10n.tr("Localizable", "Share.ColorVariant.Preset.whiteTeal")
      }
    }
    internal enum ErrorAlert {
      /// The code generation server is temporarily unavailable, try again later or contact the developer directly
      internal static let message = L10n.tr("Localizable", "Share.ErrorAlert.Message")
      /// Server is not available
      internal static let title = L10n.tr("Localizable", "Share.ErrorAlert.Title")
    }
    internal enum HelloText {
      /// Will be shown in a pop-up window after scanning the code
      internal static let info = L10n.tr("Localizable", "Share.HelloText.Info")
      /// Enter your welcome message
      internal static let placehodler = L10n.tr("Localizable", "Share.HelloText.Placehodler")
      /// Display welcome message
      internal static let title = L10n.tr("Localizable", "Share.HelloText.Title")
    }
    internal enum LogoVariant {
      /// Scan Only
      internal static let camera = L10n.tr("Localizable", "Share.LogoVariant.Camera")
      /// If you combine the code with an NFC tag, please select the NFC design. If you don't insert an NFC tag, please select «Scan Only» design
      internal static let info = L10n.tr("Localizable", "Share.LogoVariant.Info")
      /// NFC
      internal static let phone = L10n.tr("Localizable", "Share.LogoVariant.Phone")
      /// Logo
      internal static let title = L10n.tr("Localizable", "Share.LogoVariant.Title")
    }
    internal enum OpenURL {
      /// Continue
      internal static let `continue` = L10n.tr("Localizable", "Share.OpenURL.Continue")
      /// Shared with you the route
      internal static let info = L10n.tr("Localizable", "Share.OpenURL.Info")
      /// Author's messages
      internal static let message = L10n.tr("Localizable", "Share.OpenURL.Message")
      /// The route will be laid in "exclusive" mode, to exit it, swipe the curtain up and click on the "finish" button
      internal static let openInfo = L10n.tr("Localizable", "Share.OpenURL.OpenInfo")
      /// Welcome
      internal static let title = L10n.tr("Localizable", "Share.OpenURL.Title")
    }
    internal enum Result {
      /// Done
      internal static let done = L10n.tr("Localizable", "Share.Result.Done")
      /// Loading...
      internal static let loading = L10n.tr("Localizable", "Share.Result.Loading")
      /// Result
      internal static let navigationTitle = L10n.tr("Localizable", "Share.Result.NavigationTitle")
      /// Guidelines for using PDF
      internal static let sharePdf = L10n.tr("Localizable", "Share.Result.SharePdf")
      /// PNG bitmap image
      internal static let sharePng = L10n.tr("Localizable", "Share.Result.SharePng")
      /// SVG vector image
      internal static let shareSvg = L10n.tr("Localizable", "Share.Result.ShareSvg")
      /// Permalink
      internal static let shareUrl = L10n.tr("Localizable", "Share.Result.ShareUrl")
      internal enum ShareUrl {
        /// You can embed the link yourself in any type of codes, or simply send it in text form
        internal static let info = L10n.tr("Localizable", "Share.Result.ShareUrl.Info")
      }
    }
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
