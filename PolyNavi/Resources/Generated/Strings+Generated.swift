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

  internal enum HelloPopup {
    /// Continue
    internal static let `continue` = L10n.tr("Localizable", "HelloPopup.Continue")
    /// Welcome to PolyMap!
    internal static let title = L10n.tr("Localizable", "HelloPopup.Title")
    internal enum Indoor {
      /// Simply zoom in to the building or select an annotation and click the "Plan " button to view detailed indoor map.
      internal static let message = L10n.tr("Localizable", "HelloPopup.Indoor.Message")
      /// Indoor map
      internal static let title = L10n.tr("Localizable", "HelloPopup.Indoor.Title")
    }
    internal enum Route {
      /// Select your destination and press "Route" button
      internal static let message = L10n.tr("Localizable", "HelloPopup.Route.Message")
      /// Build routes
      internal static let title = L10n.tr("Localizable", "HelloPopup.Route.Title")
    }
    internal enum Share {
      /// Select the "Share" option in the context menu of the route to share a route. It is possible to share as a QR or AppClip code.
      internal static let message = L10n.tr("Localizable", "HelloPopup.Share.Message")
      /// Share
      internal static let title = L10n.tr("Localizable", "HelloPopup.Share.Title")
    }
  }

  internal enum MapInfo {
    /// Share
    internal static let share = L10n.tr("Localizable", "MapInfo.Share")
    internal enum Detail {
      /// Address
      internal static let address = L10n.tr("Localizable", "MapInfo.Detail.Address")
      /// Email
      internal static let email = L10n.tr("Localizable", "MapInfo.Detail.Email")
      /// Phone
      internal static let phone = L10n.tr("Localizable", "MapInfo.Detail.Phone")
      /// See Details
      internal static let title = L10n.tr("Localizable", "MapInfo.Detail.Title")
      /// Website
      internal static let website = L10n.tr("Localizable", "MapInfo.Detail.Website")
      internal enum EmptyPlan {
        /// Unfortunately this building does not have a floor plan, if you have a floor plan for this building or know who might have it, please contact the developer
        internal static let message = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Message")
        /// Write
        internal static let `open` = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Open")
        /// No building floor plan
        internal static let title = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Title")
        internal enum Email {
          /// Copy
          internal static let copy = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Email.Copy")
          /// Open mail
          internal static let `open` = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Email.Open")
        }
        internal enum Mail {
          /// Hi, I would like to help with the layout of the {BUILDING}
          internal static let message = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Mail.Message")
          /// Building plan PolyMap
          internal static let subject = L10n.tr("Localizable", "MapInfo.Detail.EmptyPlan.Mail.Subject")
        }
      }
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
          /// Completing the exclusive mode will erase the route from the map. You should reopen the invitation to view again
          internal static let message = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.Message")
          /// Finish exclusive mode
          internal static let title = L10n.tr("Localizable", "MapInfo.ExclRoute.Info.CloseAlert.Title")
        }
      }
    }
    internal enum Report {
      /// Report an Issue
      internal static let issue = L10n.tr("Localizable", "MapInfo.Report.Issue")
      internal enum Favorites {
        /// Add to Favorites
        internal static let add = L10n.tr("Localizable", "MapInfo.Report.Favorites.Add")
        /// Remove from Favorites
        internal static let remove = L10n.tr("Localizable", "MapInfo.Report.Favorites.Remove")
      }
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
      internal enum Share {
        /// QR code or AppClip code
        internal static let appClipQR = L10n.tr("Localizable", "MapInfo.Route.Share.AppClipQR")
        /// Share
        internal static let title = L10n.tr("Localizable", "MapInfo.Route.Share.Title")
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
      /// Recommendation
      internal static let recomendation = L10n.tr("Localizable", "MapInfo.Search.Recomendation")
      /// Today
      internal static let today = L10n.tr("Localizable", "MapInfo.Search.Today")
    }
  }

  internal enum Present {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Present.Cancel")
  }

  internal enum ReportAnIssue {
    /// no
    internal static let disable = L10n.tr("Localizable", "ReportAnIssue.Disable")
    /// yes
    internal static let enable = L10n.tr("Localizable", "ReportAnIssue.Enable")
    /// Send
    internal static let send = L10n.tr("Localizable", "ReportAnIssue.Send")
    /// Sorry, we couldn't connect to the server, please try again later
    internal static let serverError = L10n.tr("Localizable", "ReportAnIssue.ServerError")
    /// Issue report sent successfully
    internal static let succes = L10n.tr("Localizable", "ReportAnIssue.Succes")
    /// Report
    internal static let title = L10n.tr("Localizable", "ReportAnIssue.Title")
    internal enum Error {
      /// Issue in the building
      internal static let annotation = L10n.tr("Localizable", "ReportAnIssue.Error.Annotation")
      /// Issue in the route
      internal static let route = L10n.tr("Localizable", "ReportAnIssue.Error.Route")
    }
    internal enum Message {
      /// It is recommended to leave a contact for feedback, for example, an email address or a Telegram account
      internal static let footer = L10n.tr("Localizable", "ReportAnIssue.Message.Footer")
      /// Describe the issue
      internal static let placeholder = L10n.tr("Localizable", "ReportAnIssue.Message.Placeholder")
      /// Describe the issue in detail
      internal static let title = L10n.tr("Localizable", "ReportAnIssue.Message.Title")
    }
  }

  internal enum Settings {
    /// Select group
    internal static let settingOfGroup = L10n.tr("Localizable", "Settings.settingOfGroup")
    /// Select professor
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
    /// Professor
    internal static let titleOfTeacherCell = L10n.tr("Localizable", "Settings.titleOfTeacherCell")
    /// Professors
    internal static let titleOfTeachersView = L10n.tr("Localizable", "Settings.titleOfTeachersView")
  }

  internal enum Share {
    /// Allow parameter changes
    internal static let allowParameterChange = L10n.tr("Localizable", "Share.AllowParameterChange")
    /// Check connection...
    internal static let connectionCheck = L10n.tr("Localizable", "Share.ConnectionCheck")
    /// Server unavailable
    internal static let connectionError = L10n.tr("Localizable", "Share.ConnectionError")
    /// Generate
    internal static let create = L10n.tr("Localizable", "Share.Create")
    /// You can generate a QR or AppClip code. After scanning the code an application with a route will open and a welcome message will be displayed.\n\nIf user has not installed the application yet, a simplified blitz version with similar functionality will open
    internal static let mainInfo = L10n.tr("Localizable", "Share.MainInfo")
    /// Code generation
    internal static let navigationTitle = L10n.tr("Localizable", "Share.NavigationTitle")
    internal enum AllowParameterChange {
      /// Allow user to change route building parameters (service routes/paved roads)
      internal static let description = L10n.tr("Localizable", "Share.AllowParameterChange.Description")
    }
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
      /// QR code can be scanned on any device\n\nAppClip code can only be scanned by iOS devices
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
        /// Black
        internal static let black = L10n.tr("Localizable", "Share.ColorVariant.Preset.black")
        /// Blue
        internal static let blue = L10n.tr("Localizable", "Share.ColorVariant.Preset.blue")
        /// Grey
        internal static let gray = L10n.tr("Localizable", "Share.ColorVariant.Preset.gray")
        /// Green
        internal static let green = L10n.tr("Localizable", "Share.ColorVariant.Preset.green")
        /// Indigo
        internal static let indigo = L10n.tr("Localizable", "Share.ColorVariant.Preset.indigo")
        /// Orange
        internal static let orange = L10n.tr("Localizable", "Share.ColorVariant.Preset.orange")
        /// Purple
        internal static let purple = L10n.tr("Localizable", "Share.ColorVariant.Preset.purple")
        /// Red
        internal static let red = L10n.tr("Localizable", "Share.ColorVariant.Preset.red")
        /// Teal
        internal static let teal = L10n.tr("Localizable", "Share.ColorVariant.Preset.teal")
      }
      internal enum Preview {
        /// Change color
        internal static let changeColor = L10n.tr("Localizable", "Share.ColorVariant.Preview.ChangeColor")
      }
    }
    internal enum ErrorAlert {
      /// The code generation server is temporarily unavailable, try again later or contact the developer directly
      internal static let message = L10n.tr("Localizable", "Share.ErrorAlert.Message")
      internal enum AppClip {
        /// The AppClip code generation server is temporarily unavailable, try again later or contact the developer directly
        internal static let message = L10n.tr("Localizable", "Share.ErrorAlert.AppClip.Message")
      }
      internal enum Qr {
        /// The QR code generation server is temporarily unavailable, try again later or contact the developer directly
        internal static let message = L10n.tr("Localizable", "Share.ErrorAlert.QR.Message")
      }
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
      /// If you combine the code with an NFC tag, please select the NFC design. If you do not insert an NFC tag, please select «Scan Only» design
      internal static let info = L10n.tr("Localizable", "Share.LogoVariant.Info")
      /// NFC
      internal static let phone = L10n.tr("Localizable", "Share.LogoVariant.Phone")
      /// Logo
      internal static let title = L10n.tr("Localizable", "Share.LogoVariant.Title")
    }
    internal enum OpenURL {
      /// Continue
      internal static let `continue` = L10n.tr("Localizable", "Share.OpenURL.Continue")
      /// The route was shared with you
      internal static let info = L10n.tr("Localizable", "Share.OpenURL.Info")
      /// Failed to connect to the server, may not be connected to the internet
      internal static let internetError = L10n.tr("Localizable", "Share.OpenURL.InternetError")
      /// Author's messages
      internal static let message = L10n.tr("Localizable", "Share.OpenURL.Message")
      /// The route will be laid in "exclusive" mode. Swipe the curtain up and click on the "finish" button to exit it
      internal static let openInfo = L10n.tr("Localizable", "Share.OpenURL.OpenInfo")
      /// Welcome
      internal static let title = L10n.tr("Localizable", "Share.OpenURL.Title")
    }
    internal enum QRLogoVariant {
      /// No logo
      internal static let `none` = L10n.tr("Localizable", "Share.QRLogoVariant.None")
      /// Logo
      internal static let title = L10n.tr("Localizable", "Share.QRLogoVariant.Title")
      /// Use logo
      internal static let use = L10n.tr("Localizable", "Share.QRLogoVariant.Use")
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
        /// You can embed the link yourself in any type of codes or simply send it in text form
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
