//
//  ViewController.swift
//  AppEstados
//
//  Created by Karla Ayala on 23/06/25.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var btnAprender: UIButton!
    @IBOutlet weak var btnPrueba: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
    }

  
    @IBAction func btnAprender(_ sender: UIButton) {
//        performSegue(withIdentifier: "IrMapa", sender: self)
        let vc = MapaViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    @IBAction func btnPrueba(_ sender: UIButton) {
        //performSegue(withIdentifier: "IrCuestionario", sender: self)
        let vc = CuestionarioViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    

    
    
}

