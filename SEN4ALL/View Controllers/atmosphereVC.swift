//
//  atmosphereVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit

class atmosphereVC: UIViewController {
    
    @IBOutlet weak var S5B1: UIButton!
    @IBOutlet weak var S5B2: UIButton!
    @IBOutlet weak var S5B3: UIButton!
    @IBOutlet weak var S5B4: UIButton!
    @IBOutlet weak var S5B5: UIButton!
    @IBOutlet weak var S5B6: UIButton!
    
    let persistStorage = UserDefaults.standard

    @IBAction func selectS5(_ sender: UIButton) {
        updateUI()
        sender.drawSelectedLayer()
        persistStorage.setValue(2, forKey: "context")
        persistStorage.setValue(5, forKey: "satellite")
        persistStorage.setValue(sender.tag, forKey: "layer")
        NotificationCenter.default.post(name: .applyLayer, object: nil)
    }
    
    // MARK: - Helpers
    
    
    func updateUI() {
        S5B1.drawBorderOrange()
        S5B2.drawBorderOrange()
        S5B3.drawBorderOrange()
        S5B4.drawBorderOrange()
        S5B5.drawBorderOrange()
        S5B6.drawBorderOrange()
        
      
        
    }
    
    func selectLayer(layer: Int) {
        if persistStorage.integer(forKey: "satellite") == 5 {
            switch layer {
            case 1:
                S5B1.drawSelectedLayer()
            case 2:
                S5B2.drawSelectedLayer()
            case 3:
                S5B3.drawSelectedLayer()
            case 4:
                S5B4.drawSelectedLayer()
            case 5:
                S5B5.drawSelectedLayer()
            case 6:
                S5B6.drawSelectedLayer()
            default:
                print("error layer")
                
            }
            
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
        
        updateUI()
        
        let context = persistStorage.integer(forKey: "context")
        if context == 2 {
            let layer = persistStorage.integer(forKey: "layer")
            selectLayer(layer: layer)
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
