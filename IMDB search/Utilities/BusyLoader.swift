//
//  BusyLoader.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import UIKit
class BusyLoader {
    static var overlayView:UIView?
    static var activityIndicator:UIActivityIndicatorView?
    static func showBusyIndicator(mainView :UIView){
        if(self.overlayView == nil || (self.overlayView?.isHidden)!){
            self.overlayView = UIView.init(frame: UIScreen.main.bounds)
            
            self.overlayView!.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
            self.activityIndicator = UIActivityIndicatorView(style: .gray)
            self.activityIndicator!.center.x = self.overlayView!.center.x
            self.activityIndicator!.center.y = self.overlayView!.center.y - 15
            self.overlayView!.addSubview(self.activityIndicator!)
            self.activityIndicator!.startAnimating()
            mainView.addSubview(self.overlayView!)
        }
        
    }
    
    static func hideBusyIndicator(){
        self.overlayView!.isHidden=true
    }
    
    static func isLoading()->Bool{
        return self.overlayView?.isHidden == false
    }
}
