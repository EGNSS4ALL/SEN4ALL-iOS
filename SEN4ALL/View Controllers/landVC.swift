//
//  layersVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit

class landVC: UIViewController {

    @IBOutlet weak var S1B1: UIButton!
    @IBOutlet weak var S1B2: UIButton!
    @IBOutlet weak var S1B3: UIButton!
    @IBOutlet weak var S1B4: UIButton!
    @IBOutlet weak var S1B5: UIButton!
    @IBOutlet weak var S2B1: UIButton!
    @IBOutlet weak var S2B2: UIButton!
    @IBOutlet weak var S3B1: UIButton!
    @IBOutlet weak var S3B2: UIButton!
    
    let persistStorage = UserDefaults.standard
    
    @IBAction func selectS1(_ sender: UIButton) {
        updateUI()
        sender.drawSelectedLayer()
        persistStorage.setValue(0, forKey: "context")
        persistStorage.setValue(1, forKey: "satellite")
        persistStorage.setValue(sender.tag, forKey: "layer")
        NotificationCenter.default.post(name: .applyLayer, object: nil)
    }
    
    @IBAction func selectS2(_ sender: UIButton) {
        updateUI()
        sender.drawSelectedLayer()
        persistStorage.setValue(0, forKey: "context")
        persistStorage.setValue(2, forKey: "satellite")
        persistStorage.setValue(sender.tag, forKey: "layer")
        NotificationCenter.default.post(name: .applyLayer, object: nil)
    }
    
    
    @IBAction func selectS3(_ sender: UIButton) {
        updateUI()
        sender.drawSelectedLayer()
        persistStorage.setValue(0, forKey: "context")
        persistStorage.setValue(3, forKey: "satellite")
        persistStorage.setValue(sender.tag, forKey: "layer")
        NotificationCenter.default.post(name: .applyLayer, object: nil)
    }
    
    
    
    
    // MARK: - Helpers
    
    func updateUI() {
        S1B1.drawBorderOrange()
        S1B2.drawBorderOrange()
        S1B3.drawBorderOrange()
        S1B4.drawBorderOrange()
        S1B5.drawBorderOrange()
        
        S2B1.drawBorderOrange()
        S2B2.drawBorderOrange()
        
        S3B1.drawBorderOrange()
        S3B2.drawBorderOrange()
        
    }
    
    func selectLayer(layer: Int) {
        if persistStorage.integer(forKey: "satellite") == 1 {
            switch layer {
            case 1:
                S1B1.drawSelectedLayer()
            case 2:
                S1B2.drawSelectedLayer()
            case 3:
                S1B3.drawSelectedLayer()
            case 4:
                S1B4.drawSelectedLayer()
            case 5:
                S1B5.drawSelectedLayer()
            default:
                print("error layer")
                
            }
        } else if persistStorage.integer(forKey: "satellite") == 2 {
            switch layer {
            case 1:
                S2B1.drawSelectedLayer()
            case 2:
                S2B2.drawSelectedLayer()
            default:
                print("error layer")
                
            }
        } else if persistStorage.integer(forKey: "satellite") == 3 {
            switch layer {
            case 1:
                S3B1.drawSelectedLayer()
            case 2:
                S3B2.drawSelectedLayer()
            default:
                print("error layer")
                
            }
        }
        
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        
        
        updateUI()
        let context = persistStorage.integer(forKey: "context")
        if context == 0 {
            let layer = persistStorage.integer(forKey: "layer")
            selectLayer(layer: layer)
        }
        
        super.viewDidLoad()

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
