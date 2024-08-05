import Dependencies
import Foundation
import KakaoSDKTalk
import URLClient

extension URLClient: DependencyKey {
    public static var liveValue: Self {
        let secrets = Secrets.load()
        return Self(
            getIntroduceURL: { 
                guard let introduceURLStr = secrets?.introduceURL else { return nil }
                return URL(string: introduceURLStr)!
            },
            getPrivacyPolicyURL: { 
                guard let privacyPolicyURLStr = secrets?.privacyPolicyURL else { return nil }
                return URL(string: privacyPolicyURLStr)!
            },
            getCSURL: {
                guard let kakaoPublicID = secrets?.kakaoChannelPublicId else { return nil }
                return TalkApi.shared.makeUrlForChatChannel(channelPublicId: kakaoPublicID)
            }
        )
    }
}

struct Secrets: Decodable {
    let introduceURL: String
    let privacyPolicyURL: String
    let kakaoChannelPublicId:  String
    
    static func load() -> Self? {
        guard let secretsFileURL = Bundle.module.url(forResource: "secrets", withExtension: "json"),
              let data = try? Data(contentsOf: secretsFileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
