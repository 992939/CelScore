//
//  RFEnums.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation


//MARK: Error
enum SettingsError: Int, Error { case noCelebrityModels, noRatingsModel, noUserRatingsModel, noUser }
enum SettingType: Int { case defaultListIndex = 0, loginTypeIndex, onCountdown, firstInterest, firstVoteDisable, firstTrollWarning, lastVisit }
enum RatingsError: Int, Error { case ratingsNotFound = 0, userRatingsNotFound, ratingValueOutOfBounds, ratingIndexOutOfBounds }
enum ListError: Int, Error { case emptyList = 0, indexOutOfBounds, noLists }
enum CelebrityError: Int, Error { case notFound = 0 }
enum NetworkError: Int, Error { case notConnected = 1 }
enum PrevDay: Int { case Yesterday = 0, LastWeek, LastMonth }


//MARK: Misc.
enum RatingsType { case ratings, userRatings }
enum AWSDataType { case celebrity, list, ratings }
enum CognitoDataSet: String { case facebookInfo, twitterInfo, userRatings, userSettings }

//MARK: SocialLogin
enum SocialLogin: Int {
    case none = 0
    case facebook = 1
    case twitter = 2
    
    func serviceUnavailable() -> String {
        switch self {
        case .facebook: return "Sharing on Facebook is unavailable. Please check the settings and make sure your Facebook account is accessible."
        case .twitter: return "Sharing on Twitter is unavailable. Please check the settings and make sure your Twitter account is accessible."
        default: return "Social sharing is unavailable. Please check the settings and make sure your social accounts are accessible."
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .facebook: return "Facebook"
        case .twitter: return "Twitter"
        default: return ""
        }
    }
}

//MARK: OverlayInfo
enum OverlayInfo {
    case menuAccess
    case loginSuccess
    case maxFollow
    case countdown
    case firstInterest
    case firstVoteDisable
    case firstTrollWarning
    case loginError
    case networkError
    case permissionError
    
    func message(_ social: String = "") -> String {
        switch self {
        case .menuAccess: return "Log in with either Twitter or Facebook."
        case .loginSuccess: return "Login was successful!"
        case .maxFollow: return "You've reached the maximum number of celebs to watch."
        case .countdown: return "You will recieve a notification when a new celeb is crowned."
        case .firstInterest: return "Saved."
        case .firstVoteDisable: return "Log into the blue castle with Twitter or Facebook."
        case .firstTrollWarning: return "Below a level of negativity, all your votes will be discarded."
        case .loginError: return "Settings check:\n- Network connection is on.\n- Date & Time is set automatically.\n- Celeb&Noble is enabled with your \(social) account.\n\nPlease contact us if the problem persists."
        case .networkError: return "Try again and please contact us if the problem persists."
        case .permissionError: return "Unable to authenticate using your \(social) account.\n\nCheck that Celeb&Noble is enabled with your \(social) account.\n\nPlease contact us if the problem persists."
        }
    }
    
    func logo() -> UIImage {
        switch self {
        case .menuAccess: return R.image.kindom_Blue()!
        case .loginSuccess: return R.image.kindom_Blue()!
        case .maxFollow: return R.image.king()!
        case .countdown: return R.image.crown_big_blue()!
        case .firstInterest: return R.image.sphere_blue()!
        case .firstVoteDisable: return R.image.king()!
        case .firstTrollWarning: return R.image.nuclear_red()!
        case .loginError: return R.image.cloud_red()!
        case .networkError: return R.image.cloud_red()!
        case .permissionError: return R.image.cloud_red()!
        }
    }
    
    static func getOptions() -> TAOverlayOptions {
        return [.overlaySizeRoundedRect, .overlayDismissTap, .overlayAnimateTransistions, .overlayShadow]
    }
}

//MARK: Info
enum Info: Int {
    case firstName
    case middleName
    case lastName
    case from
    case birthdate
    case height
    case zodiac
    case status
    case throne
    case networth
    
    static func getAll() -> [String] {
        return [
            firstName.name(),
            middleName.name(),
            lastName.name(),
            from.name(),
            birthdate.name(),
            height.name(),
            zodiac.name(),
            status.name(),
            throne.name(),
            networth.name()
        ]
    }
    
    func name() -> String {
        switch self {
        case .firstName: return "First Name"
        case .middleName: return "Middle Name"
        case .lastName: return "Last Name"
        case .from: return "From"
        case .birthdate: return "Date of Birth"
        case .height: return "Height"
        case .zodiac: return "Zodiac"
        case .status: return "Status"
        case .throne: return "On The Throne"
        case .networth: return "Networth"
        }
    }
}

//MARK: Qualities
enum Qualities: Int {
    case talent
    case originality
    case authenticity
    case generosity
    case roleModel
    case hardWork
    case smarts
    case charisma
    case elegance
    case sexAppeal
    
    static func getAll(isMale: Bool = true) -> [String] {
        return [
            talent.name(),
            originality.name(),
            authenticity.name(),
            generosity.name(),
            roleModel.name(),
            hardWork.name(),
            smarts.name(),
            charisma.name(),
            elegance.name(),
            sexAppeal.name(isMale: isMale)
        ]
    }

    func name(isMale: Bool = true) -> String {
        switch self {
        case .talent: return "Talent"
        case .originality: return "Originality"
        case .authenticity: return "Authenticity"
        case .generosity: return "Generosity"
        case .roleModel: return "Role Model"
        case .hardWork: return "Work Ethic"
        case .smarts: return "Smarts"
        case .charisma: return "Charisma"
        case .elegance: return "Elegance"
        case .sexAppeal: return isMale == true ? "Good Looks" : "Beauty"
        }
    }
}

//MARK: BarTrends
enum BarTrend: String {
    case BBBB
    case BRBB
    case BBRB
    case BBBR
    case BBRR
    case BRRB
    case BRBR
    case BRRR
    case RBBB
    case RBBR
    case RBRR
    case RBRB
    case RRRB
    case RRBB
    case RRBR
    case RRRR
    case ZZZZ
    
    func icon() -> UIImage {
        switch self {
        case .BBBB: return R.image.bBBB()!
        case .BRBB: return R.image.bRBB()!
        case .BBRB: return R.image.bBRB()!
        case .BBBR: return R.image.bBBR()!
        case .BBRR: return R.image.bBRR()!
        case .BRRB: return R.image.bRRB()!
        case .BRBR: return R.image.bRBR()!
        case .BRRR: return R.image.bRRR()!
        case .RBBB: return R.image.rBBB()!
        case .RBBR: return R.image.rBBR()!
        case .RBRR: return R.image.rBRR()!
        case .RBRB: return R.image.rBRB()!
        case .RRRB: return R.image.rRRB()!
        case .RRBB: return R.image.rRBB()!
        case .RRRR: return R.image.rRRR()!
        case .RRBR: return R.image.rRBR()!
        case .ZZZZ: return R.image.zZZZ()!
        }
    }
}


//MARK: ListInfo
enum ListInfo : Int {
    case hollywood
    case hipHop
    case sports
    case music
    case news
    
    static func getAllNames() -> [String] {
        return [
            hollywood.name(),
            music.name(),
            sports.name(),
            hipHop.name(),
            news.name()
        ]
    }
    
    static func getAllIDs() -> [String] {
        return [
            hollywood.getId(),
            hipHop.getId(),
            sports.getId(),
            music.getId(),
            news.getId()
        ]
    }
    
    static func getCount() -> Int {
        var max: Int = 0
        while let _ = ListInfo(rawValue: max) { max += 1 }
        return max
    }
    
    func name() -> String {
        switch self {
        case .hollywood: return "Hollywood"
        case .music: return "Music"
        case .sports: return "Sports"
        case .hipHop: return "Hip Hop"
        case .news: return "Trending"
        }
    }
    
    func getId() -> String {
        switch self {
        case .hollywood: return "0001"
        case .music: return "0003"
        case .sports: return "0002"
        case .hipHop: return "0004"
        case .news: return "0005"
        }
    }
    
    func getIndex() -> Int {
        switch self {
        case .hollywood: return 1
        case .music: return 2
        case .sports: return 3
        case .hipHop: return 4
        case .news: return 5
        }
    }
}

//MARK: SnackIcon
enum SnackIcon: Int {
    case alert
    case crown
    case star
    
    func icon() -> UIImage {
        switch self {
        case .alert: return R.image.bell()!
        case .crown: return R.image.white_wreath()!
        case .star: return R.image.star_icon()!
        }
    }
}

//MARK: Zodiac
enum Zodiac : Int {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    func name() -> String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }
}
