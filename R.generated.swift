// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift

import Foundation
import Rswift
import UIKit

/// This `R` struct is code generated, and contains references to static resources.
struct R {
  /// This `R.color` struct is generated, and contains static references to 0 color palettes.
  struct color {
    private init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 2 files.
  struct file {
    /// Resource file `icomoon2.ttf`.
    static let icomoon2Ttf = FileResource(bundle: _R.hostingBundle, name: "icomoon2", pathExtension: "ttf")
    /// Resource file `TAOverlay.bundle`.
    static let tAOverlayBundle = FileResource(bundle: _R.hostingBundle, name: "TAOverlay", pathExtension: "bundle")
    
    /// `bundle.URLForResource("icomoon2", withExtension: "ttf")`
    static func icomoon2Ttf(_: Void) -> NSURL? {
      let fileResource = R.file.icomoon2Ttf
      return fileResource.bundle.url(forResource: fileResource) as NSURL?
    }
    
    /// `bundle.URLForResource("TAOverlay", withExtension: "bundle")`
    static func tAOverlayBundle(_: Void) -> NSURL? {
      let fileResource = R.file.tAOverlayBundle
      return fileResource.bundle.url(forResource: fileResource) as NSURL?
    }
    
    private init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 1 fonts.
  struct font {
    /// Font `icomoon`.
    static let icomoon = FontResource(fontName: "icomoon")
    
    /// `UIFont(name: "icomoon", size: ...)`
    static func icomoon(size: CGFloat) -> UIFont? {
      return UIFont(resource: icomoon, size: size)
    }
    
    private init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 65 images.
  struct image {
    /// Image `angryFace`.
    static let angryFace = ImageResource(bundle: _R.hostingBundle, name: "angryFace")
    /// Image `Anonymous`.
    static let anonymous = ImageResource(bundle: _R.hostingBundle, name: "Anonymous")
    /// Image `arrow_down`.
    static let arrow_down = ImageResource(bundle: _R.hostingBundle, name: "arrow_down")
    /// Image `arrow_up`.
    static let arrow_up = ImageResource(bundle: _R.hostingBundle, name: "arrow_up")
    /// Image `arrow_white`.
    static let arrow_white = ImageResource(bundle: _R.hostingBundle, name: "arrow_white")
    /// Image `astronaut_red`.
    static let astronaut_red = ImageResource(bundle: _R.hostingBundle, name: "astronaut_red")
    /// Image `celscore_big_white`.
    static let celscore_big_white = ImageResource(bundle: _R.hostingBundle, name: "celscore_big_white")
    /// Image `celscore_black`.
    static let celscore_black = ImageResource(bundle: _R.hostingBundle, name: "celscore_black")
    /// Image `celscore_white`.
    static let celscore_white = ImageResource(bundle: _R.hostingBundle, name: "celscore_white")
    /// Image `cloud_big_blue`.
    static let cloud_big_blue = ImageResource(bundle: _R.hostingBundle, name: "cloud_big_blue")
    /// Image `cloud_big_red`.
    static let cloud_big_red = ImageResource(bundle: _R.hostingBundle, name: "cloud_big_red")
    /// Image `cloud_red`.
    static let cloud_red = ImageResource(bundle: _R.hostingBundle, name: "cloud_red")
    /// Image `contract_blue_big`.
    static let contract_blue_big = ImageResource(bundle: _R.hostingBundle, name: "contract_blue_big")
    /// Image `contract_red_big`.
    static let contract_red_big = ImageResource(bundle: _R.hostingBundle, name: "contract_red_big")
    /// Image `court_red`.
    static let court_red = ImageResource(bundle: _R.hostingBundle, name: "court_red")
    /// Image `court_small_white`.
    static let court_small_white = ImageResource(bundle: _R.hostingBundle, name: "court_small_white")
    /// Image `court_white`.
    static let court_white = ImageResource(bundle: _R.hostingBundle, name: "court_white")
    /// Image `cross`.
    static let cross = ImageResource(bundle: _R.hostingBundle, name: "cross")
    /// Image `emptyCircle`.
    static let emptyCircle = ImageResource(bundle: _R.hostingBundle, name: "emptyCircle")
    /// Image `facebooklogo`.
    static let facebooklogo = ImageResource(bundle: _R.hostingBundle, name: "facebooklogo")
    /// Image `geometry_red`.
    static let geometry_red = ImageResource(bundle: _R.hostingBundle, name: "geometry_red")
    /// Image `happyFace`.
    static let happyFace = ImageResource(bundle: _R.hostingBundle, name: "happyFace")
    /// Image `head_red`.
    static let head_red = ImageResource(bundle: _R.hostingBundle, name: "head_red")
    /// Image `heart_black`.
    static let heart_black = ImageResource(bundle: _R.hostingBundle, name: "heart_black")
    /// Image `heart_white`.
    static let heart_white = ImageResource(bundle: _R.hostingBundle, name: "heart_white")
    /// Image `ic_add_black`.
    static let ic_add_black = ImageResource(bundle: _R.hostingBundle, name: "ic_add_black")
    /// Image `ic_add_white`.
    static let ic_add_white = ImageResource(bundle: _R.hostingBundle, name: "ic_add_white")
    /// Image `ic_close_white`.
    static let ic_close_white = ImageResource(bundle: _R.hostingBundle, name: "ic_close_white")
    /// Image `ic_menu_white`.
    static let ic_menu_white = ImageResource(bundle: _R.hostingBundle, name: "ic_menu_white")
    /// Image `ic_search_white`.
    static let ic_search_white = ImageResource(bundle: _R.hostingBundle, name: "ic_search_white")
    /// Image `info_black`.
    static let info_black = ImageResource(bundle: _R.hostingBundle, name: "info_black")
    /// Image `info_button`.
    static let info_button = ImageResource(bundle: _R.hostingBundle, name: "info_button")
    /// Image `info_white`.
    static let info_white = ImageResource(bundle: _R.hostingBundle, name: "info_white")
    /// Image `jurors_blue_big`.
    static let jurors_blue_big = ImageResource(bundle: _R.hostingBundle, name: "jurors_blue_big")
    /// Image `jurors_red_big`.
    static let jurors_red_big = ImageResource(bundle: _R.hostingBundle, name: "jurors_red_big")
    /// Image `mic_blue`.
    static let mic_blue = ImageResource(bundle: _R.hostingBundle, name: "mic_blue")
    /// Image `mic_red`.
    static let mic_red = ImageResource(bundle: _R.hostingBundle, name: "mic_red")
    /// Image `mic_yellow`.
    static let mic_yellow = ImageResource(bundle: _R.hostingBundle, name: "mic_yellow")
    /// Image `nosmileFace`.
    static let nosmileFace = ImageResource(bundle: _R.hostingBundle, name: "nosmileFace")
    /// Image `nuclear_red`.
    static let nuclear_red = ImageResource(bundle: _R.hostingBundle, name: "nuclear_red")
    /// Image `observatory_red`.
    static let observatory_red = ImageResource(bundle: _R.hostingBundle, name: "observatory_red")
    /// Image `planet_red`.
    static let planet_red = ImageResource(bundle: _R.hostingBundle, name: "planet_red")
    /// Image `sadFace`.
    static let sadFace = ImageResource(bundle: _R.hostingBundle, name: "sadFace")
    /// Image `scale_black`.
    static let scale_black = ImageResource(bundle: _R.hostingBundle, name: "scale_black")
    /// Image `scale_white`.
    static let scale_white = ImageResource(bundle: _R.hostingBundle, name: "scale_white")
    /// Image `score_black`.
    static let score_black = ImageResource(bundle: _R.hostingBundle, name: "score_black")
    /// Image `score_logo`.
    static let score_logo = ImageResource(bundle: _R.hostingBundle, name: "score_logo")
    /// Image `score_white`.
    static let score_white = ImageResource(bundle: _R.hostingBundle, name: "score_white")
    /// Image `smileFace`.
    static let smileFace = ImageResource(bundle: _R.hostingBundle, name: "smileFace")
    /// Image `spaceship_blue_big`.
    static let spaceship_blue_big = ImageResource(bundle: _R.hostingBundle, name: "spaceship_blue_big")
    /// Image `spaceship_red`.
    static let spaceship_red = ImageResource(bundle: _R.hostingBundle, name: "spaceship_red")
    /// Image `spaceship_red_big`.
    static let spaceship_red_big = ImageResource(bundle: _R.hostingBundle, name: "spaceship_red_big")
    /// Image `sphere_blue`.
    static let sphere_blue = ImageResource(bundle: _R.hostingBundle, name: "sphere_blue")
    /// Image `sphere_blue_big`.
    static let sphere_blue_big = ImageResource(bundle: _R.hostingBundle, name: "sphere_blue_big")
    /// Image `sphere_blue_mini`.
    static let sphere_blue_mini = ImageResource(bundle: _R.hostingBundle, name: "sphere_blue_mini")
    /// Image `sphere_red`.
    static let sphere_red = ImageResource(bundle: _R.hostingBundle, name: "sphere_red")
    /// Image `sphere_red_big`.
    static let sphere_red_big = ImageResource(bundle: _R.hostingBundle, name: "sphere_red_big")
    /// Image `sphere_red_mini`.
    static let sphere_red_mini = ImageResource(bundle: _R.hostingBundle, name: "sphere_red_mini")
    /// Image `sphere_yellow`.
    static let sphere_yellow = ImageResource(bundle: _R.hostingBundle, name: "sphere_yellow")
    /// Image `star_black`.
    static let star_black = ImageResource(bundle: _R.hostingBundle, name: "star_black")
    /// Image `star_icon`.
    static let star_icon = ImageResource(bundle: _R.hostingBundle, name: "star_icon")
    /// Image `topView`.
    static let topView = ImageResource(bundle: _R.hostingBundle, name: "topView")
    /// Image `twitterlogo`.
    static let twitterlogo = ImageResource(bundle: _R.hostingBundle, name: "twitterlogo")
    /// Image `worker_blue_big`.
    static let worker_blue_big = ImageResource(bundle: _R.hostingBundle, name: "worker_blue_big")
    /// Image `worker_red_big`.
    static let worker_red_big = ImageResource(bundle: _R.hostingBundle, name: "worker_red_big")
    
    /// `UIImage(named: "angryFace", bundle: ..., traitCollection: ...)`
    static func angryFace(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.angryFace, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "Anonymous", bundle: ..., traitCollection: ...)`
    static func anonymous(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.anonymous, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "arrow_down", bundle: ..., traitCollection: ...)`
    static func arrow_down(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.arrow_down, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "arrow_up", bundle: ..., traitCollection: ...)`
    static func arrow_up(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.arrow_up, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "arrow_white", bundle: ..., traitCollection: ...)`
    static func arrow_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.arrow_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "astronaut_red", bundle: ..., traitCollection: ...)`
    static func astronaut_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.astronaut_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "celscore_big_white", bundle: ..., traitCollection: ...)`
    static func celscore_big_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.celscore_big_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "celscore_black", bundle: ..., traitCollection: ...)`
    static func celscore_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.celscore_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "celscore_white", bundle: ..., traitCollection: ...)`
    static func celscore_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.celscore_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "cloud_big_blue", bundle: ..., traitCollection: ...)`
    static func cloud_big_blue(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.cloud_big_blue, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "cloud_big_red", bundle: ..., traitCollection: ...)`
    static func cloud_big_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.cloud_big_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "cloud_red", bundle: ..., traitCollection: ...)`
    static func cloud_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.cloud_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "contract_blue_big", bundle: ..., traitCollection: ...)`
    static func contract_blue_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.contract_blue_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "contract_red_big", bundle: ..., traitCollection: ...)`
    static func contract_red_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.contract_red_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "court_red", bundle: ..., traitCollection: ...)`
    static func court_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.court_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "court_small_white", bundle: ..., traitCollection: ...)`
    static func court_small_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.court_small_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "court_white", bundle: ..., traitCollection: ...)`
    static func court_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.court_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "cross", bundle: ..., traitCollection: ...)`
    static func cross(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.cross, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "emptyCircle", bundle: ..., traitCollection: ...)`
    static func emptyCircle(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.emptyCircle, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "facebooklogo", bundle: ..., traitCollection: ...)`
    static func facebooklogo(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.facebooklogo, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "geometry_red", bundle: ..., traitCollection: ...)`
    static func geometry_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.geometry_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "happyFace", bundle: ..., traitCollection: ...)`
    static func happyFace(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.happyFace, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "head_red", bundle: ..., traitCollection: ...)`
    static func head_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.head_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "heart_black", bundle: ..., traitCollection: ...)`
    static func heart_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.heart_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "heart_white", bundle: ..., traitCollection: ...)`
    static func heart_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.heart_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "ic_add_black", bundle: ..., traitCollection: ...)`
    static func ic_add_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.ic_add_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "ic_add_white", bundle: ..., traitCollection: ...)`
    static func ic_add_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.ic_add_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "ic_close_white", bundle: ..., traitCollection: ...)`
    static func ic_close_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.ic_close_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "ic_menu_white", bundle: ..., traitCollection: ...)`
    static func ic_menu_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.ic_menu_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "ic_search_white", bundle: ..., traitCollection: ...)`
    static func ic_search_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.ic_search_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "info_black", bundle: ..., traitCollection: ...)`
    static func info_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.info_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "info_button", bundle: ..., traitCollection: ...)`
    static func info_button(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.info_button, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "info_white", bundle: ..., traitCollection: ...)`
    static func info_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.info_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "jurors_blue_big", bundle: ..., traitCollection: ...)`
    static func jurors_blue_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.jurors_blue_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "jurors_red_big", bundle: ..., traitCollection: ...)`
    static func jurors_red_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.jurors_red_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "mic_blue", bundle: ..., traitCollection: ...)`
    static func mic_blue(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.mic_blue, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "mic_red", bundle: ..., traitCollection: ...)`
    static func mic_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.mic_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "mic_yellow", bundle: ..., traitCollection: ...)`
    static func mic_yellow(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.mic_yellow, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "nosmileFace", bundle: ..., traitCollection: ...)`
    static func nosmileFace(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.nosmileFace, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "nuclear_red", bundle: ..., traitCollection: ...)`
    static func nuclear_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.nuclear_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "observatory_red", bundle: ..., traitCollection: ...)`
    static func observatory_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.observatory_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "planet_red", bundle: ..., traitCollection: ...)`
    static func planet_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.planet_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sadFace", bundle: ..., traitCollection: ...)`
    static func sadFace(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sadFace, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "scale_black", bundle: ..., traitCollection: ...)`
    static func scale_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.scale_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "scale_white", bundle: ..., traitCollection: ...)`
    static func scale_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.scale_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "score_black", bundle: ..., traitCollection: ...)`
    static func score_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.score_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "score_logo", bundle: ..., traitCollection: ...)`
    static func score_logo(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.score_logo, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "score_white", bundle: ..., traitCollection: ...)`
    static func score_white(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.score_white, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "smileFace", bundle: ..., traitCollection: ...)`
    static func smileFace(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.smileFace, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "spaceship_blue_big", bundle: ..., traitCollection: ...)`
    static func spaceship_blue_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.spaceship_blue_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "spaceship_red", bundle: ..., traitCollection: ...)`
    static func spaceship_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.spaceship_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "spaceship_red_big", bundle: ..., traitCollection: ...)`
    static func spaceship_red_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.spaceship_red_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_blue", bundle: ..., traitCollection: ...)`
    static func sphere_blue(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_blue, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_blue_big", bundle: ..., traitCollection: ...)`
    static func sphere_blue_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_blue_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_blue_mini", bundle: ..., traitCollection: ...)`
    static func sphere_blue_mini(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_blue_mini, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_red", bundle: ..., traitCollection: ...)`
    static func sphere_red(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_red, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_red_big", bundle: ..., traitCollection: ...)`
    static func sphere_red_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_red_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_red_mini", bundle: ..., traitCollection: ...)`
    static func sphere_red_mini(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_red_mini, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "sphere_yellow", bundle: ..., traitCollection: ...)`
    static func sphere_yellow(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.sphere_yellow, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "star_black", bundle: ..., traitCollection: ...)`
    static func star_black(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.star_black, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "star_icon", bundle: ..., traitCollection: ...)`
    static func star_icon(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.star_icon, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "topView", bundle: ..., traitCollection: ...)`
    static func topView(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.topView, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "twitterlogo", bundle: ..., traitCollection: ...)`
    static func twitterlogo(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.twitterlogo, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "worker_blue_big", bundle: ..., traitCollection: ...)`
    static func worker_blue_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.worker_blue_big, compatibleWithTraitCollection: traitCollection)
    }
    
    /// `UIImage(named: "worker_red_big", bundle: ..., traitCollection: ...)`
    static func worker_red_big(compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
      return UIImage(resource: R.image.worker_red_big, compatibleWithTraitCollection: traitCollection)
    }
    
    private init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 1 nibs.
  struct nib {
    /// Nib `LaunchScreen`.
    static let launchScreen = _R.nib._LaunchScreen()
    
    /// `UINib(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void) -> UINib {
      return UINib(resource: R.nib.launchScreen)
    }
    
    private init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 0 reuse identifiers.
  struct reuseIdentifier {
    private init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    private init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 0 storyboards.
  struct storyboard {
    private init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    private init() {}
  }
  
  private init() {}
}

struct _R {
  static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(NSLocale.init)
  static let hostingBundle = Bundle(identifier: "com.GreyEcology.CelebrityScore") ?? Bundle.main
  
  struct nib {
    struct _LaunchScreen: NibResourceType {
      let bundle = _R.hostingBundle
      let name = "LaunchScreen"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIView
      }
      
      private init() {}
    }
    
    private init() {}
  }
  
  struct storyboard {
    private init() {}
  }
  
  private init() {}
}
