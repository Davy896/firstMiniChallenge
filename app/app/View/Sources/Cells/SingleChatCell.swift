//
//  Messages.swift
//  App
//
//  Created by Davide Contaldo on 14/12/17.
//  Copyright © 2017 Apple Dev Academy. All rights reserved.
//

import UIKit


class SingleChatCell: UICollectionViewCell {
    
    
    var message: Messages? {
        didSet {
            nameLabel.text = message?.username
            profileImageHair.image = UIImage(named: (message?.avatarHair)!)
            profileImageEyes.image = UIImage(named: (message?.avatarEyes)!)
            profileImageSkinColor.image = UIImage(named: (message?.avatarSkinColor)!)
            messageLabel.text = message?.text
//            cloud.image = #imageLiteral(resourceName: "right")
//            tail.image = #imageLiteral(resourceName: "tail3")
        }
    }
    
    
    
  
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    
    var cloud: UIView = {
        var image = UIView()
//        image = #imageLiteral(resourceName: "right")
        image.backgroundColor = UIColor.blue
        image.layer.cornerRadius = 15
        image.alpha = 0
        
        return image
    }()
    
    let messageLabel: UITextView = {
        let label = UITextView()
        label.text = ""
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 18)
        label.layer.cornerRadius = 15
        label.isEditable = false
        label.alpha = 0
        return label
    }()
    
    let mounth: UIImageView = {
        var image = UIImageView()
        //        image = #imageLiteral(resourceName: "right")
//        image.backgroundColor = UIColor.blue
        image.layer.cornerRadius = 15
//        image.alpha = 0
        
        return image
    }()

    
    
    let profileImageHair: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.alpha = 0
        return imageView
    }()
    
    let profileImageEyes: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.alpha = 0
        return imageView
    }()
    
    let profileImageSkinColor: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.alpha = 0
        return imageView
    }()
    
    let tail: UIImageView = {
        var tailImage = UIImageView()
//        tailImage.image = #imageLiteral(resourceName: "Path")
        tailImage.alpha = 0
        return tailImage
    }()
    
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
    
    override init(frame: CGRect) {
       
        super.init(frame: frame)
         setupView()
        
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        backgroundColor = UIColor.clear
        addSubview(mounth)
        addSubview(cloud)
        addSubview(messageLabel)
        addSubview(profileImageHair)
        addSubview(profileImageEyes)
        addSubview(profileImageSkinColor)
        addSubview(tail)
    }

}




