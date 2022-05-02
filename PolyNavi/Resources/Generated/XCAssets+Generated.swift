// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal enum Annotation {
    internal enum Amenity {
      internal static let administration = ImageAsset(name: "administration")
      internal static let banch = ImageAsset(name: "banch")
      internal static let classroom = ImageAsset(name: "classroom")
      internal static let `default` = ImageAsset(name: "default")
      internal static let foodserviceCoffee = ImageAsset(name: "foodservice.coffee")
      internal static let laboratorium = ImageAsset(name: "laboratorium")
      internal static let lecture = ImageAsset(name: "lecture")
      internal static let parkingBicycle = ImageAsset(name: "parking.bicycle")
      internal static let parkingCar = ImageAsset(name: "parking.car")
      internal static let restroomFemale = ImageAsset(name: "restroom.female")
      internal static let restroomMale = ImageAsset(name: "restroom.male")
      internal static let security = ImageAsset(name: "security")
      internal static let souvenirs = ImageAsset(name: "souvenirs")
      internal static let stairs = ImageAsset(name: "stairs")
      internal static let vendingmachine = ImageAsset(name: "vendingmachine")
      internal static let wardrobe = ImageAsset(name: "wardrobe")
    }
    internal enum Buildings {
      internal static let gydro = ImageAsset(name: "Gydro")
    }
    internal enum Colors {
      internal static let attractionBackground = ColorAsset(name: "AttractionBackground")
      internal static let attractionBorder = ColorAsset(name: "AttractionBorder")
      internal static let attractionTextColor = ColorAsset(name: "AttractionTextColor")
      internal static let attractionTextStroke = ColorAsset(name: "AttractionTextStroke")
      internal static let stroke = ColorAsset(name: "Stroke")
      internal enum Units {
        internal static let administrationAnnotation = ColorAsset(name: "administration-annotation")
        internal static let foodserviceAnnotation = ColorAsset(name: "foodservice-annotation")
        internal static let foodserviceCoffeeAnnotation = ColorAsset(name: "foodservice.coffee-annotation")
        internal static let restroomAnnotation = ColorAsset(name: "restroom-annotation")
        internal static let securityAnnotation = ColorAsset(name: "security-annotation")
        internal static let souvenirsAnnotation = ColorAsset(name: "souvenirs-annotation")
        internal static let wardrobeAnnotation = ColorAsset(name: "wardrobe-annotation")
      }
    }
  }
  internal enum AppClip {
    internal static let appclipPreview = ImageAsset(name: "AppclipPreview")
    internal enum Badge {
      internal static let appclipCamera = ImageAsset(name: "appclip.camera")
      internal static let appclipNfcPrimary = ImageAsset(name: "appclip.nfc.primary")
      internal static let appclipNfcSecondary = ImageAsset(name: "appclip.nfc.secondary")
      internal static let appclipPrimary = ImageAsset(name: "appclip.primary")
      internal static let appclipSecondary = ImageAsset(name: "appclip.secondary")
      internal static let badge = ImageAsset(name: "badge")
      internal static let badgeText = ImageAsset(name: "badgeText")
    }
    internal enum Circle {
      internal static let appclipCBackground = ImageAsset(name: "appclip.c.background")
      internal static let appclipCCamera = ImageAsset(name: "appclip.c.camera")
      internal static let appclipCNfcPrimary = ImageAsset(name: "appclip.c.nfc.primary")
      internal static let appclipCNfcSecondary = ImageAsset(name: "appclip.c.nfc.secondary")
      internal static let appclipCPrimary = ImageAsset(name: "appclip.c.primary")
      internal static let appclipCSecondary = ImageAsset(name: "appclip.c.secondary")
    }
  }
  internal enum Colors {
    internal static let bottomSheetGroupped = ColorAsset(name: "BottomSheetGroupped")
    internal static let bottomSheetPlan = ColorAsset(name: "BottomSheetPlan")
    internal static let searchBarBackground = ColorAsset(name: "SearchBarBackground")
  }
  internal enum IMDFColors {
    internal static let buildingFill = ColorAsset(name: "BuildingFill")
    internal static let buildingLine = ColorAsset(name: "BuildingLine")
    internal static let buildingUnderLevel = ColorAsset(name: "BuildingUnderLevel")
    internal static let `default` = ColorAsset(name: "Default")
    internal enum Enviroment {
      internal static let crosswalk = ColorAsset(name: "crosswalk")
      internal static let fenceHeigth = ColorAsset(name: "fence.heigth")
      internal static let fenceMain = ColorAsset(name: "fence.main")
      internal static let forest = ColorAsset(name: "forest")
      internal static let grass = ColorAsset(name: "grass")
      internal static let roadDirt = ColorAsset(name: "road.dirt")
      internal static let roadMain = ColorAsset(name: "road.main")
      internal static let roadPedestrianMain = ColorAsset(name: "road.pedestrian.main")
      internal static let roadPedestrianSecond = ColorAsset(name: "road.pedestrian.second")
      internal static let steps = ColorAsset(name: "steps")
      internal static let tree = ColorAsset(name: "tree")
    }
    internal static let levelLine = ColorAsset(name: "LevelLine")
    internal enum Units {
      internal static let defaultLine = ColorAsset(name: "DefaultLine")
      internal static let indoorStairs = ColorAsset(name: "indoor.stairs")
      internal static let indoorSteps = ColorAsset(name: "indoor.steps")
      internal static let restricted = ColorAsset(name: "restricted")
      internal static let restroom = ColorAsset(name: "restroom")
      internal static let stairs = ColorAsset(name: "stairs")
      internal static let walkway = ColorAsset(name: "walkway")
    }
    internal static let venueFill = ColorAsset(name: "VenueFill")
  }
  internal enum Images {
    internal static let from = ImageAsset(name: "from")
    internal static let rotateBuilding = ImageAsset(name: "rotateBuilding")
    internal static let to = ImageAsset(name: "to")
  }
  internal enum Qr {
    internal static let qrBackground = ImageAsset(name: "qrBackground")
    internal static let qrData = ImageAsset(name: "qrData")
    internal static let qrDataFull = ImageAsset(name: "qrDataFull")
    internal static let qrLogo = ImageAsset(name: "qrLogo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
