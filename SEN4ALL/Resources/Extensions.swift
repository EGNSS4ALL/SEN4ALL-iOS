//
//  Extensions.swift
//  SEN4ALL
//
//  Created by Gabriele Amendola on 02/10/23.
//

import Foundation
import UIKit
import CoreImage


// MARK: - Notification

extension Notification.Name {
    static let pageDataUpdated = Notification.Name("PageDataUpdated")
    static let applyLayer = Notification.Name("ApplyLayer")
    static let changeLayerPage = Notification.Name("ChangeLayerPage")
}


// MARK: - Button

extension UIButton {
    
   
    
    func circleBtn() {
        self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "LightColor")!.withAlphaComponent(0.9)
        self.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        self.layer.borderWidth = 1
        
    }
    func circleBtnOrange() {
        self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "AccentColor")!.withAlphaComponent(0.9)
        self.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        self.layer.borderWidth = 1
        
    }
    
    func normalBtn() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "LightColor")!.withAlphaComponent(0.9)
        self.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        self.layer.borderWidth = 1
    
    }
    
    func drawBorderOrange() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "LightColor")
        self.setTitleColor(UIColor(named: "DarkColor"), for: .normal)
    }
    
    func drawBorderOrangeFill() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "AccentColor")
        self.setTitleColor(UIColor(named: "LightColor"), for: .normal)
    }
    
    func drawSelectedLayer() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "AccentColor")
        self.setTitleColor(UIColor(named: "LightColor"), for: .normal)
    }
  
}

// MARK: - UIImage


extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

   
}

// MARK: - UIImageView

extension UIImageView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 1
        addSubview(blurEffectView)
    }
}

// MARK: - UIViewController

extension UIViewController {
    
    func alertStandard(title: String, text: String) {
        let sb = UIStoryboard(name: "Alerts", bundle: nil)
        let alertVC = sb.instantiateViewController(identifier: "alertVC") as! alertVC
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.titolo = title
        alertVC.messaggio = text
        alertVC.modalTransitionStyle = .crossDissolve
        self.present(alertVC, animated: true, completion: nil)
        
        
    }
    
    func removeWhiteBackground(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
                return nil
            }

            let width = cgImage.width
            let height = cgImage.height

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

            guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                return nil
            }

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

            if let data = context.data {
                let buffer = UnsafeMutableBufferPointer<UInt32>(start: data.assumingMemoryBound(to: UInt32.self), count: width * height)
                let whiteColor = UIColor.white.cgColor

                for i in buffer.indices {
                    let color = buffer[i]

                    // Estrai i componenti del colore
                    let red = CGFloat((color >> 16) & 0xFF) / 255.0
                    let green = CGFloat((color >> 8) & 0xFF) / 255.0
                    let blue = CGFloat(color & 0xFF) / 255.0

                    // Verifica se il colore è bianco
                    if red == 1.0 && green == 1.0 && blue == 1.0 {
                        buffer[i] = 0 // Imposta il colore su trasparente
                    }
                }

                if let cgImageWithTransparency = context.makeImage() {
                    let imageWithTransparency = UIImage(cgImage: cgImageWithTransparency)
                    return imageWithTransparency
                }
            }

            return nil
    }
    
    
    func createImageWithColor(color: UIColor, size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.setStrokeColor(borderColor.cgColor) // Colore del bordo
        context?.setLineWidth(borderWidth) // Spessore del bordo

        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0), size: size), cornerRadius: cornerRadius)
        path.fill()
        path.stroke() // Disegna il bordo

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Errore durante il download dell'immagine: \(error.localizedDescription)")
                DispatchQueue.main.async(execute: {
                    self.alertStandard(title: "NETWORK ERROR", text: "Check Internet Connection")
                })
                
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    
}
