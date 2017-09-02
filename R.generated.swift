//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try font.validate()
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 color palettes.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 3 files.
  struct file {
    /// Resource file `DroidSerif-Bold.ttf`.
    static let droidSerifBoldTtf = Rswift.FileResource(bundle: R.hostingBundle, name: "DroidSerif-Bold", pathExtension: "ttf")
    /// Resource file `GoogleService-Info.plist`.
    static let googleServiceInfoPlist = Rswift.FileResource(bundle: R.hostingBundle, name: "GoogleService-Info", pathExtension: "plist")
    /// Resource file `TAOverlay.bundle`.
    static let tAOverlayBundle = Rswift.FileResource(bundle: R.hostingBundle, name: "TAOverlay", pathExtension: "bundle")
    
    /// `bundle.url(forResource: "DroidSerif-Bold", withExtension: "ttf")`
    static func droidSerifBoldTtf(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.droidSerifBoldTtf
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "GoogleService-Info", withExtension: "plist")`
    static func googleServiceInfoPlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.googleServiceInfoPlist
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "TAOverlay", withExtension: "bundle")`
    static func tAOverlayBundle(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.tAOverlayBundle
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 1 fonts.
  struct font: Rswift.Validatable {
    /// Font `DroidSerif-Bold`.
    static let droidSerifBold = Rswift.FontResource(fontName: "DroidSerif-Bold")
    
    /// `UIFont(name: "DroidSerif-Bold", size: ...)`
    static func droidSerifBold(size: CGFloat) -> UIKit.UIFont? {
      return UIKit.UIFont(resource: droidSerifBold, size: size)
    }
    
    static func validate() throws {
      if R.font.droidSerifBold(size: 42) == nil { throw Rswift.ValidationError(description:"[R.swift] Font 'DroidSerif-Bold' could not be loaded, is 'DroidSerif-Bold.ttf' added to the UIAppFonts array in this targets Info.plist?") }
    }
    
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 76 images.
  struct image {
    /// Image `Anonymous`.
    static let anonymous = Rswift.ImageResource(bundle: R.hostingBundle, name: "Anonymous")
    /// Image `Kindom_Blue`.
    static let kindom_Blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "Kindom_Blue")
    /// Image `Kindom_big_white`.
    static let kindom_big_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "Kindom_big_white")
    /// Image `Kindom_medium_white`.
    static let kindom_medium_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "Kindom_medium_white")
    /// Image `angryFace`.
    static let angryFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "angryFace")
    /// Image `arrow_down`.
    static let arrow_down = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_down")
    /// Image `arrow_up`.
    static let arrow_up = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_up")
    /// Image `arrow_white`.
    static let arrow_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_white")
    /// Image `bell_blue`.
    static let bell_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "bell_blue")
    /// Image `bell_red`.
    static let bell_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "bell_red")
    /// Image `bell_ring`.
    static let bell_ring = Rswift.ImageResource(bundle: R.hostingBundle, name: "bell_ring")
    /// Image `bell`.
    static let bell = Rswift.ImageResource(bundle: R.hostingBundle, name: "bell")
    /// Image `big_blue_ballot`.
    static let big_blue_ballot = Rswift.ImageResource(bundle: R.hostingBundle, name: "big_blue_ballot")
    /// Image `blackstar`.
    static let blackstar = Rswift.ImageResource(bundle: R.hostingBundle, name: "blackstar")
    /// Image `blue_wreath`.
    static let blue_wreath = Rswift.ImageResource(bundle: R.hostingBundle, name: "blue_wreath")
    /// Image `celscore_big_white`.
    static let celscore_big_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "celscore_big_white")
    /// Image `celscore_black`.
    static let celscore_black = Rswift.ImageResource(bundle: R.hostingBundle, name: "celscore_black")
    /// Image `celscore_white`.
    static let celscore_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "celscore_white")
    /// Image `cloud_big_blue`.
    static let cloud_big_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "cloud_big_blue")
    /// Image `cloud_big_red`.
    static let cloud_big_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "cloud_big_red")
    /// Image `cloud_red`.
    static let cloud_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "cloud_red")
    /// Image `cross`.
    static let cross = Rswift.ImageResource(bundle: R.hostingBundle, name: "cross")
    /// Image `crown_big_blue`.
    static let crown_big_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "crown_big_blue")
    /// Image `emptyCircle`.
    static let emptyCircle = Rswift.ImageResource(bundle: R.hostingBundle, name: "emptyCircle")
    /// Image `facebooklogo`.
    static let facebooklogo = Rswift.ImageResource(bundle: R.hostingBundle, name: "facebooklogo")
    /// Image `geometry_red`.
    static let geometry_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "geometry_red")
    /// Image `geometry_white`.
    static let geometry_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "geometry_white")
    /// Image `goldstar`.
    static let goldstar = Rswift.ImageResource(bundle: R.hostingBundle, name: "goldstar")
    /// Image `half_circle_blue`.
    static let half_circle_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "half_circle_blue")
    /// Image `half_circle_red`.
    static let half_circle_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "half_circle_red")
    /// Image `happyFace`.
    static let happyFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "happyFace")
    /// Image `ic_add_black`.
    static let ic_add_black = Rswift.ImageResource(bundle: R.hostingBundle, name: "ic_add_black")
    /// Image `ic_add_white`.
    static let ic_add_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "ic_add_white")
    /// Image `ic_close_white`.
    static let ic_close_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "ic_close_white")
    /// Image `ic_menu_white`.
    static let ic_menu_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "ic_menu_white")
    /// Image `ic_search_white`.
    static let ic_search_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "ic_search_white")
    /// Image `jamie_blue`.
    static let jamie_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "jamie_blue")
    /// Image `kindom_white`.
    static let kindom_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "kindom_white")
    /// Image `king_big_blue`.
    static let king_big_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "king_big_blue")
    /// Image `king_white`.
    static let king_white = Rswift.ImageResource(bundle: R.hostingBundle, name: "king_white")
    /// Image `king`.
    static let king = Rswift.ImageResource(bundle: R.hostingBundle, name: "king")
    /// Image `mainstar`.
    static let mainstar = Rswift.ImageResource(bundle: R.hostingBundle, name: "mainstar")
    /// Image `mini_angry`.
    static let mini_angry = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_angry")
    /// Image `mini_crown_blue`.
    static let mini_crown_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_crown_blue")
    /// Image `mini_crown_red`.
    static let mini_crown_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_crown_red")
    /// Image `mini_crown_yellow`.
    static let mini_crown_yellow = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_crown_yellow")
    /// Image `mini_death`.
    static let mini_death = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_death")
    /// Image `mini_empty`.
    static let mini_empty = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_empty")
    /// Image `mini_happy`.
    static let mini_happy = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_happy")
    /// Image `mini_nosmile`.
    static let mini_nosmile = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_nosmile")
    /// Image `mini_sadFace`.
    static let mini_sadFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_sadFace")
    /// Image `mini_smile`.
    static let mini_smile = Rswift.ImageResource(bundle: R.hostingBundle, name: "mini_smile")
    /// Image `news_icon`.
    static let news_icon = Rswift.ImageResource(bundle: R.hostingBundle, name: "news_icon")
    /// Image `news_red`.
    static let news_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "news_red")
    /// Image `nosmileFace`.
    static let nosmileFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "nosmileFace")
    /// Image `nuclear_red`.
    static let nuclear_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "nuclear_red")
    /// Image `past_circle`.
    static let past_circle = Rswift.ImageResource(bundle: R.hostingBundle, name: "past_circle")
    /// Image `sadFace`.
    static let sadFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "sadFace")
    /// Image `score_logo`.
    static let score_logo = Rswift.ImageResource(bundle: R.hostingBundle, name: "score_logo")
    /// Image `small_avatar`.
    static let small_avatar = Rswift.ImageResource(bundle: R.hostingBundle, name: "small_avatar")
    /// Image `small_crown`.
    static let small_crown = Rswift.ImageResource(bundle: R.hostingBundle, name: "small_crown")
    /// Image `smileFace`.
    static let smileFace = Rswift.ImageResource(bundle: R.hostingBundle, name: "smileFace")
    /// Image `sphere_blue_big`.
    static let sphere_blue_big = Rswift.ImageResource(bundle: R.hostingBundle, name: "sphere_blue_big")
    /// Image `sphere_blue`.
    static let sphere_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "sphere_blue")
    /// Image `star_black`.
    static let star_black = Rswift.ImageResource(bundle: R.hostingBundle, name: "star_black")
    /// Image `star_circle_blue`.
    static let star_circle_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "star_circle_blue")
    /// Image `star_circle`.
    static let star_circle = Rswift.ImageResource(bundle: R.hostingBundle, name: "star_circle")
    /// Image `star_icon`.
    static let star_icon = Rswift.ImageResource(bundle: R.hostingBundle, name: "star_icon")
    /// Image `thin_circle`.
    static let thin_circle = Rswift.ImageResource(bundle: R.hostingBundle, name: "thin_circle")
    /// Image `tomb_big_blue`.
    static let tomb_big_blue = Rswift.ImageResource(bundle: R.hostingBundle, name: "tomb_big_blue")
    /// Image `tomb_big_red`.
    static let tomb_big_red = Rswift.ImageResource(bundle: R.hostingBundle, name: "tomb_big_red")
    /// Image `topView`.
    static let topView = Rswift.ImageResource(bundle: R.hostingBundle, name: "topView")
    /// Image `twitterlogo`.
    static let twitterlogo = Rswift.ImageResource(bundle: R.hostingBundle, name: "twitterlogo")
    /// Image `white_avatar`.
    static let white_avatar = Rswift.ImageResource(bundle: R.hostingBundle, name: "white_avatar")
    /// Image `white_crown`.
    static let white_crown = Rswift.ImageResource(bundle: R.hostingBundle, name: "white_crown")
    /// Image `whitestar`.
    static let whitestar = Rswift.ImageResource(bundle: R.hostingBundle, name: "whitestar")
    
    /// `UIImage(named: "Anonymous", bundle: ..., traitCollection: ...)`
    static func anonymous(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.anonymous, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Kindom_Blue", bundle: ..., traitCollection: ...)`
    static func kindom_Blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.kindom_Blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Kindom_big_white", bundle: ..., traitCollection: ...)`
    static func kindom_big_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.kindom_big_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Kindom_medium_white", bundle: ..., traitCollection: ...)`
    static func kindom_medium_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.kindom_medium_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "angryFace", bundle: ..., traitCollection: ...)`
    static func angryFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.angryFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "arrow_down", bundle: ..., traitCollection: ...)`
    static func arrow_down(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_down, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "arrow_up", bundle: ..., traitCollection: ...)`
    static func arrow_up(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_up, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "arrow_white", bundle: ..., traitCollection: ...)`
    static func arrow_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "bell", bundle: ..., traitCollection: ...)`
    static func bell(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bell, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "bell_blue", bundle: ..., traitCollection: ...)`
    static func bell_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bell_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "bell_red", bundle: ..., traitCollection: ...)`
    static func bell_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bell_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "bell_ring", bundle: ..., traitCollection: ...)`
    static func bell_ring(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bell_ring, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "big_blue_ballot", bundle: ..., traitCollection: ...)`
    static func big_blue_ballot(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.big_blue_ballot, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "blackstar", bundle: ..., traitCollection: ...)`
    static func blackstar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.blackstar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "blue_wreath", bundle: ..., traitCollection: ...)`
    static func blue_wreath(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.blue_wreath, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "celscore_big_white", bundle: ..., traitCollection: ...)`
    static func celscore_big_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.celscore_big_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "celscore_black", bundle: ..., traitCollection: ...)`
    static func celscore_black(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.celscore_black, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "celscore_white", bundle: ..., traitCollection: ...)`
    static func celscore_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.celscore_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "cloud_big_blue", bundle: ..., traitCollection: ...)`
    static func cloud_big_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cloud_big_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "cloud_big_red", bundle: ..., traitCollection: ...)`
    static func cloud_big_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cloud_big_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "cloud_red", bundle: ..., traitCollection: ...)`
    static func cloud_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cloud_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "cross", bundle: ..., traitCollection: ...)`
    static func cross(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cross, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "crown_big_blue", bundle: ..., traitCollection: ...)`
    static func crown_big_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.crown_big_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "emptyCircle", bundle: ..., traitCollection: ...)`
    static func emptyCircle(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.emptyCircle, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "facebooklogo", bundle: ..., traitCollection: ...)`
    static func facebooklogo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.facebooklogo, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "geometry_red", bundle: ..., traitCollection: ...)`
    static func geometry_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.geometry_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "geometry_white", bundle: ..., traitCollection: ...)`
    static func geometry_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.geometry_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "goldstar", bundle: ..., traitCollection: ...)`
    static func goldstar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.goldstar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "half_circle_blue", bundle: ..., traitCollection: ...)`
    static func half_circle_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.half_circle_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "half_circle_red", bundle: ..., traitCollection: ...)`
    static func half_circle_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.half_circle_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "happyFace", bundle: ..., traitCollection: ...)`
    static func happyFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.happyFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ic_add_black", bundle: ..., traitCollection: ...)`
    static func ic_add_black(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ic_add_black, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ic_add_white", bundle: ..., traitCollection: ...)`
    static func ic_add_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ic_add_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ic_close_white", bundle: ..., traitCollection: ...)`
    static func ic_close_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ic_close_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ic_menu_white", bundle: ..., traitCollection: ...)`
    static func ic_menu_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ic_menu_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ic_search_white", bundle: ..., traitCollection: ...)`
    static func ic_search_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.ic_search_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "jamie_blue", bundle: ..., traitCollection: ...)`
    static func jamie_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.jamie_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "kindom_white", bundle: ..., traitCollection: ...)`
    static func kindom_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.kindom_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "king", bundle: ..., traitCollection: ...)`
    static func king(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.king, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "king_big_blue", bundle: ..., traitCollection: ...)`
    static func king_big_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.king_big_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "king_white", bundle: ..., traitCollection: ...)`
    static func king_white(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.king_white, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mainstar", bundle: ..., traitCollection: ...)`
    static func mainstar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mainstar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_angry", bundle: ..., traitCollection: ...)`
    static func mini_angry(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_angry, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_crown_blue", bundle: ..., traitCollection: ...)`
    static func mini_crown_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_crown_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_crown_red", bundle: ..., traitCollection: ...)`
    static func mini_crown_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_crown_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_crown_yellow", bundle: ..., traitCollection: ...)`
    static func mini_crown_yellow(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_crown_yellow, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_death", bundle: ..., traitCollection: ...)`
    static func mini_death(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_death, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_empty", bundle: ..., traitCollection: ...)`
    static func mini_empty(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_empty, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_happy", bundle: ..., traitCollection: ...)`
    static func mini_happy(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_happy, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_nosmile", bundle: ..., traitCollection: ...)`
    static func mini_nosmile(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_nosmile, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_sadFace", bundle: ..., traitCollection: ...)`
    static func mini_sadFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_sadFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "mini_smile", bundle: ..., traitCollection: ...)`
    static func mini_smile(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mini_smile, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "news_icon", bundle: ..., traitCollection: ...)`
    static func news_icon(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.news_icon, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "news_red", bundle: ..., traitCollection: ...)`
    static func news_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.news_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "nosmileFace", bundle: ..., traitCollection: ...)`
    static func nosmileFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.nosmileFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "nuclear_red", bundle: ..., traitCollection: ...)`
    static func nuclear_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.nuclear_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "past_circle", bundle: ..., traitCollection: ...)`
    static func past_circle(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.past_circle, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "sadFace", bundle: ..., traitCollection: ...)`
    static func sadFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sadFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "score_logo", bundle: ..., traitCollection: ...)`
    static func score_logo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.score_logo, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "small_avatar", bundle: ..., traitCollection: ...)`
    static func small_avatar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.small_avatar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "small_crown", bundle: ..., traitCollection: ...)`
    static func small_crown(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.small_crown, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "smileFace", bundle: ..., traitCollection: ...)`
    static func smileFace(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.smileFace, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "sphere_blue", bundle: ..., traitCollection: ...)`
    static func sphere_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sphere_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "sphere_blue_big", bundle: ..., traitCollection: ...)`
    static func sphere_blue_big(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sphere_blue_big, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "star_black", bundle: ..., traitCollection: ...)`
    static func star_black(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.star_black, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "star_circle", bundle: ..., traitCollection: ...)`
    static func star_circle(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.star_circle, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "star_circle_blue", bundle: ..., traitCollection: ...)`
    static func star_circle_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.star_circle_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "star_icon", bundle: ..., traitCollection: ...)`
    static func star_icon(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.star_icon, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "thin_circle", bundle: ..., traitCollection: ...)`
    static func thin_circle(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.thin_circle, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "tomb_big_blue", bundle: ..., traitCollection: ...)`
    static func tomb_big_blue(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tomb_big_blue, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "tomb_big_red", bundle: ..., traitCollection: ...)`
    static func tomb_big_red(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tomb_big_red, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "topView", bundle: ..., traitCollection: ...)`
    static func topView(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.topView, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "twitterlogo", bundle: ..., traitCollection: ...)`
    static func twitterlogo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.twitterlogo, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "white_avatar", bundle: ..., traitCollection: ...)`
    static func white_avatar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.white_avatar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "white_crown", bundle: ..., traitCollection: ...)`
    static func white_crown(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.white_crown, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "whitestar", bundle: ..., traitCollection: ...)`
    static func whitestar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.whitestar, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 1 nibs.
  struct nib {
    /// Nib `LaunchScreen`.
    static let launchScreen = _R.nib._LaunchScreen()
    
    /// `UINib(name: "LaunchScreen", in: bundle)`
    static func launchScreen(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.launchScreen)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 0 reuse identifiers.
  struct reuseIdentifier {
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 0 storyboards.
  struct storyboard {
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try nib.validate()
  }
  
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _LaunchScreen.validate()
    }
    
    struct _LaunchScreen: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "celscore_big_white") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'celscore_big_white' is used in nib 'LaunchScreen', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  struct storyboard {
    fileprivate init() {}
  }
  
  fileprivate init() {}
}