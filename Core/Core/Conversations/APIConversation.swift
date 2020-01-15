//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public enum ConversationWorkflowState: String, Codable {
    case read, unread, archived
}

public enum ConversationProperties: String, Codable {
    case last_author, attachments, media_objects
}

// https://canvas.instructure.com/doc/api/conversations.html#Conversation
public struct APIConversation: Codable, Equatable {
    let id: ID
    let subject: String
    let workflow_state: ConversationWorkflowState
    let last_message: String
    let last_message_at: Date
    let last_authored_message: String?
    let last_authored_message_at: Date?
    let participants: [APIConversationParticipant]
    let message_count: Int
    let subscribed: Bool
    let `private`: Bool
    let starred: Bool
    let properties: [ConversationProperties]?
    let audience: [ID]?
    let avatar_url: APIURL
    let visible: Bool
    let context_name: String?
    let context_code: String
    let messages: [APIConversationMessage]?
}

// https://canvas.instructure.com/doc/api/conversations.html#ConversationParticipant
public struct APIConversationParticipant: Codable, Equatable {
    let id: ID
    let name: String
    let avatar_url: APIURL?
    let pronouns: String?
}

public struct APIConversationMessage: Codable, Equatable {
    let id: ID
    let created_at: Date
    let body: String
    let author_id: ID
    let generated: Bool
    let media_comment: APIMediaComment?
    let attachments: [APIFile]?
    let forwarded_messages: [APIConversationMessage]?
    let participating_user_ids: [ID]?
}

#if DEBUG
extension APIConversation {
    public static func make(
        id: String = "1",
        subject: String = "Subject One",
        workflow_state: ConversationWorkflowState = .unread,
        last_message: String = "Last Message One",
        last_message_at: Date = Clock.now,
        last_authored_message: String? = "Last Authored Message One",
        last_authored_message_at: Date? = Clock.now,
        participants: [APIConversationParticipant] = [.make()],
        message_count: Int = 1,
        subscribed: Bool = false,
        private: Bool = false,
        starred: Bool = false,
        properties: [ConversationProperties]? = nil,
        audience: [String]? = [ "1" ],
        avatar_url: URL = URL(string: "https://canvas.instructure.com/avatar/1")!,
        visible: Bool = true,
        context_name: String = "Canvas 101",
        context_code: String = "course_1",
        messages: [APIConversationMessage]? = nil
    ) -> APIConversation {
        return APIConversation(
            id: ID(id),
            subject: subject,
            workflow_state: workflow_state,
            last_message: last_message,
            last_message_at: last_message_at,
            last_authored_message: last_authored_message,
            last_authored_message_at: last_authored_message_at,
            participants: participants,
            message_count: message_count,
            subscribed: subscribed,
            private: `private`,
            starred: starred,
            properties: properties,
            audience: audience?.map { ID($0) },
            avatar_url: APIURL(rawValue: avatar_url),
            visible: visible,
            context_name: context_name,
            context_code: context_code,
            messages: messages
        )
    }
}

extension APIConversationParticipant {
    public static func make(
        id: String = "1",
        name: String = "Participant One",
        avatar_url: URL? = nil,
        pronouns: String? = nil
    ) -> APIConversationParticipant {
        return APIConversationParticipant(
            id: ID(id),
            name: name,
            avatar_url: APIURL(rawValue: avatar_url),
            pronouns: pronouns
        )
    }
}

extension APIConversationMessage {
    public static func make(
        id: String = "1",
        created_at: Date = Clock.now,
        body: String = "Body One",
        author_id: String = "1",
        generated: Bool = false,
        media_comment: APIMediaComment? = nil,
        attachments: [APIFile]? = nil,
        forwarded_messages: [APIConversationMessage]? = nil,
        participating_user_ids: [ID]? = ["1", "2"]
    ) -> APIConversationMessage {
        return APIConversationMessage(
            id: ID(id),
            created_at: created_at,
            body: body,
            author_id: ID(author_id),
            generated: generated,
            media_comment: media_comment,
            attachments: attachments,
            forwarded_messages: forwarded_messages,
            participating_user_ids: participating_user_ids
        )
    }
}
#endif

public struct GetConversationsUnreadCountRequest: APIRequestable {
    public struct Response: Codable {
        public let unread_count: UInt

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            unread_count = try UInt(container.decode(String.self, forKey: .unread_count)) ?? 0
        }
    }

    public let path = "conversations/unread_count"

    public init() {}
}

public struct GetConversationsRequest: APIRequestable {
    public typealias Response = [APIConversation]
    enum Include: String {
        case participant_avatars
    }
    enum Scope: String {
        case unread, starred, archived, sent
    }

    public let path = "conversations"

    let include: [Include]
    let perPage: Int?
    let scope: Scope?

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
        ]
        if let perPage = perPage {
            query.append(.value("per_page", String(perPage)))
        }
        if let scope = scope {
            query.append(.value("scope", scope.rawValue))
        }
        return query
    }
}

public struct GetConversationRequest: APIRequestable {
    public typealias Response = APIConversation
    public enum Include: String {
        case participant_avatars
    }

    let id: String
    let include: [Include]
    public var path: String { "conversations/\(id)" }
    public var query: [APIQueryItem] {
        return [ .include(include.map { $0.rawValue }) ]
    }
}

struct PutConversationRequest: APIRequestable {
    typealias Response = APIConversation
    struct Body: Encodable {
        let id: String
        let workflow_state: ConversationWorkflowState
    }

    let id: String
    let workflowState: ConversationWorkflowState
    var path: String { "conversations/\(id)" }
    let method = APIMethod.put
    var body: Body? {
        return Body(id: id, workflow_state: workflowState)
    }
}

public struct PostAddMessageRequest: APIRequestable {
    public typealias Response = APIConversation
    public struct Body: Encodable {
        let attachment_ids: [String]?
        let body: String
        let media_comment_id: String?
        let media_comment_type: MediaCommentType?
        let recipients: [String]?
    }

    let conversationID: String
    public let body: Body?
    public var path: String { "conversations/\(conversationID)/add_message" }
    public let method = APIMethod.post
}
