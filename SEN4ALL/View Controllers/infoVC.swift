//
//  infoVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit

class infoVC: UIViewController {

    @IBAction func exitAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
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
