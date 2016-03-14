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
public enum RatingsError: ErrorType { case RatingsNotFound, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
public enum ListError: ErrorType { case EmptyList, IndexOutOfBounds, NoLists }
public enum CelebrityError: ErrorType { case NotFound }

//MARK: Misc.
public enum LoginType: Int { case None = 1, Facebook, Twitter }
public enum SocialNetwork: Int { case Twitter = 0, Facebook }
public enum RatingsType { case Ratings, UserRatings }
public enum AWSDataType { case Celebrity, List, Ratings }
public enum CookieType: String { case Positive, Negative }
public enum CognitoDataSet: String { case UserInfo, UserRatings, UserSettings }

//MARK: OverlayInfo
public enum OverlayInfo: Int {
    case WelcomeUser
    case MenuAccess
    case LoginSuccess
    case FirstFollow
    case MaxFollow
    case FirstRoad
    case FirstPublic
    case VoteDisable
    case SocialDisable
    case LogoutUser
    case LoginError
    case NetworkError
    
    public func message() -> String {
        switch self {
        case .WelcomeUser: return "\"We’re all in the gutter, but some of us are looking at the stars.\"\n- Oscar Wilde\n\nWelcome to the Courthouse of Public Opinion."
        case .MenuAccess: return "Welcome aboard the consensus. You will need to provide some form of identification to get started."
        case .LoginSuccess: return "Welcome to the courthouse. Help us find common grounds by adding your voice to the consensus. Please vote responsibly."
        case .FirstFollow: return "blah blah blah blah blah blah blah blah"
        case .MaxFollow: return "blah blah blah blah blah blah blah blah"
        case .FirstRoad: return "Welcome to the road less traveled. We’re not sure where it’s going, but wherever it takes you, the consensus will help you get there."
        case .FirstPublic: return "You’re now a long press away from building the consensus on social media. Let’s keep finding common grounds together."
        case .VoteDisable: return "blah blah blah blah blah blah blah blah"
        case .SocialDisable: return "blah blah blah blah blah blah blah blah"
        case .LogoutUser: return "The courthouse hates to see you go, but thanks you for your votes and for co-creating the consensus. You’re welcome back anytime."
        case .LoginError: return "blah blah blah blah blah blah blah blah"
        case .NetworkError: return "blah blah blah blah blah blah blah blah"
        }
    }
    
    public func logo() -> String {
        switch self {
        case .WelcomeUser: return "court_green"
        case .MenuAccess: return "passport_green"
        case .LoginSuccess: return "court_green"
        case .FirstFollow: return "telescope_green"
        case .MaxFollow: return "camera_green"
        case .FirstRoad: return "road_green"
        case .FirstPublic: return "megaphone_green"
        case .VoteDisable: return "vote_green"
        case .SocialDisable: return "megaphone_green"
        case .LogoutUser: return "astronaut_green"
        case .LoginError: return "error_green"
        case .NetworkError: return "error_green"
        }
    }
    
    public static func getOptions() -> TAOverlayOptions {
        return [.OverlaySizeRoundedRect, .OverlayDismissTap, .OverlayAnimateTransistions, .OverlayShadow]
    }
}

//MARK: Info
public enum Info: Int {
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
    
    public static func getAll() -> [String] {
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
    
    public func name() -> String {
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
    
    public func text() -> String {
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
public enum Qualities: Int {
    case Talent
    case Originality
    case Authenticity
    case Generosity
    case RoleModel
    case HardWork
    case Smarts
    case Elegance
    case Charisma
    case SexAppeal
    
    public static func getAll() -> [String] {
        return [
            Talent.name(),
            Originality.name(),
            Authenticity.name(),
            Generosity.name(),
            RoleModel.name(),
            HardWork.name(),
            Smarts.name(),
            Elegance.name(),
            Charisma.name(),
            SexAppeal.name()
        ]
    }

    public func name() -> String {
        switch self {
        case .Talent: return "Talent"
        case .Originality: return "Originality"
        case .Authenticity: return "Authenticity"
        case .Generosity: return "Generosity"
        case .RoleModel: return "Role Model"
        case .HardWork: return "Work Ethic"
        case .Smarts: return "Smarts"
        case .Elegance: return "Elegance"
        case .Charisma: return "Charisma"
        case .SexAppeal: return "Handsome"
        }
    }
    
    public func text() -> String {
        switch self {
        case .Talent: return "talent is"
        case .Originality: return "originality is"
        case .Authenticity: return "authenticity is"
        case .Generosity: return "generosity is"
        case .RoleModel: return "as a role model is"
        case .HardWork: return "work ethic is"
        case .Smarts: return "smarts are"
        case .Elegance: return "elegance is"
        case .Charisma: return "charisma is"
        case .SexAppeal: return "handsomeness is"
        }
    }
}

//MARK: ListInfo
public enum ListInfo : Int {
    case PublicOpinion
    case Hollywood
    case HipHop
    case Sports
    case Music
    case Television
    case News
    
    public static func getAll() -> [String] {
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
    
    public static func getCount() -> Int {
        var max: Int = 0
        while let _ = ListInfo(rawValue: max) { max += 1 }
        return max
    }
    
    public func name() -> String {
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
    
    public func getId() -> String {
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
    
    public func getIndex() -> Int {
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
public enum Zodiac : Int {
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

    public func name() -> String {
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

    public func compatableTypes() -> [Zodiac] {
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

    public func symbol() -> String {
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

//MARK: StarFillMode
public enum StarFillMode: Int {
    case Full = 0
    case Half = 1
    case Precise = 2
}