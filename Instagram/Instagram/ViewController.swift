//
//  ViewController.swift
//  Instagram
//
//  Created by Optisol on 31/07/18.
//  Copyright © 2018 Optisol. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional set up

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func instagramShare(_ sender: UIButton){
        //Share Image and Video
        let instagramShare = SocialShare.init()
        let url = URL(string:"https://d1wfecrvohrb6s.cloudfront.net/small/119/4218397D-AFDF-4318-91A2-FB583E5D6E70-5009-000003F6620C6FF9.png")
        if let data = try? Data(contentsOf: url!){
            let image: UIImage = UIImage(data: data)!
            instagramShare.executeInstagramShare("image", image:image , videoUrl: nil, from: self, locationString: "")
        }else{
            let alertView = UIAlertController(title: "", message: "Please install the instagram app on your device", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)

        }

    }


}

