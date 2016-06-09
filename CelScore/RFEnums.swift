//
//  RFEnums.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation


//MARK: Error
enum RatingsError: Int, ErrorType { case RatingsNotFound = 0, UserRatingsNotFound, RatingValueOutOfBounds, RatingIndexOutOfBounds }
enum CognitoError: Int, ErrorType { case NoDataSet = 0 }
enum ListError: Int, ErrorType { case EmptyList = 0, IndexOutOfBounds, NoLists }
enum CelebrityError: Int, ErrorType { case NotFound = 0 }
enum NetworkError: Int, ErrorType { case NotConnected = 1, TimedOut }


//MARK: Misc.
enum RatingsType { case Ratings, UserRatings }
enum AWSDataType { case Celebrity, List, Ratings }
enum CognitoDataSet: String { case FacebookInfo, TwitterInfo, UserRatings, UserSettings }

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
    case FirstNotFollow
    case FirstConsensus
    case FirstPublic
    case FirstStars
    case FirstNegative
    case FirstInterest
    case FirstCompleted
    case FirstVoteDisable
    case FirstTrollWarning
    case LogoutUser
    case LoginError
    case NetworkError
    case TimeoutError
    
    func message() -> String {
        switch self {
        case .WelcomeUser: return "What happens in a court of public opinion stays in a court of public opinion.\n\nWhat is voted on and agreed upon in court of public opinion is enterely up to you.\n\nWelcome to the courthouse!"
        case .MenuAccess: return "You've reached the steps of courthouse!\n\nYou'll need to register to access this area."
        case .LoginSuccess: return "You are now a registered member of the Courthouse of Public Opinion!\n\nPlease vote responsibly."
        case .MaxFollow: return "You've already reached the maximum number of stars you can follow!"
        case .FirstFollow: return "You've selected your first star!\n\nYou can choose up to ten stars to appear in the Today view.\n(swipe down from the top of your screen to display it)"
        case FirstNotFollow: return "You've reached the steps of observatory!\n\nYou'll need to register to access this area."
        case .FirstConsensus: return "\"A genuine leader is not a searcher for consensus but a molder of consensus.\"\n- Martin Luther King Jr.\n\nFrom now on the consensus will regenerate after each one of your votes."
        case .FirstPublic: return "\"With public sentiment, nothing can fail.\"\n- Abraham Lincoln\n\nYou can now add your voice to the public debate by long pressing on a star."
        case .FirstStars: return "\"The celebrity exists above the real world, in the realm of symbols that gain and lose value like commodities on the stock market.\"\n- P. David Marshall\n\nPlease vote responsibly."
        case .FirstNegative: return "You've ventured into the dark side of the Score!\n\nYou can check your ratio of positive votes in the courthouse section."
        case .FirstInterest: return "You've choosen your first realm of interest!\n\nYour realm is automatically saved."
        case .FirstCompleted: return "You've cast your votes in every realm of our star-studded constellation!\n\nThank you for voting and for building the consensus."
        case .FirstVoteDisable: return "Welcome to our star-studded voting booth!\n\nYou'll need to register to make your opinion public."
        case .FirstTrollWarning: return "You've entered the trolling zone!\n\nPast a certain ratio of negative votes, all your votes will be discarded."
        case .LogoutUser: return "The courthouse hates to see you go!\n\nThank you for voting and for building the consensus."
        case .LoginError: return "We are currently not able to log you in.\nPlease try again at a later time.\n\nIf the issue persists, please contact @GreyEcologist."
        case .NetworkError: return "The internet connection appears to be offline.\nPlease check your network settings.\n\nIf the issue persists, please contact @GreyEcologist."
        case .TimeoutError: return "We're unable to update you with the latest data from our servers.\n\nIf the issue persists, please contact @GreyEcologist."
        }
    }
    
    func logo() -> UIImage {
        switch self {
        case .WelcomeUser: return R.image.court_green()!
        case .MenuAccess: return R.image.court_green()!
        case .LoginSuccess: return R.image.astronaut_green()!
        case .MaxFollow: return R.image.observatory_green()!
        case .FirstFollow: return R.image.astronaut_green()!
        case .FirstNotFollow: return R.image.observatory_green()!
        case .FirstConsensus: return R.image.mlk_green()!
        case .FirstPublic: return R.image.lincoln_green()!
        case .FirstStars: return R.image.spaceship_green()!
        case .FirstNegative: return R.image.mic_purple()!
        case .FirstInterest: return R.image.geometry_green()!
        case .FirstCompleted: return R.image.planet_green()!
        case .FirstVoteDisable: return R.image.mic_green()!
        case .FirstTrollWarning: return R.image.nuclear_purple()!
        case .LogoutUser: return R.image.planet_green()!
        case .LoginError: return R.image.networkError()!
        case .NetworkError: return R.image.networkError()!
        case .TimeoutError: return R.image.networkError()!
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
        case .FirstName: return "First Name"
        case .MiddleName: return "Middle Name"
        case .LastName: return "Last Name"
        case .From: return "From"
        case .Birthdate: return "Date of Birth"
        case .Height: return "Height"
        case .Zodiac: return "Zodiac"
        case .Status: return "Status"
        case .CelScore: return "Score"
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
    
    static func getAll(isMale isMale: Bool = true) -> [String] {
        return [
            Talent.name(),
            Originality.name(),
            Authenticity.name(),
            Generosity.name(),
            RoleModel.name(),
            HardWork.name(),
            Smarts.name(),
            Charisma.name(),
            Elegance.name(isMale: isMale),
            SexAppeal.name(isMale: isMale)
        ]
    }

    func name(isMale isMale: Bool = true) -> String {
        switch self {
        case .Talent: return "Talent"
        case .Originality: return "Originality"
        case .Authenticity: return "Authenticity"
        case .Generosity: return "Generosity"
        case .RoleModel: return "Role Model"
        case .HardWork: return "Work Ethic"
        case .Smarts: return "Smarts"
        case .Charisma: return "Charisma"
        case .Elegance: return isMale == true ? "Style" : "Elegance"
        case .SexAppeal: return isMale == true ? "Handsome" : "Beauty"
        }
    }
    
    func text(isMale isMale: Bool = true) -> String {
        switch self {
        case .Talent: return "talent is"
        case .Originality: return "originality is"
        case .Authenticity: return "authenticity is"
        case .Generosity: return "generosity is"
        case .RoleModel: return "as a role model is"
        case .HardWork: return "work ethic is"
        case .Smarts: return "smarts are"
        case .Charisma: return "charisma is"
        case .Elegance: return isMale == true ? "style is" : "elegance is"
        case .SexAppeal: return isMale == true ? "handsomeness is" : "beauty is"
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
    
    static func getAllNames() -> [String] {
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
    
    static func getAllIDs() -> [String] {
        return [
            PublicOpinion.getId(),
            Hollywood.getId(),
            HipHop.getId(),
            Sports.getId(),
            Music.getId(),
            Television.getId(),
            News.getId()
        ]
    }
    
    static func getCount() -> Int {
        var max: Int = 0
        while let _ = ListInfo(rawValue: max) { max += 1 }
        return max
    }
    
    func name() -> String {
        switch self {
        case .PublicOpinion: return "Public Opinion"
        case .Hollywood: return "Hollywood"
        case .HipHop: return "Hip Hop"
        case .Sports: return "Sports"
        case .Music: return "Music"
        case .Television: return "Television"
        case .News: return "New"
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