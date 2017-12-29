//
//  FirstViewController.swift
//  FirstMini
//
//  Created by Alessio Tortello on 11/12/2017.
//  Copyright © 2017 Alessio Tortello. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MapViewController: ConnectivityViewController {
    
    @IBOutlet var panCircleView: UIPanGestureRecognizer!
    @IBOutlet var tapCircleView: UITapGestureRecognizer!
    @IBOutlet var transparencyView: UIView!
    @IBOutlet var invitationView: UIView!
    @IBOutlet weak var avatarFrameView: RoundView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var gameButton: RoundButton!
    @IBOutlet weak var chatButton: RoundButton!
    
    var circleView: CircleView!
    var avatarButtons: [String: AvatarPlanetButton] = [:]
    var selectedAvatarButton: AvatarPlanetButton? = nil {
        willSet {
            if let value = newValue {
                self.previousSelectedAvatarButtonCenter = value.center
                self.previousSelectedAvatarButtonCenter!.x -= self.circleView.translation.x
                self.previousSelectedAvatarButtonCenter!.y -= self.circleView.translation.y
            } else {
                self.previousSelectedAvatarButtonCenter = nil
            }
        }
    }
    
    var previousSelectedAvatarButtonCenter: CGPoint? = nil
    
    var isPromptVisible: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.35) {
                if (self.isPromptVisible) {
                    self.transparencyView.alpha = 0.7
                    self.invitationView.alpha = 1
                    self.avatarFrameView.alpha = 1
                    self.circleView.alpha = 0
                    for (_ , button) in self.avatarButtons {
                        if (button != self.selectedAvatarButton) {
                            button.alpha = 0
                        }
                    }
                } else {
                    self.transparencyView.alpha = 0
                    self.invitationView.alpha = 0
                    self.avatarFrameView.alpha = 0
                    self.circleView.alpha = 1
                    for (_ , button) in self.avatarButtons {
                        button.alpha = 1
                    }
                }
            }
        }
    }
    
    var isGestureEnabled: Bool = true {
        didSet {
            self.panCircleView.isEnabled = self.isGestureEnabled
            self.tapCircleView.isEnabled = self.isGestureEnabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIViewController.setViewBackground(for: self)
        self.setUpPromptViews()
        self.circleView = CircleView(frame: self.view.frame)
        self.circleView.isUserInteractionEnabled = true
        self.circleView.radius = 60
        self.circleView.delegate = self
        self.view.addSubview(self.circleView)
        self.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func peerFound(withId id: MCPeerID) {
        super.peerFound(withId: id)
        self.reloadData()
    }
    
    override func peerLost(withId id: MCPeerID) {
        super.peerLost(withId: id)
        self.avatarButtons.removeValue(forKey: id.displayName.components(separatedBy: "|")[0])
        self.reloadData()
    }
    
    @IBAction func panCircles(_ sender: UIPanGestureRecognizer) {
        if self.people.count != 0 {
            switch sender.state {
            case UIGestureRecognizerState.began:
                break
            case UIGestureRecognizerState.changed:
                let translation = sender.translation(in: self.view)
                self.circleView.center = CGPoint(x: self.circleView.center.x + translation.x, y: self.circleView.center.y + translation.y)
                for (_, button) in self.avatarButtons {
                    button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
                }
                
                self.circleView.translation.x += translation.x
                self.circleView.translation.y += translation.y
                sender.setTranslation(CGPoint.zero, in: self.view)
                break
            case UIGestureRecognizerState.ended:
                UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseOut,
                               animations: self.translateCirclesWith(velocity: sender.velocity(in: self.view)),
                               completion: nil)
                break
            default:
                break
            }
        }
    }
    
    @IBAction func tapCenterCircles(_ sender: UITapGestureRecognizer) {
        self.isGestureEnabled = false
        self.centerCircles()
    }
    
    @IBAction func showInvitationPrompt(_ sender: AvatarPlanetButton) {
        if (sender.center != self.view.center) {
            self.selectedAvatarButton = sender
            self.centerCircles()
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseOut,
                           animations: self.translateCirclesWith(button: sender), completion: nil)
            self.isPromptVisible = true
            self.isGestureEnabled = false
            self.view.insertSubview(self.invitationView, belowSubview: self.selectedAvatarButton! )
            self.usernameLabel.text = self.selectedAvatarButton!.userNameLabel.text
            self.gameButton.backgroundColor = self.selectedAvatarButton!.faceImageView.backgroundColor
            self.chatButton.backgroundColor = self.selectedAvatarButton!.faceImageView.backgroundColor
        }
    }
    
    @IBAction func dismissInvitationPrompt(_ sender: RoundButton) {
        UIView.animate(withDuration: 0.35,
                       animations: {
                        if let button = self.selectedAvatarButton {
                            if let center = self.previousSelectedAvatarButtonCenter {
                                button.center = center
                            }
                        }
        }, completion: { finished in
            if (finished) {
                self.selectedAvatarButton = nil
            }
        })
        self.isPromptVisible = false
    }
    
    func centerCircles() {
        UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: self.translateCirclesWith(),
                       completion: { finished in if (finished) { self.circleView.translation = (0,0); self.isGestureEnabled = true }
        })
    }
    
    func reloadData() {
        self.centerCircles()
        if (self.people.count > 0) {
            for view in self.view.subviews {
                if let button = view as? AvatarPlanetButton {
                    button.removeFromSuperview()
                }
            }
            
            var peersMissing = self.people.count
            var circlePopulation = 1
            var circleIndex = 0
            
            while (peersMissing > 0) {
                peersMissing -= circlePopulation
                circlePopulation += (circleIndex + 1)
                circleIndex += 1
            }
            
            self.circleView.numberOfCircles = circleIndex
            
            circleIndex = 0
            circlePopulation = 1
            for i in 0 ... self.people.count - 1 {
                let button = AvatarPlanetButton.createAvatarButton(from: self.people[i], size: CGSize(width: 65, height: 65))
                repeat {
                    let center = self.circleView.points[Int(arc4random_uniform(UInt32(361))) + 361 * self.circleView.circleFirstIndex[circleIndex] ]
                    button.center = CGPoint(x: center.x, y: center.y)
                } while (self.checkButtonColision(button))
                
                button.addTarget(self, action: #selector(showInvitationPrompt(_:)), for: UIControlEvents.touchUpInside)
                self.avatarButtons[self.people[i].id] = button
                self.view.addSubview(button)
                if (i == 0 || circlePopulation == i) {
                    circleIndex += 1
                    circlePopulation += i + 1
                }
            }
        }
    }
    
    private func setUpPromptViews() {
        self.invitationView.center = self.view.center
        self.avatarFrameView.frame.size = CGSize(width: 70, height: 70)
        self.avatarFrameView.circle = true
        self.avatarFrameView.center = CGPoint(x: self.view.frame.width / 2, y: self.invitationView.frame.origin.y)
    }
    
    private func checkButtonColision(_ button: AvatarPlanetButton) -> Bool {
        let margins: CGFloat = 10
        let extendedFrame = CGRect(origin: button.frame.origin,
                                   size: CGSize(width: button.frame.width + margins,
                                                height: button.frame.height + margins))
        for (_, existingButton) in self.avatarButtons {
            let existingFrame = CGRect(x: existingButton.frame.origin.x - margins / 2,
                                       y: existingButton.frame.origin.y - margins / 2,
                                       width: existingButton.frame.size.width + margins,
                                       height: existingButton.frame.size.height + margins)
            if (extendedFrame.intersects(existingFrame)) {
                return true
            }
        }
        
        return false
    }
    
    private func translateCirclesWith(button: AvatarPlanetButton? = nil, velocity: CGPoint? = nil) -> () -> Void {
        if let velocity = velocity {
            return {
                let x = (velocity.x * 0.1)
                let y = (velocity.y * 0.1)
                self.circleView.center = CGPoint(x: self.circleView.center.x + x, y: self.circleView.center.y + y)
                for (_, button) in self.avatarButtons {
                    button.center = CGPoint(x: button.center.x + x, y: button.center.y + y)
                }
                
                self.circleView.translation.x += x
                self.circleView.translation.y += y
            }
        } else if let sender = button {
            return  {
                sender.center = self.avatarFrameView.center
            }
        } else {
            return  {
                self.circleView.center.x -= self.circleView.translation.x
                self.circleView.center.y -= self.circleView.translation.y
                for (_, button) in self.avatarButtons {
                    if (button != self.selectedAvatarButton) {
                        button.center.x -= self.circleView.translation.x
                        button.center.y -= self.circleView.translation.y
                    }
                }
            }
        }
    }
}

extension MapViewController: CircleViewDelegate  {
    func handleDrawingCompletion() {
        for (_, button) in self.avatarButtons {
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: { button.alpha = 1 },
                           completion: nil)
        }
    }
}

