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
enum CelebrityError: ErrorType { case NotFound, TooManyCelebs }

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
    
    func message() -> String {
        switch self {
        case .WelcomeUser: return "\"We’re all in the gutter, but some of us are looking at the stars.\"\n- Oscar Wilde\n\nThank you for downloading the CelScore!\n\nWelcome aboard our constellation, our set of stars for you to gaze upon."
        case .MenuAccess: return "You need to register to access this area."
        case .LoginSuccess: return "Thank you for registering and becoming a member of the Courthouse of Public Opinion!\n\nPlease vote responsibly, and enjoy your journey aboard the constellation."
        case .MaxFollow: return "You've reached the maximum of stars you can follow."
        case .FirstFollow: return "You can follow up to ten stars."
        case .FirstConsensus: return "\"The whole is other than the sum of the parts\"\n- Kurt Koffka\n\nThe consensus is greater than the sum of our votes, rather it is something else altogether.\n\nThe consensus will regenerate after each one of your votes."
        case .FirstPublic: return "\"With public sentiment, nothing can fail.\"\n- Abraham Lincoln\n\nThere is no precedent in history in which so many could participate in the making of public opinion.\n\nYou can share your opinion by long pressing on a star quality."
        case .FirstStars: return "\"We are dealing with the stars in terms of their signification, not with them as real people.\"\n- Richard Dyer\n\nIf stars are symbols, then the values they incarnate are bright lights shining through them."
        case .FirstNegative: return "Welcome to the other side of the Score."
        case .FirstInterest: return "Your selection is saved automatically."
        case .FirstCompleted: return "You've cast your votes on every star in our constellation.\n\nThank you for voting and building the consensus."
        case .FirstVoteDisable: return ""
        case .FirstTrollWarning: return ""
        case .LogoutUser: return "The courthouse hates to see you go, but we thank you for your votes and for building the consensus."
        case .LoginError: return "\"Last night was a shameful train wreck filled with blind cuddly puppies.\"\n- Charlie Sheen\n\nWe are currently not able to log you in. Please try again at a later time."
        case .NetworkError: return "\"I am on a drug. It's called Charlie Sheen. It's not available because if you try it you will die.\"\n- Charlie Sheen\n\nConnection to the network is currently not available. Please check your network settings."
        }
    }
    
    func logo() -> UIImage {
        switch self {
        case .WelcomeUser: return R.image.spaceship_green()!
        case .MenuAccess: return R.image.passport_green()!
        case .LoginSuccess: return R.image.planet_green()!
        case .MaxFollow: return R.image.observatory_green()!
        case .FirstFollow: return R.image.observatory_green()!
        case .FirstConsensus: return R.image.collective_green()!
        case .FirstPublic: return R.image.lincoln_green()!
        case .FirstStars: return R.image.spaceship_green()!
        case .FirstNegative: return R.image.nuclear_purple()!
        case .FirstInterest: return R.image.anchor_green()!
        case .FirstCompleted: return R.image.planet_green()!
        case .FirstVoteDisable: return R.image.spaceship_green()!
        case .FirstTrollWarning: return R.image.nuclear_purple()!
        case .LogoutUser: return R.image.planet_green()!
        case .LoginError: return R.image.antenna_green()!
        case .NetworkError: return R.image.antenna_green()!
        }
    }
    
    static func consensusArray() -> [UIImage] {
        return [R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer0_green()!,
                R.image.hammer1_green()!,
                R.image.hammer3_green()!,
                R.image.hammer4_green()!,
                R.image.hammer5_green()!,
                R.image.hammer6_green()!,
                R.image.hammer7_green()!,
                R.image.hammer8_green()!,
                R.image.hammer10_green()!,
                R.image.hammer9_green()!,
                R.image.hammer9_green()!,
                R.image.hammer9_green()!,
                R.image.hammer9_green()!,
                R.image.hammer8_green()!,
                R.image.hammer7_green()!,
                R.image.hammer6_green()!,
                R.image.hammer5_green()!,
                R.image.hammer4_green()!,
                R.image.hammer3_green()!,
                R.image.hammer1_green()!,
                R.image.hammer0_green()!]
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