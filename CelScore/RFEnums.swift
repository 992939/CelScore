//
//  RFEnums.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation
import Material


//MARK: Error
enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
enum ListError: ErrorType { case EmptyList, IndexOutOfBounds, NoLists }
enum CelebrityError: ErrorType { case NotFound }

//MARK: Misc.
enum RatingsType { case Ratings, UserRatings }
enum AWSDataType { case Celebrity, List, Ratings }
enum CognitoDataSet: String { case UserInfo, UserRatings, UserSettings }

//MARK: SocialLogin
enum SocialLogin: Int {
    case None = 0
    case Facebook = 1
    case Twitter = 2
    
    func serviceUnavailable() -> String {
        switch self {
        case .Facebook: return "Sharing on Facebook is unavailable. Please check the settings and make sure your Facebook account is accessible."
        case .Twitter: return "Sharing on Twitter is unavailable. Please check the settings and make sure your Twitter account is accessible."
        default: return "Social sharing is unavailable. Please check the settings and make sure your social accounts are accessible."
        }
    }
}

//MARK: OverlayInfo
enum OverlayInfo: Int {
    case WelcomeUser
    case MenuAccess
    case LoginSuccess
    case MaxFollow
    case FirstFollow
    case FirstConsensus
    case FirstPublic
    case FirstStars
    case FirstNegative
    case FirstInterest
    case FirstCompleted
    case FirstVoteDisable
    case LogoutUser
    case LoginError
    case NetworkError
    
    func message() -> String {
        switch self {
        case .WelcomeUser: return "\"We’re all in the gutter, but some of us are looking at the stars.\"\n- Oscar Wilde\n\nWelcome to the Courthouse of Public Opinion."
        case .MenuAccess: return "Welcome to the courthouse!\n\nA court where no pledge nor oath is required.\n\nA court where you only need to show your I.D to enter."
        case .LoginSuccess: return "Welcome into the courthouse,\nwhere we study the stars and share opinions\nwhere we come together and build consensus.\n\nPlease, vote responsibly."
        case .MaxFollow: return "blah blah blah blah blah blah blah blah."
        case .FirstFollow: return "blah blah blah blah blah blah blah blah."
        case .FirstConsensus: return "\"Keep your eyes on the stars, and your feet on the ground.\"\n- Theodore Roosevelt\n\nThe consensus will be revealed after casting your votes."
        case .FirstPublic: return "\"All humanity is connnected through a universal bond of sharing.\"\n- Ubuntu\n\nWelcome to the road less traveled of public service. You can pave the way for others to join the consensus by long pressing on a star quality."
        case .FirstStars: return "\"We are dealing with the stars in terms of their signification, not with them as real people.\"\n- Richard Dyer\n\nIn the courthouse stars are symbols, the consensus a journey to explore star qualities and reveal what makes them shine bright."
        case .FirstNegative: return "\"Two men look out the same prison bars; one sees mud and the other stars.\"\n- Beck\n\nWelcome to the other side."
        case .FirstInterest: return "blah blah blah blah blah blah blah blah. Your selection is automatically saved."
        case .FirstCompleted: return "blah blah blah blah blah blah blah blah."
        case .FirstVoteDisable: return "\"blah blah blah blah blah blah blah blah."
        case .LogoutUser: return "\"We are all of us stars, and we deserve to twinkle.\"\n- Marilyn Monroe\n\nThe courthouse hates to see you go, but we thank you for your votes and for building the consensus."
        case .LoginError: return "blah blah blah blah blah blah blah blah."
        case .NetworkError: return "blah blah blah blah blah blah blah blah."
        }
    }
    
    func logo() -> UIImage {
        switch self {
        case .WelcomeUser: return R.image.court_green()!
        case .MenuAccess: return R.image.passport_green()!
        case .LoginSuccess: return R.image.court_green()!
        case .MaxFollow: return R.image.telescope_green()!
        case .FirstFollow: return R.image.telescope_green()!
        case .FirstConsensus: return R.image.observatory_green()!
        case .FirstPublic: return R.image.road_green()!
        case .FirstStars: return R.image.spaceship_green()!
        case .FirstNegative: return R.image.vote_purple()!
        case .FirstInterest: return R.image.compass_green()!
        case .FirstCompleted: return R.image.planet_green()!
        case .FirstVoteDisable: return R.image.vote_green()!
        case .LogoutUser: return R.image.planet_green()!
        case .LoginError: return R.image.antenna_green()!
        case .NetworkError: return R.image.antenna_green()!
        }
    }
    
    static func getOptions() -> TAOverlayOptions {
        return [.OverlaySizeRoundedRect, .OverlayDismissTap, .OverlayAnimateTransistions, .OverlayShadow]
    }
}

//MARK: Info
enum Info: Int {
    case FirstName
    case MiddleName
    case LastName
    case From
    case Birthdate
    case Height
    case Zodiac
    case Status
    case CelScore
    case Networth
    
    static func getAll() -> [String] {
        return [
            FirstName.name(),
            MiddleName.name(),
            LastName.name(),
            From.name(),
            Birthdate.name(),
            Height.name(),
            Zodiac.name(),
            Status.name(),
            CelScore.name(),
            Networth.name()
        ]
    }
    
    func name() -> String {
        switch self {
        case .FirstName: return "FirstName"
        case .MiddleName: return "MiddleName"
        case .LastName: return "LastName"
        case .From: return "From"
        case .Birthdate: return "Date of Birth"
        case .Height: return "Height"
        case .Zodiac: return "Zodiac"
        case .Status: return "Status"
        case .CelScore: return "C-Score"
        case .Networth: return "Networth"
        }
    }
    
    func text() -> String {
        switch self {
        case .FirstName: return "first name is"
        case .MiddleName: return "middle name is"
        case .LastName: return "last name is"
        case .From: return "is from"
        case .Birthdate: return "was born"
        case .Height: return "height is"
        case .Zodiac: return "zodiac sign is"
        case .Status: return "relationship status is"
        case .CelScore: return "celscore is"
        case .Networth: return "networth is"
        }
    }
}

//MARK: Qualities
enum Qualities: Int {
    case Talent
    case Originality
    case Authenticity
    case Generosity
    case RoleModel
    case HardWork
    case Smarts
    case Charisma
    case Elegance
    case SexAppeal
    
    static func getAll() -> [String] {
        return [
            Talent.name(),
            Originality.name(),
            Authenticity.name(),
            Generosity.name(),
            RoleModel.name(),
            HardWork.name(),
            Smarts.name(),
            Charisma.name(),
            Elegance.name(),
            SexAppeal.name()
        ]
    }

    func name() -> String {
        switch self {
        case .Talent: return "Talent"
        case .Originality: return "Originality"
        case .Authenticity: return "Authenticity"
        case .Generosity: return "Generosity"
        case .RoleModel: return "Role Model"
        case .HardWork: return "Work Ethic"
        case .Smarts: return "Smarts"
        case .Charisma: return "Charisma"
        case .Elegance: return "Elegance"
        case .SexAppeal: return "Handsome"
        }
    }
    
    func text() -> String {
        switch self {
        case .Talent: return "talent is"
        case .Originality: return "originality is"
        case .Authenticity: return "authenticity is"
        case .Generosity: return "generosity is"
        case .RoleModel: return "as a role model is"
        case .HardWork: return "work ethic is"
        case .Smarts: return "smarts are"
        case .Charisma: return "charisma is"
        case .Elegance: return "elegance is"
        case .SexAppeal: return "handsomeness is"
        }
    }
}

//MARK: ListInfo
enum ListInfo : Int {
    case PublicOpinion
    case Hollywood
    case HipHop
    case Sports
    case Music
    case Television
    case News
    
    static func getAll() -> [String] {
        return [
            PublicOpinion.name(),
            Hollywood.name(),
            HipHop.name(),
            Sports.name(),
            Music.name(),
            Television.name(),
            News.name()
        ]
    }
    
    static func getCount() -> Int {
        var max: Int = 0
        while let _ = ListInfo(rawValue: max) { max += 1 }
        return max
    }
    
    func name() -> String {
        switch self {
        case .PublicOpinion: return "#PublicOpinion"
        case .Hollywood: return "#Hollywood"
        case .HipHop: return "#HipHop"
        case .Sports: return "#Sports"
        case .Music: return "#Music"
        case .Television: return "#Television"
        case .News: return "#News"
        }
    }
    
    func getId() -> String {
        switch self {
        case .PublicOpinion: return "0001"
        case .Hollywood: return "0004"
        case .HipHop: return "0007"
        case .Sports: return "0002"
        case .Music: return "0003"
        case .Television: return "0005"
        case .News: return "0006"
        }
    }
    
    func getIndex() -> Int {
        switch self {
        case .PublicOpinion: return 0
        case .Hollywood: return 1
        case .HipHop: return 2
        case .Sports: return 3
        case .Music: return 4
        case .Television: return 5
        case .News: return 6
        }
    }
}

//MARK: Zodiac
enum Zodiac : Int {
    case Aries
    case Taurus
    case Gemini
    case Cancer
    case Leo
    case Virgo
    case Libra
    case Scorpio
    case Sagittarius
    case Capricorn
    case Aquarius
    case Pisces

    func name() -> String {
        switch self {
        case .Aries: return "Aries"
        case .Taurus: return "Taurus"
        case .Gemini: return "Gemini"
        case .Cancer: return "Cancer"
        case .Leo: return "Leo"
        case .Virgo: return "Virgo"
        case .Libra: return "Libra"
        case .Scorpio: return "Scorpio"
        case .Sagittarius: return "Sagittarius"
        case .Capricorn: return "Capricorn"
        case .Aquarius: return "Aquarius"
        case .Pisces: return "Pisces"
        }
    }

    func compatableTypes() -> [Zodiac] {
        switch self {
        case .Aries: return [.Gemini, .Sagittarius, .Leo, .Aquarius]
        case .Taurus: return [.Capricorn, .Pisces, .Virgo, .Cancer]
        case .Gemini: return [.Aquarius, .Libra, .Aries, .Leo]
        case .Cancer: return [.Pisces, .Taurus, .Scorpio, .Virgo]
        case .Leo: return [.Sagittarius, .Aries, .Gemini, .Libra]
        case .Virgo: return [.Taurus, .Capricorn, .Cancer]
        case .Libra: return [.Gemini, .Aquarius, .Leo, .Sagittarius]
        case .Scorpio: return [.Pisces, .Cancer, .Capricorn, .Virgo]
        case .Sagittarius: return [.Leo, .Aries, .Libra, .Aquarius]
        case .Capricorn: return [.Taurus, .Virgo, .Pisces, .Scorpio]
        case .Aquarius: return [.Gemini, .Libra, .Sagittarius, .Aries]
        case .Pisces: return [.Cancer, .Scorpio, .Taurus, .Capricorn]
        }
    }

    func symbol() -> String {
        switch self {
            case .Aries: return "♈"
            case .Taurus: return "♉"
            case .Gemini: return "♊"
            case .Cancer: return "♋"
            case .Leo: return "♌"
            case .Virgo: return "♍"
            case .Libra: return "♎"
            case .Scorpio: return "♏"
            case .Sagittarius: return "♐"
            case .Capricorn: return "♑"
            case .Aquarius: return "♒"
            case .Pisces: return "♓"
        }
    }
}