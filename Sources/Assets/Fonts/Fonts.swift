// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length
// swiftlint:disable implicit_return

// MARK: - Fonts


// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum Gotham {
    internal static let black = FontConvertible(name: "Gotham-Black", family: "Gotham", path: "Gotham-Black.ttf")
    internal static let blackItalic = FontConvertible(name: "Gotham-BlackItalic", family: "Gotham", path: "Gotham-BlackItalic.ttf")
    internal static let bold = FontConvertible(name: "Gotham-Bold", family: "Gotham", path: "Gotham-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Gotham-BoldItalic", family: "Gotham", path: "Gotham-BoldItalic.ttf")
    internal static let book = FontConvertible(name: "Gotham-Book", family: "Gotham", path: "Gotham-Book.ttf")
    internal static let bookItalic = FontConvertible(name: "Gotham-BookItalic", family: "Gotham", path: "Gotham-BookItalic.ttf")
    internal static let light = FontConvertible(name: "Gotham-Light", family: "Gotham", path: "Gotham-Light.ttf")
    internal static let lightItalic = FontConvertible(name: "Gotham-LightItalic", family: "Gotham", path: "Gotham-LightItalic.ttf")
    internal static let medium = FontConvertible(name: "Gotham-Medium", family: "Gotham", path: "Gotham-Medium.ttf")
    internal static let mediumItalic = FontConvertible(name: "Gotham-MediumItalic", family: "Gotham", path: "Gotham-MediumItalic.ttf")
    internal static let thin = FontConvertible(name: "Gotham-Thin", family: "Gotham", path: "Gotham-Thin.ttf")
    internal static let thinItalic = FontConvertible(name: "Gotham-ThinItalic", family: "Gotham", path: "Gotham-ThinItalic.ttf")
    internal static let ultra = FontConvertible(name: "Gotham-Ultra", family: "Gotham", path: "Gotham-Ultra.ttf")
    internal static let ultraItalic = FontConvertible(name: "Gotham-UltraItalic", family: "Gotham", path: "Gotham-UltraItalic.ttf")
    internal static let extraLight = FontConvertible(name: "Gotham-XLight", family: "Gotham", path: "Gotham-XLight.ttf")
    internal static let extraLightItalic = FontConvertible(name: "Gotham-XLightItalic", family: "Gotham", path: "Gotham-XLightItalic.ttf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, book, bookItalic, light, lightItalic, medium, mediumItalic, thin, thinItalic, ultra, ultraItalic, extraLight, extraLightItalic]
  }
  internal static let allCustomFonts: [FontConvertible] = [Gotham.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(OSX)
  internal typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Font = UIFont
  #endif

  internal func font(size: CGFloat) -> Font! {
    return Font(font: self, size: size)
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    return Bundle.assetsBundle?.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}
