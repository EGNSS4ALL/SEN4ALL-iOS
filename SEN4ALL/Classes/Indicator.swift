//
//  Indicator.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 20/09/21.
//

import Foundation
import UIKit
import Lottie

public class Indicator {

    public static let sharedInstance = Indicator()
    var blurImg = UIImageView()
    let animationView = LottieAnimationView(name: "sen4all_loader")
    


    init()
    {
        blurImg.frame = UIScreen.main.bounds
        blurImg.backgroundColor = UIColor.black
        blurImg.isUserInteractionEnabled = true
        blurImg.alpha = 0
        blurImg.applyBlurEffect()
        animationView.frame = CGRect(x: (blurImg.frame.size.width)/2 - 50, y: blurImg.frame.size.height/2 - 50, width: 100, height: 100)
    
        //animationView.center = self.container.center
        animationView.contentMode = .scaleAspectFill
        
        /*container.layer.shadowColor = UIColor(named: "primary")?.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = .zero
        container.layer.shadowRadius = 8*/
        
        
               
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
        
        
    }

    func showIndicator(alphaBlur: CGFloat, viewToAdd: UIView){
        DispatchQueue.main.async( execute: {
            let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    
            
            
            //windows!.addSubview(self.blurImg)
            self.animationView.frame = CGRect(x: viewToAdd.frame.origin.x-64, y: viewToAdd.frame.origin.y, width: 56, height: 56)
            windows!.addSubview(self.animationView)
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn]) {self.blurImg.alpha = alphaBlur} completion: { (status) in }
            self.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
            //let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            //windows!.addSubview(self.animationView)
        })
    }
    func hideIndicator(){

        DispatchQueue.main.async( execute:
            {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn]) {self.blurImg.alpha = 0} completion: { (status) in
                self.blurImg.removeFromSuperview()
                self.animationView.removeFromSuperview()
                
            }
               
        })
    }
}

