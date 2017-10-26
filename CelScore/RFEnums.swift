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
enum SettingType: Int { case defaultListIndex = 0, loginTypeIndex, onCountdown, firstInterest, firstTrollWarning, lastVisit }
enum RatingsError: Int, Error { case ratingsNotFound = 0, userRatingsNotFound, ratingValueOutOfBounds, ratingIndexOutOfBounds }
enum CelebrityError: Int, Error { case notFound = 0 }
enum NetworkError: Int, Error { case notConnected = 1 }
enum PrevDay: Int { case Yesterday = 0, LastWeek, LastMonth }


//MARK: Misc.
enum RatingsType { case ratings, userRatings }
enum AWSDataType { case celebrity, ratings }
enum CognitoDataSet: String { case facebookInfo, twitterInfo, userRatings, userSettings }

//MARK: SocialLogin
enum SocialLogin: Int {
    case none = 0
    case facebook = 1
    case twitter = 2
    
    func serviceUnavailable() -> String {
        switch self {
        case .facebook: return "Sharing on Facebook is unavailable."
        case .twitter: return "Sharing on Twitter is unavailable."
        default: return "Social sharing is unavailable."
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
    case countdown
    case firstInterest
    case firstTrollWarning
    case loginError
    case networkError
    case permissionError
    
    func message(_ social: String = "") -> String {
        switch self {
        case .menuAccess: return "Log in with Twitter or Facebook."
        case .loginSuccess: return "Login was successful!"
        case .countdown: return "You will recieve a notification when a new celeb is crowned."
        case .firstInterest: return "Saved."
        case .firstTrollWarning: return "Your votes could eventually be discarded."
        case .loginError: return "\(social) login error: please try again."
        case .networkError: return "Network Error: please try again."
        case .permissionError: return "Unable to access your \(social) account."
        }
    }
    
    func logo() -> UIImage {
        switch self {
        case .menuAccess: return R.image.kindom_Blue()!
        case .loginSuccess: return R.image.kindom_Blue()!
        case .countdown: return R.image.crown_big_blue()!
        case .firstInterest: return R.image.sphere_blue()!
        case .firstTrollWarning: return R.image.nuclear_red()!
        case .loginError: return R.image.cloud_red()!
        case .networkError: return R.image.cloud_red()!
        case .permissionError: return R.image.cloud_red()!
        }
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
    case music
    case sports
    case news
    
    static func getAllNames() -> [String] {
        return [
            hollywood.name(),
            music.name(),
            sports.name(),
            news.name()
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
        case .news: return "Trending"
        }
    }
    
    func getId() -> Int {
        switch self {
        case .hollywood: return 0
        case .music: return 1
        case .sports: return 2
        case .news: return 4
        }
    }
}

//MARK: SnackIcon
enum SnackIcon: Int {
    case alert
    case news
    case lion
    case crown
    case star
    case nuclear
    
    func icon() -> UIImage {
        switch self {
        case .alert: return R.image.bell()!
        case .news: return R.image.bell_ring()!
        case .crown: return R.image.white_wreath()!
        case .lion: return R.image.white_lion()!
        case .star: return R.image.star_icon()!
        case .nuclear: return R.image.nuclear_mini()!
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
