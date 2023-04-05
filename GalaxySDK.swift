import Foundation
import UIKit

@objc public class GalaxySDK: NSObject{
    public static let shared = GalaxySDK()
    
    let baseUri = "https://app.galaxy.us"
    let baseApi = "https://api.galaxysdk.com/api/v1"
    var publishableKey = ""
    var configurationInProgress = false
    var currentWebViewController: WebViewController?
    
    @objc public func configure(publishableKey: String){
        self.configurationInProgress = true
        self.publishableKey = publishableKey
        
        //Check if token exists
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            if(galaxyToken != ""){
                self.configurationInProgress = false
                return
            }
        }
        
        //No token, sign in
        let parameters: [String: Any] = [
            "bundle_id": Bundle.main.bundleIdentifier ?? "",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "no-device-id-available"
        ]
        
        APIManager().apiCall(urlPath: "/signup/anonymous", method: .post, parameters: parameters, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                print("Saved new token")
                let anonToken = String(data: data, encoding: .utf8)!
                self.saveTokenAndPlayerId(token: anonToken)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            self.configurationInProgress = false
        }
    }
    
    @objc public func reportScore(leaderboardId: String, score: Double){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.reportScore(leaderboardId: leaderboardId, score: score)
                return
            }
        }
        
        if(!Reachability().isConnectedToNetwork()){
            var savedScoresList = UserDefaults.standard.string(forKey: "cachedScores") ?? ""
            savedScoresList += "\(score)|\(leaderboardId)|\(UUID().uuidString),"
            UserDefaults.standard.set(savedScoresList, forKey: "cachedScores")
        }
        else{
            let savedScores = UserDefaults.standard.string(forKey: "cachedScores") ?? ""
            UserDefaults.standard.set("", forKey: "cachedScores")
            
            if !savedScores.isEmpty {
                let cachedList = stringToList(savedScores, ",")
                for cachedScore in cachedList {
                    let savedScore = cachedScore.split(separator: "|")[0]
                    let savedLeaderboard = cachedScore.split(separator: "|")[1]
                    
                    var savedUUID = ""
                    if cachedScore.split(separator: "|").count > 2 {
                        savedUUID = String(cachedScore.split(separator: "|")[2])
                    }
                    else {
                        savedUUID = UUID().uuidString
                    }
                    
                    APIManager().apiCall(urlPath: "/client/leaderboards/\(leaderboardId)/report_score", method: .post, parameters: ["id": savedUUID, "leaderboard_id": savedLeaderboard, "score": savedScore], publishableKey: publishableKey) { _ in }
                }
            }
            
            APIManager().apiCall(urlPath: "/client/leaderboards/\(leaderboardId)/report_score", method: .post, parameters: ["id": UUID().uuidString, "leaderboard_id": leaderboardId, "score": score], publishableKey: publishableKey) { _ in }
        }
    }
    
    @objc public func show(leaderboardId: String){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(leaderboardId: leaderboardId)
            }
           return
        }
        
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            let url = URL(string: "https://app.galaxy.us/leaderboards/\(leaderboardId)?token=\(galaxyToken)&combo=true")
            currentWebViewController = WebViewController()
            currentWebViewController!.url = url
            if let currentViewController = getCurrentViewController() {
                currentWebViewController!.modalPresentationStyle = .fullScreen
                currentViewController.present(currentWebViewController!, animated: true, completion: nil)
            }
        }
    }
    
    @objc public func showClan(clanId: String, leaderboardId: String){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showClan(clanId: clanId, leaderboardId: leaderboardId)
                return
            }
        }
        
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            let url = URL(string: "https://app.galaxy.us/leaderboards/\(leaderboardId)/clans/\(clanId)?token=\(galaxyToken)&combo=true")
            currentWebViewController = WebViewController()
            currentWebViewController!.url = url
            if let currentViewController = getCurrentViewController() {
                currentWebViewController!.modalPresentationStyle = .fullScreen
                currentViewController.present(currentWebViewController!, animated: true, completion: nil)
            }
        }
    }
    
    @objc public func showAvatarEditor(){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showAvatarEditor()
                return
            }
        }
        
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            let playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId") ?? ""
            let url = URL(string: "https://app.galaxy.us/players/\(playerIdString)/edit?token=\(galaxyToken)&combo=true")
            currentWebViewController = WebViewController()
            currentWebViewController!.url = url
            if let currentViewController = getCurrentViewController() {
                currentWebViewController!.modalPresentationStyle = .fullScreen
                currentViewController.present(currentWebViewController!, animated: true, completion: nil)
            }
        }
    }
    
    @objc public func showChannel(channelId: String){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showChannel(channelId: channelId)
                return
            }
        }
        
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            let url = URL(string: "https://app.galaxy.us/channels/\(channelId)?token=\(galaxyToken)&combo=true")
            currentWebViewController = WebViewController()
            currentWebViewController!.url = url
            if let currentViewController = getCurrentViewController() {
                currentWebViewController!.modalPresentationStyle = .fullScreen
                currentViewController.present(currentWebViewController!, animated: true, completion: nil)
            }
        }
    }
    
    @objc public func showProfile(playerId: String?){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showProfile(playerId: playerId)
                return
            }
        }
        
        if let galaxyToken = UserDefaults.standard.string(forKey: "galaxyToken"){
            var playerIdString = playerId
            if(playerId == nil){
                playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId")
            }
            let url = URL(string: "https://app.galaxy.us/players/\(playerIdString ?? "")?token=\(galaxyToken)&combo=true")
            currentWebViewController = WebViewController()
            currentWebViewController!.url = url
            if let currentViewController = getCurrentViewController() {
                currentWebViewController!.modalPresentationStyle = .fullScreen
                currentViewController.present(currentWebViewController!, animated: true, completion: nil)
            }
        }
    }
    
    @objc public func signIn(shouldCloseOnCompletion: Bool = true){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.signIn(shouldCloseOnCompletion: shouldCloseOnCompletion)
                return
            }
        }
        
        let url = URL(string: "https://app.galaxy.us/sign_in")
        currentWebViewController = WebViewController()
        currentWebViewController!.url = url
        if let currentViewController = getCurrentViewController() {
            currentWebViewController!.modalPresentationStyle = .fullScreen
            currentViewController.present(currentWebViewController!, animated: true, completion: nil)
        }
    }

    
    @objc public func hide(){
        if let c = currentWebViewController{
            c.dismiss(animated: true)
        }
    }
    
    @objc public func getPlayerRecord(leaderboardId: String, playerId: String?, completion: @escaping (LeaderboardRecord?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getPlayerRecord(leaderboardId: leaderboardId, playerId: playerId, completion: completion)
                return
            }
        }
        
        var playerIdString = playerId
        if(playerId == nil){
            playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId")
        }
        
        APIManager().apiCall(urlPath: "/client/leaderboards/\(leaderboardId)/players/\(playerIdString ?? "")", method: .get, parameters: nil, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let playerRecord = try decoder.decode(PlayerRecordApiResponse.self, from: data)
                    return completion(playerRecord.data.record)
                } catch {
                    return completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                return completion(nil)
            }
        }
    }

    @objc public func getCurrentClan(completion: @escaping (Clan?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getCurrentClan(completion: completion)
                return
            }
        }
        
        APIManager().apiCall(urlPath: "/client/clans/current", method: .get, parameters: nil, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let clan = try decoder.decode(ClanApiResponse.self, from: data)
                    return completion(clan.data.clan)
                } catch{
                    return completion(nil)
                }
            case .failure(let error):
                if(error.localizedDescription.contains("404")){
                    print("This user is not part of a clan")
                } else{
                    print("Error: \(error.localizedDescription)")
                }
                return completion(nil)
            }
        }
    }
    
    @objc public func findOpponent(leaderboardId: String, completion: @escaping (LeaderboardRecord?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.findOpponent(leaderboardId: leaderboardId, completion: completion)
                return
            }
        }
        
        APIManager().apiCall(urlPath: "/client/leaderboards/\(leaderboardId)/find_opponent?leaderboard_id=\(leaderboardId)&first_bound=-25&second_bound=25", method: .get, parameters: nil, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let opponent = try decoder.decode(PlayerRecordApiResponse.self, from: data)
                    return completion(opponent.data.record)
                } catch let error{
                    print(error)
                    return completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                return completion(nil)
            }
        }

    }
    
    
    @objc public func saveState(state: String, completion: @escaping (Bool) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.saveState(state: state, completion: completion)
                return
            }
        }
        
        APIManager().apiCall(urlPath: "/client/players/save_state", method: .post, parameters: ["state": state], publishableKey: publishableKey) { result in
            switch(result){
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    @objc public func getState(completion: @escaping (String?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getState(completion: completion)
                return
            }
        }
        
        APIManager().apiCall(urlPath: "/client/players/get_state", method: .get, parameters: nil, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let state = try decoder.decode(State.self, from: data)
                    return completion(state.data.state as String)
                } catch{
                    return completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                return completion(nil)
            }
        }
    }
    
    @objc public func getPlayerProfile(playerId: String?, completion: @escaping (PlayerProfile?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getPlayerProfile(playerId: playerId, completion: completion)
                return
            }
        }
        
        var playerIdString = playerId
        if(playerId == nil){
            playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId") ?? ""
        }
        
        
        APIManager().apiCall(urlPath: "/client/players/\(playerIdString!)/profile", method: .get, parameters: nil, publishableKey: publishableKey) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let player = try decoder.decode(PlayerProfileApiResponse.self, from: data)
                    return completion(player.data)
                } catch let error{
                    print(error)
                    return completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                return completion(nil)
            }
        }
    }
    
    @objc public func updatePlayerProfile(nickname: String, completion: @escaping (Bool) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updatePlayerProfile(nickname: nickname, completion: completion)
                return
            }
        }
        let playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId") ?? ""

        APIManager().apiCall(urlPath: "/client/players/\(playerIdString)/profile", method: .patch, parameters: ["player_id": playerIdString, "nickname": nickname], publishableKey: publishableKey) { result in
            switch(result){
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }

    }
    
    @objc public func getPlayerAvatarTexture(playerId: String? = nil, completion: @escaping (UIImage?) -> Void){
        if configurationInProgress{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getPlayerAvatarTexture(playerId: playerId, completion: completion)
                return
            }
        }
        
        var playerIdString = playerId
        if(playerId == nil){
            playerIdString = UserDefaults.standard.string(forKey: "galaxyPlayerId") ?? ""
        }
        
        let url = URL(string: "https://api.galaxysdk.com/api/v1/users/\(playerIdString!)/avatar.png")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
    @objc func uploadContacts(contactsObject: [String: Any]){
        APIManager().apiCall(urlPath: "/users/update_contacts", method: .post, parameters: contactsObject, publishableKey: publishableKey) { _ in }
    }
    
    
    private func stringToList(_ message: String, _ separator: String) -> [String] {
        var exportList = [String]()
        var tok = ""
        for character in message {
            tok.append(character)
            if tok.contains(separator) {
                tok = tok.replacingOccurrences(of: separator, with: "")
                exportList.append(tok)
                tok = ""
            }
        }
        return exportList
    }
    
    func saveTokenAndPlayerId(token: String){
        UserDefaults.standard.set(token, forKey: "galaxyToken")
        let playerId = getPlayerIdFromJWT(token: token)
        UserDefaults.standard.set(playerId, forKey: "galaxyPlayerId")
    }
    
    private func getPlayerIdFromJWT(token: String) -> String {
        let parts = token.components(separatedBy: ".")
        if parts.count > 2 {
            let decode = parts[1]
            let padLength = 4 - decode.count % 4
            var decodedData = Data(base64Encoded: decode, options: [.ignoreUnknownCharacters])
            if padLength < 4 {
                decodedData?.append(Data(count: padLength))
            }
            if let decodedBytes = decodedData {
                let userInfo = String(data: decodedBytes, encoding: .utf8)!
                print(userInfo)
                if userInfo.contains("user_id") {
                    if let range = userInfo.range(of: "\"user_id\":\"") {
                        let startIndex = userInfo.index(range.upperBound, offsetBy: 0)
                        if let endIndex = userInfo[startIndex...].range(of: "\"")?.lowerBound {
                            let playerId = String(userInfo[startIndex..<endIndex])
                            return playerId
                        } else {
                            print("End delimiter not found")
                        }
                    } else {
                        print("Start delimiter not found")
                    }
                }
            }
        }
        return ""
    }

    private func getCurrentViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController
        else {
            return nil
        }


        var currentViewController = rootViewController

        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }

        return currentViewController
    }
    
}
