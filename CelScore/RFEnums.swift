//
//  RFEnums.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation
import Material


//MARK: ThemeColor
public enum ThemeColor: Int {
    case Blue
    case Red
    case Green
    case Purple
    case Pink
    case Brown
    case Grey
    case BlueGrey
    case Black
    case White
    
    public func mainShade() -> UIColor {
        switch self {
        case .Blue: return MaterialColor.blue.base
        case .Red: return MaterialColor.red.base
        case .Green: return MaterialColor.green.base
        case .Purple: return MaterialColor.purple.base
        case .Pink: return MaterialColor.pink.base
        case .Brown: return MaterialColor.brown.base
        case .Grey: return MaterialColor.grey.base
        case .BlueGrey: return MaterialColor.blueGrey.base
        case .Black: return MaterialColor.black
        case .White: return MaterialColor.white
        }
    }
    
    public func darkShade() -> UIColor {
        switch self {
        case .Blue: return MaterialColor.blue.darken4
        case .Red: return MaterialColor.red.darken4
        case .Green: return MaterialColor.green.darken4
        case .Purple: return MaterialColor.purple.darken4
        case .Pink: return MaterialColor.pink.darken4
        case .Brown: return MaterialColor.brown.darken4
        case .Grey: return MaterialColor.grey.darken4
        case .BlueGrey: return MaterialColor.blueGrey.darken4
        case .Black: return MaterialColor.black
        case .White: return MaterialColor.white
        }
    }
    
    public func lightShade() -> UIColor {
        switch self {
        case .Blue: return MaterialColor.blue.lighten3
        case .Red: return MaterialColor.red.lighten3
        case .Green: return MaterialColor.green.lighten3
        case .Purple: return MaterialColor.purple.lighten3
        case .Pink: return MaterialColor.pink.lighten3
        case .Brown: return MaterialColor.brown.lighten3
        case .Grey: return MaterialColor.grey.lighten3
        case .BlueGrey: return MaterialColor.blueGrey.lighten3
        case .Black: return MaterialColor.black
        case .White: return MaterialColor.white
        }
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
        case .SexAppeal: return "Sex Appeal"
        }
    }
}

//MARK: CelebList
public enum CelebList : Int {
    case PublicOpinion
    case Ubuntu
    case Hollywood
    case Sports
    case Music
    case Television
    case Candidates
    
    public static func getAll() -> [String] {
        return [
            PublicOpinion.name(),
            Ubuntu.name(),
            Hollywood.name(),
            Sports.name(),
            Music.name(),
            Television.name(),
            Candidates.name()
        ]
    }
    
    public static func getCount() -> Int {
        var max: Int = 0
        while let _ = CelebList(rawValue: max) { max += 1 }
        return max
    }
    
    public func name() -> String {
        switch self {
        case .PublicOpinion: return "#PublicOpinon"
        case .Ubuntu: return "#Ubuntu"
        case .Hollywood: return "#Hollywood"
        case .Sports: return "#Sports"
        case .Music: return "#Music"
        case .Television: return "#Television"
        case .Candidates: return "#Candidates"
        }
    }
    
    public func getId() -> String {
        switch self {
        case .PublicOpinion: return "0001"
        case .Ubuntu: return "0007"
        case .Hollywood: return "0004"
        case .Sports: return "0002"
        case .Music: return "0003"
        case .Television: return "0005"
        case .Candidates: return "0006"
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