//
//  DataStructures.swift
//  Test
//
//  Created by Adam Barr-Neuwirth on 3/30/23.
//

import Foundation

@objc public class LeaderboardRecord: NSObject, Decodable {
    @objc public let clan: Clan?
    @objc public let clanMember: ClanMember?
    @objc public let playerProfile: PlayerProfileModel?
    @objc public let rank: NSNumber
    @objc public let score: NSNumber

    enum CodingKeys: String, CodingKey {
        case clan
        case clanMember = "clan_member"
        case playerProfile = "player_profile"
        case rank
        case score
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clan = try container.decodeIfPresent(Clan.self, forKey: .clan)
        clanMember = try container.decodeIfPresent(ClanMember.self, forKey: .clanMember)
        playerProfile = try container.decodeIfPresent(PlayerProfileModel.self, forKey: .playerProfile)
        let rankValue = try container.decode(Int.self, forKey: .rank)
        rank = NSNumber(value: rankValue)
        let scoreValue = try container.decode(Double.self, forKey: .score)
        score = NSNumber(value: scoreValue)
    }
}

@objc public class ClanMember: NSObject, Decodable {
    @objc public let playerProfile: PlayerProfileModel?
    @objc public let role: NSString

    enum CodingKeys: String, CodingKey {
        case playerProfile = "player_profile"
        case role
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerProfile = try container.decodeIfPresent(PlayerProfileModel.self, forKey: .playerProfile)
        let roleString = try container.decode(String.self, forKey: .role)
        role = NSString(string: roleString)
    }
}

@objc public class PlayerProfileModel: NSObject, Decodable {
    @objc public let aliasId: NSString
    @objc public let isAnonymous: NSNumber
    @objc public let playerId: NSString
    @objc public let nickname: NSString
    @objc public let profileImageURL: NSString

    enum CodingKeys: String, CodingKey {
        case aliasId = "alias_id"
        case isAnonymous = "is_anonymous"
        case playerId = "player_id"
        case nickname
        case profileImageURL = "profile_image_url"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let aliasIdString = try container.decode(String.self, forKey: .aliasId)
        aliasId = NSString(string: aliasIdString)
        let isAnonymousValue = try container.decode(Bool.self, forKey: .isAnonymous)
        isAnonymous = NSNumber(value: isAnonymousValue)
        let playerIdString = try container.decode(String.self, forKey: .playerId)
        playerId = NSString(string: playerIdString)
        let nicknameString = try container.decode(String.self, forKey: .nickname)
        nickname = NSString(string: nicknameString)
        let profileImageURLString = try container.decode(String.self, forKey: .profileImageURL)
        profileImageURL = NSString(string: profileImageURLString)
    }
}


@objc public class Clan: NSObject, Decodable {
    @objc public let clanId: NSString
    @objc public let name: NSString
    @objc public let humanUid: NSString
    @objc public let inviteCode: NSString
    @objc public let memberCount: NSNumber
    @objc public let memberLimit: NSNumber
    @objc public let memberRole: NSString?
    @objc public let image: NSString
    @objc public let closed: NSNumber
    @objc public let members: [ClanMember]?
    @objc public let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case clanId = "clan_id"
        case name
        case humanUid = "human_uid"
        case inviteCode = "invite_code"
        case memberCount = "member_count"
        case memberLimit = "member_limit"
        case memberRole = "member_role"
        case image
        case closed
        case members
        case metadata
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clanId = try container.decode(String.self, forKey: .clanId) as NSString
        name = try container.decode(String.self, forKey: .name) as NSString
        humanUid = try container.decode(String.self, forKey: .humanUid) as NSString
        inviteCode = try container.decode(String.self, forKey: .inviteCode) as NSString
        let memberCountValue = try container.decode(Int.self, forKey: .memberCount)
        memberCount = NSNumber(value: memberCountValue)
        let memberLimitValue = try container.decode(Int.self, forKey: .memberLimit)
        memberLimit = NSNumber(value: memberLimitValue)
        memberRole = try container.decodeIfPresent(String.self, forKey: .memberRole) as NSString?
        image = try container.decode(String.self, forKey: .image) as NSString
        let closedValue = try container.decode(Bool.self, forKey: .closed)
        closed = NSNumber(value: closedValue)
        members = try container.decodeIfPresent([ClanMember].self, forKey: .members)
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
    }
}


@objc public class PlayerRecordApiResponse: NSObject, Decodable {
    @objc public let data: DataObject

    @objc public class DataObject: NSObject, Decodable {
        @objc public let record: LeaderboardRecord
        
        enum CodingKeys: String, CodingKey {
            case record
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            record = try container.decode(LeaderboardRecord.self, forKey: .record)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(DataObject.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

@objc public class ClanApiResponse: NSObject, Decodable {
    @objc public let data: DataObject

    @objc public class DataObject: NSObject, Decodable {
        @objc public let clan: Clan
        
        enum CodingKeys: String, CodingKey {
            case clan
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            clan = try container.decode(Clan.self, forKey: .clan)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(DataObject.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}


@objc public class PlayerProfileApiResponse: NSObject, Decodable {
    @objc public let data: PlayerProfile
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(PlayerProfile.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}


@objc public class PlayerProfile: NSObject, Decodable {
    @objc public let clan: Clan?
    @objc public let playerProfile: PlayerProfileModel?
    @objc public let notifications: NSNumber?

    enum CodingKeys: String, CodingKey {
        case clan
        case playerProfile = "player_profile"
        case notifications
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clan = try container.decodeIfPresent(Clan.self, forKey: .clan)
        playerProfile = try container.decodeIfPresent(PlayerProfileModel.self, forKey: .playerProfile)
        notifications = try container.decodeIfPresent(Int.self, forKey: .notifications) as NSNumber?
    }
}

@objc public class OpponentResultApiResponse: NSObject, Decodable {
    @objc public let data: OpponentResult
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(OpponentResult.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

@objc public class OpponentResult: NSObject, Decodable {
    @objc public let playerId: NSString?
    @objc public let nickname: NSString
    @objc public let score: NSNumber
    @objc public let rank: NSNumber
    @objc public let avatarURL: NSString
    
    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case nickname
        case score
        case rank
        case avatarURL = "avatar_url"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerId = try container.decodeIfPresent(String.self, forKey: .playerId) as NSString?
        nickname = try container.decode(String.self, forKey: .nickname) as NSString
        score = try container.decode(Double.self, forKey: .score) as NSNumber
        rank = try container.decode(Int.self, forKey: .rank) as NSNumber
        avatarURL = try container.decode(String.self, forKey: .avatarURL) as NSString
    }
}


@objc public class State: NSObject, Decodable {
    @objc public let data: DataObject
    
    @objc public class DataObject: NSObject, Decodable {
        @objc public let state: NSString
        
        enum CodingKeys: String, CodingKey {
            case state
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state = try container.decode(String.self, forKey: .state) as NSString
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(DataObject.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
