//
//  ConnectivityViewController.swift
//  App
//
//  Created by Lucas Assis Rodrigues on 12/12/2017.
//  Copyright © 2017 Apple Dev Academy. All rights reserved.
//

import UIKit
import ConnectivityServices
import MultipeerConnectivity
import SCLAlertView

class ConnectivityViewController: UIViewController, ChatServiceDelegate {

    var isGame = true
    var people: [UserProfile] = []
    let alertAppearence = SCLAlertView.SCLAppearance(kCircleIconHeight: -56,
                                                     kTitleFont: UIFont(name: "Futura-Bold", size: 17)!,
                                                     kTextFont: UIFont(name: "Futura-Medium", size: 14)!,
                                                     kButtonFont: UIFont(name: "Futura-Medium", size: 17)!,
                                                     showCloseButton: false,
                                                     showCircularIcon: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceManager.instance.chatService.delegate = self
        self.setDiscoveryInfo(from: ServiceManager.instance.userProfile)
        self.updateVisibility()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        ServiceManager.instance.chatService.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ServiceManager.instance.chatService.delegate = self
    }
    
    func updateVisibility() {
        if (ServiceManager.instance.userProfile.status != Status.ghost) {
            ServiceManager.instance.chatService.serviceAdvertiser.startAdvertisingPeer()
            ServiceManager.instance.chatService.serviceBrowser.startBrowsingForPeers()
        } else {
            ServiceManager.instance.chatService.serviceAdvertiser.stopAdvertisingPeer()
            ServiceManager.instance.chatService.serviceBrowser.stopBrowsingForPeers()
        }
    }
    
    func setDiscoveryInfo(from profile: ProfileRequirements) {
        let userProfile = ServiceManager.instance.userProfile
        let info = ["avatarHair": userProfile.avatar[AvatarParts.hair]!,
                    "avatarFace": userProfile.avatar[AvatarParts.face]!,
                    "avatarSkinTone": userProfile.avatar[AvatarParts.skin]!,
                    "username": userProfile.username,
                    "moodOne": userProfile.moods[0].enumToString,
                    "moodTwo": userProfile.moods[1].enumToString,
                    "moodThree": userProfile.moods[2].enumToString,
                    "status":  userProfile.status.enumToString]
        ServiceManager.instance.chatService.discoveryInfo = info
    }
    
    func invitePeer(withId id: MCPeerID, profile: ProfileRequirements) {
        if let userBeingInvited = profile as? UserProfile {
            
            let alert = SCLAlertView(appearance: self.alertAppearence)
            let serviceBrowser = ServiceManager.instance.chatService.serviceBrowser
            alert.addButton("Game") {
                self.isGame = true
                ServiceManager.instance.selectedPeer = id
                GameViewControlller.randomEmoji = GameViewControlller.randomizeEmoji()
                GameViewControlller.isPlayerOne = true
                serviceBrowser.invitePeer(id,
                                          to: ServiceManager.instance.chatService.session,
                                          withContext: ConnectivityViewController.createUserData(for: "game"),
                                          timeout: 20)
            }
            
            alert.addButton("Chat") {
                self.isGame = false
                ServiceManager.instance.selectedPeer = id
                serviceBrowser.invitePeer(id,
                                          to: ServiceManager.instance.chatService.session,
                                          withContext: ConnectivityViewController.createUserData(for: "chat"),
                                          timeout: 20)
            }
            
            alert.addButton("Cancel", backgroundColor: UIColor.red) {
                UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.light).impactOccurred()
            }
            
            OperationQueue.main.addOperation {
                alert.showInfo(userBeingInvited.username,
                               subTitle: "Send invitation for",
                               colorStyle: userBeingInvited.avatarSkin.toHexUInt(),
                               circleIconImage: UIImage.imageByCombiningImage(firstImage: userBeingInvited.avatarFace!, withImage: userBeingInvited.avatarHair!))
            }
        }
    }
    
    func handleInvitation(from: MCPeerID, withContext context: Data?) {
        if let context = context {
            if let data = String(data: context, encoding: String.Encoding.utf8) {
                
                let chatService = ServiceManager.instance.chatService
                let userData = ConnectivityViewController.decodeUserData(from: data)
                let invitationText = userData[DecodedUserDataKeys.interactionType] == "chat" ? "chat." : "to play a game."
                let alert = SCLAlertView(appearance: self.alertAppearence)
                
                alert.addButton("Accept") {
                    self.isGame = userData[DecodedUserDataKeys.interactionType]! == "game"
                    GameViewControlller.randomEmoji = userData[DecodedUserDataKeys.emoji]!
                    GameViewControlller.isPlayerOne = false
                    ServiceManager.instance.selectedPeer = from
                    chatService.invitationHandler(true, chatService.session)
                }
                
                alert.addButton("Refuse", backgroundColor: UIColor.red) {
                    UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.heavy).impactOccurred()
                    chatService.invitationHandler(false, chatService.session)
                }
                
                OperationQueue.main.addOperation {
                    alert.showInfo(userData[DecodedUserDataKeys.username]!,
                                   subTitle: "Is inviting you to \(invitationText)",
                        colorStyle: Colours.getColour(named: userData[DecodedUserDataKeys.avatarSkinTone]!,
                                                      index: Int(userData[DecodedUserDataKeys.avatarSkinToneIndex]!)).toHexUInt(),
                        circleIconImage: UIImage.imageByCombiningImage(firstImage: UIImage(named: userData[DecodedUserDataKeys.avatarHair]!)!,
                                                                       withImage: UIImage(named: userData[DecodedUserDataKeys.avatarFace]!)!))
                }
            }
        }
    }
    
    func handleMessage(from: MCPeerID, message: String) {
        let (key, value) = (message.components(separatedBy: "|")[0], message.components(separatedBy: "|")[1])
        print("handleMessage------", message)
        switch key {
        case MPCMessageTypes.closeConnection:
            sleep(1)
            ServiceManager.instance.chatService.session.disconnect()
            OperationQueue.main.addOperation {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            break
        case MPCMessageTypes.emoji:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "received_emoji"), object: nil, userInfo: ["emoji": value])
            break
        default:
            break
        }
        
    }
    
    func peerFound(withId id: MCPeerID) {
        self.updateFoundPeers()
    }
    
    func peerLost(withId id: MCPeerID) {
        if (self.people.count > 0) {
            for i in 0 ... self.people.count - 1 {
                if self.people[0].id == id.displayName.components(separatedBy: "|")[0] {
                    self.people.remove(at: i)
                    break
                }
            }
        }
    }
    
    func connectedSuccessfully(with id: MCPeerID) {
        OperationQueue.main.addOperation {
            if (self.isGame) {
                self.show(UIStoryboard(name: "Interactions", bundle: nil).instantiateViewController(withIdentifier: "GameViewController"), sender: self)
            } else {
                self.show(UIStoryboard(name: "Interactions", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController"), sender: self)
            }
        }
    }
    
    func connectionLost() {
    }
    
    func updateFoundPeers() {
        self.people.removeAll()
        let peers = ServiceManager.instance.chatService.peers
        let infos = ServiceManager.instance.chatService.peersDiscoveryInfos
        if peers.count > 0 {
            for i in 0 ... peers.count - 1 {
                self.people.append(UserProfile(id: peers[i].displayName.components(separatedBy: "|")[0],
                                               username: infos[i][DecodedUserDataKeys.username.enumToString]!,
                                               avatar: [AvatarParts.hair: infos[i][DecodedUserDataKeys.avatarHair.enumToString]!,
                                                        AvatarParts.face: infos[i][DecodedUserDataKeys.avatarFace.enumToString]!,
                                                        AvatarParts.skin: infos[i][DecodedUserDataKeys.avatarSkinTone.enumToString]!],
                                               moods: [Mood.stringToEnum(from: infos[i][DecodedUserDataKeys.moodOne.enumToString]!),
                                                       Mood.stringToEnum(from: infos[i][DecodedUserDataKeys.moodTwo.enumToString]!),
                                                       Mood.stringToEnum(from:infos[i][DecodedUserDataKeys.moodThree.enumToString]!)],
                                               status: Status.stringToEnum(from: infos[i][DecodedUserDataKeys.status.enumToString]!)))
            }
        }
    }
    
    @IBAction func unwindToListTableView(segue:UIStoryboardSegue) { }

    
    static func createUserData(for interaction: String) -> Data {
        let userProfile = ServiceManager.instance.userProfile
        let data = "\(userProfile.username)|" +
            "\(userProfile.avatar[AvatarParts.hair]!)|" +
            "\(userProfile.avatar[AvatarParts.face]!)|" +
            "\(userProfile.avatar[AvatarParts.skin]!)|" + // skinColour|index
            "\(userProfile.moods[0].enumToString)|" +
            "\(userProfile.moods[1].enumToString)|" +
            "\(userProfile.moods[2].enumToString)|" +
        "\(userProfile.status.enumToString)|"
        return (interaction == "chat" ? data + "chat|\(GameViewControlller.randomEmoji)" : data + "game|\(GameViewControlller.randomEmoji)").data(using: String.Encoding.utf8)!  // has 10 components separeted by |
    }
    
    static func decodeUserData(from data: String) -> [DecodedUserDataKeys : String] {
        let userData = data.components(separatedBy: "|")
        return [.username: userData[0],
                .avatarHair: userData[1],
                .avatarFace: userData[2],
                .avatarSkinTone: userData[3],
                .avatarSkinToneIndex: userData[4],
                .moodOne: userData[5],
                .moodTwo: userData[6],
                .moodThree: userData[7],
                .status: userData[8],
                .interactionType: userData[9],
                .emoji: userData[10]]
    }
}
