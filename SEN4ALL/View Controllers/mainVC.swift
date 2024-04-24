//
//  ViewController.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 29/09/23.
//

import UIKit
import WebKit
import FSCalendar
import CoreLocation

class mainVC: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, selectVCDelegate, selectDataVCDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var zoomInBtn: UIButton!
    @IBOutlet weak var zoomOutBtn: UIButton!
    @IBOutlet weak var localizeBtn: UIButton!
    @IBOutlet weak var layerBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var pixelLabel: UILabel!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var legendImage: UIImageView!
    @IBOutlet weak var backTable: UIView!
    @IBOutlet weak var backTableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableLocation: UITableView!
    @IBOutlet weak var drawBtn: UIButton!
    
    var webView: WKWebView!
    
    var selectedDate: Date?
    var locations = [LocationData]()
    
    let persistStorage = UserDefaults.standard
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    let locationManager = CLLocationManager()
    var draw: Bool = false
    
    let activityInstance = Indicator()
    
    
    @IBAction func zoomInAction(_ sender: UIButton) {
        callJavaScriptFunction(javaFunc: "zoomIn()")
    }
    
    @IBAction func zoomOutAction(_ sender: UIButton) {
        callJavaScriptFunction(javaFunc: "zoomOut()")
    }
    
    @IBAction func localizeAction(_ sender: UIButton) {
        self.callJavaScriptFunction(javaFunc: "setCenter(\(self.latitude?.magnitude ?? 0.0), \(self.longitude?.magnitude ?? 0.0))")
    }
    
    
    @IBAction func drawAction(_ sender: UIButton) {
        if draw {
            callJavaScriptFunction(javaFunc: "disableDraw()")
            sender.setImage(UIImage(named: "icons_draw"), for: .normal)
            sender.circleBtn()
            draw = false
        } else {
            callJavaScriptFunction(javaFunc: "enableDraw('square')")
            sender.setImage(UIImage(named: "icons_draw_sel"), for: .normal)
            sender.circleBtnOrange()
            draw = true
        }
        
    }
    
    @IBAction func nextDate(_ sender: UIButton) {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate!) {
          
         
        } else {
            let newDate = selectedDate?.addingTimeInterval(24 * 60 * 60)
            selectedDate = newDate
            updateButtonDate()
            applyLayer()
        }
        
        
    }
    
    @IBAction func prevDate(_ sender: UIButton) {
        let newDate = selectedDate?.addingTimeInterval(-24 * 60 * 60)
        selectedDate = newDate
        updateButtonDate()
        applyLayer()
    }
    
    @IBAction func layerAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let selectVC = sb.instantiateViewController(identifier: "selectVC") as! selectVC
        selectVC.delegate = self
        if UIDevice.current.userInterfaceIdiom == .phone {
            selectVC.modalPresentationStyle = .fullScreen
            selectVC.modalTransitionStyle = .coverVertical
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            selectVC.modalPresentationStyle = .pageSheet
            selectVC.modalTransitionStyle = .crossDissolve
        }
        self.present(selectVC, animated: true, completion: nil)
    }
    
    
    @IBAction func showCalendar(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let selectDataVC = sb.instantiateViewController(identifier: "selectDataVC") as! selectDataVC
        selectDataVC.modalPresentationStyle = .overCurrentContext
        selectDataVC.modalTransitionStyle = .crossDissolve
        selectDataVC.selectedDate = selectedDate
        selectDataVC.delegate = self
        self.present(selectDataVC, animated: true, completion: nil)
        
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("Access")
                manager.startUpdatingLocation()
            case .denied, .restricted:
                print("No Access")
            default:
            print("Location services are not enabled")
            
            }
    }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude

            let accuracy = locations.last?.horizontalAccuracy
            if accuracy! < 50.0 {
                locationManager.stopUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location Error: \(error.localizedDescription)")
        }

        // Assicurati di fermare l'aggiornamento della posizione quando non è più necessario
        deinit {
            locationManager.stopUpdatingLocation()
        }
    // MARK: - SearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if self.locations.count > 0 {
            self.backTable.alpha = 1
            self.tableLocation.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
            // Verifica che il testo abbia almeno 3 caratteri
            guard searchText.count >= 3 else {
                // Non fare nulla se il testo è troppo corto
                self.locations.removeAll()
                self.tableLocation.reloadData()
                self.backTable.alpha = 0
                return
            }
        var formattedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: "https://nominatim.openstreetmap.org/search?format=json&polygon=1&addressdetails=1&q=" + formattedSearchText)!)
            
            // Esegui la richiesta JSON
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // controllo problemi di network
                print("error=\(String(describing: error))")
                self.alertStandard(title: "NETWORK ERROR", text: "Check Internet Connection")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // controllo errore
                print("il codice dovrebbe essere 200, ma è \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let jsonString = String(data: data, encoding: .utf8)
            
            if let jsonData = jsonString!.data(using: .utf8) {
                do {
                    let locationDataArray = try JSONDecoder().decode([LocationData].self, from: jsonData)
                               
                                
                    DispatchQueue.main.async(execute: {
                        self.backTable.alpha = 1
                        self.locations = locationDataArray
                        self.backTableHeight.constant = CGFloat(50*self.locations.count)
                        self.tableLocation.reloadData()
                    })
                } catch {
                    print("Errore nella decodifica JSON: \(error)")
                }
            }
            //let responseString = String(data: data, encoding: .utf8)
            //print(responseString)
        }
        task.resume()
            
        }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.locations.removeAll()
        self.tableLocation.reloadData()
        self.backTable.alpha = 0
    }
    
    
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchCell
        
        cell.backgroundColor = .clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "GrayColor")
        cell.locationLabel.text = self.locations[indexPath.row].display_name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.text = self.locations[indexPath.row].display_name
        self.searchBar.endEditing(true)
        self.backTable.alpha = 0
        let latitude = self.locations[indexPath.row].lat
        let longitude = self.locations[indexPath.row].lon
        self.callJavaScriptFunction(javaFunc: "setCenter(\(latitude), \(longitude))")
    }
    
    
    // MARK: - WebKitDelegate
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Error: \(error.localizedDescription)")
        
    }
    
    func callJavaScriptFunction(javaFunc: String) {
            webView.evaluateJavaScript(javaFunc, completionHandler: nil)
        }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
            if message.name == "zoomAndPixel", let messageBody = message.body as? String {
                if let jsonData = messageBody.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    if let pixelValue = jsonObject["pixel"] as? Double {
                        let roundedPixelValue = String(format: "%.2f", pixelValue)
                        self.pixelLabel.text = String(roundedPixelValue) + " m"
                    }
                    
                    if let zoomValue = jsonObject["zoom"] as? Double {
                        let roundedZoomValue = String(format: "%.1f", zoomValue)
                        self.zoomLabel.text = roundedZoomValue
                    }
                }
            }
            if message.name == "legendUrl", let messageBody = message.body as? String {
                
                self.downloadLegendImage(imageUrlString: messageBody)
            }
        
            if message.name == "loaderAction", let messageBody = message.body as? String {
                if messageBody == "true" {
                    self.activityInstance.showIndicator(alphaBlur: 0.3, viewToAdd: self.layerBtn)
                } else if messageBody == "false" {
                    self.activityInstance.hideIndicator()
                }
            
            }
        if message.name == "downloadBBox", let messageBody = message.body as? String {
            self.activityInstance.showIndicator(alphaBlur: 0.3, viewToAdd: self.layerBtn)
            downloadPolygon(BBox: messageBody)
        }
        }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
           // This method is called when the web content process terminates unexpectedly (crash).
           // You can handle the crash and reload the specific web page here.
            
    }
    
    // MARK: - Delegate
    
    func applyLayer() {
        updateLayerBtn()
    }
    
    func applyDate(date: Date) {
        selectedDate = date
        updateButtonDate()
        applyLayer()
    }
    
    // MARK: - Helpers
    
    func updateLayerBtn() {
        let selectedDateTxt = getFormattedDate(date: selectedDate!, format: "yyyy-MM-dd")
        let previousSevenDays = selectedDate?.addingTimeInterval(-168 * 60 * 60)
        let previousSevenDaysTxt = getFormattedDate(date: previousSevenDays!, format: "yyyy-MM-dd")
        let intervalDate = previousSevenDaysTxt + "/" + selectedDateTxt
        let context = persistStorage.value(forKey: "context") as! Int
        switch context {
        case 0:
            layerBtn.setImage(UIImage(named: "icons_land_map"), for: .normal)
        case 1:
            layerBtn.setImage(UIImage(named: "icons_marine_map"), for: .normal)
        case 2:
            layerBtn.setImage(UIImage(named: "icons_atmo_map"), for: .normal)
        default:
            print("error context index")
        }
        let sat = persistStorage.value(forKey: "satellite") as! Int
        let layer = persistStorage.value(forKey: "layer") as! Int
        
        switch sat {
            
        //Sentinel 1
        case 1:
            
            switch layer {
            case 1:
                layerBtn.setTitle("Water Roughness", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('WATER-ROUGHNESS', '\(intervalDate)')")
            case 2:
                layerBtn.setTitle("Urban Area", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('URBAN-DETECTION', '\(intervalDate)')")
            case 3:
                layerBtn.setTitle("Crop Monitoring", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('ENHANCED-VISUALIZATION', '\(intervalDate)')")
            case 4:
                layerBtn.setTitle("IW-VV", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('IW_VV', '\(intervalDate)')")
            case 5:
                layerBtn.setTitle("IW-VH", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('IW_VH', '\(intervalDate)')")
            default:
                print("error layer index")
            }
            
            
        //Sentinel 2
        case 2:
            switch layer {
            case 1:
                layerBtn.setTitle("Moisture", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('MOISTURE', '\(intervalDate)')")
            case 2:
                layerBtn.setTitle("NDVI", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('3_NDVI', '\(intervalDate)')")
            default:
                print("error layer index")
            }
            
        //Sentinel 3
        case 3:
            switch layer {
            case 1:
                layerBtn.setTitle("F1 Visualized", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('F1_VISUALIZED', '\(intervalDate)')")
            case 2:
                layerBtn.setTitle("F2 Visualized", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('F2_VISUALIZED', '\(intervalDate)')")
            default:
                print("error layer index")
            }
            
        //Sentinel 5
        case 5:
            switch layer {
            case 1:
                layerBtn.setTitle("SO2", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('SO2', '\(intervalDate)')")
            case 2:
                layerBtn.setTitle("O3", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('O3', '\(intervalDate)')")
            case 3:
                layerBtn.setTitle("NO2", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('NO2', '\(intervalDate)')")
            case 4:
                layerBtn.setTitle("HCNO3", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('HCHO', '\(intervalDate)')")
            case 5:
                layerBtn.setTitle("CO", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('CO', '\(intervalDate)')")
            case 6:
                layerBtn.setTitle("CH4", for: .normal)
                callJavaScriptFunction(javaFunc: "setLayer('CH4', '\(intervalDate)')")
            default:
                print("error layer index")
            }
            
        default:
            print("error sat index")
        }
    }
    
    func updateButtonDate() {
        let selectedDateTxt = getFormattedDate(date: selectedDate!, format: "d MMM yyyy")
        dateBtn.setTitle(selectedDateTxt, for: .normal)
    }
    
    func updateUI() {
        
        backTable.alpha = 0.0
        backTable.layer.cornerRadius = 12
        tableLocation.separatorColor = .clear
        
        selectedDate = Date()
        let selectedDateTxt = getFormattedDate(date: selectedDate!, format: "d MMM yyyy")
        
        dateBtn.setTitle(selectedDateTxt, for: .normal)
        
        zoomInBtn.circleBtn()
        zoomOutBtn.circleBtn()
        localizeBtn.circleBtn()
        layerBtn.normalBtn()
        drawBtn.circleBtn()
        
        let cornerRadius: CGFloat = 12.0
        let frame = CGSize(width: self.view.frame.size.width-40, height: searchBar.frame.size.height)
        let backgroundImage = createImageWithColor(color: UIColor(named: "LightColor")!.withAlphaComponent(0.9), size: frame, cornerRadius: cornerRadius, borderWidth: 1.0, borderColor: UIColor(named: "GrayAlpha")!)
        searchBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.setImage(UIImage(named: "icons_search"), for: .search, state: .normal)
        
        
        infoView.backgroundColor = UIColor(named: "LightColor")!.withAlphaComponent(0.9)
        infoView.layer.cornerRadius = 12.0
        infoView.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        infoView.layer.borderWidth = 1
        
        dateView.backgroundColor = UIColor(named: "LightColor")!.withAlphaComponent(0.9)
        dateView.layer.cornerRadius = 12.0
        dateView.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        dateView.layer.borderWidth = 1
        
    }
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }
    
    
    func webViewInit() {
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "zoomAndPixel")
        configuration.userContentController.add(self, name: "legendUrl")
        configuration.userContentController.add(self, name: "loaderAction")
        configuration.userContentController.add(self, name: "downloadBBox")
        
        
        
        let statusBarHeight = CGFloat(60)
        //-statusBarHeight
        let webViewFrame = CGRect(x: 0, y: -statusBarHeight, width: view.bounds.width, height: view.bounds.height+statusBarHeight)
        
       
           

        webView = WKWebView(frame: webViewFrame, configuration: configuration)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
       
        

        if let htmlPath = Bundle.main.path(forResource: "map", ofType: "html", inDirectory: "assets") {
       
            var urlString = "file://\(htmlPath)?zoom=12&minZoom=9&maxZoom=14&lat=\(self.latitude?.magnitude ?? 41.9027835)&lon=\(self.longitude?.magnitude ?? 12.4963655)"
            
            if let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
               let url = URL(string: encodedURLString) {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                
            }
        }
        
       
        self.view.insertSubview(webView, at: 0)
    }
    
    
    
    func coreLocationInit() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    
    }
    
    func downloadLegendImage(imageUrlString: String) {
        if let imageUrl = URL(string: imageUrlString) {
                    downloadImage(from: imageUrl) { [weak self] image in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.async {
                            if let image = image {
                                
                                let imageWW = self.removeWhiteBackground(from: image)
                                self.legendImage.image = imageWW
                                
                                
                                self.legendImage.alpha = 1
                                
                            } else {
                                
                                print("Impossibile scaricare o creare l'immagine.")
                            }
                        }
                    }
                } else {
                    print("URL dell'immagine non valido.")
                }
    }
    
    func downloadPolygon(BBox: String) {
        let selectedDateTxt = getFormattedDate(date: selectedDate!, format: "yyyy-MM-dd")
        let previousSevenDays = selectedDate?.addingTimeInterval(-168 * 60 * 60)
        let previousSevenDaysTxt = getFormattedDate(date: previousSevenDays!, format: "yyyy-MM-dd")
        let intervalDate = previousSevenDaysTxt + "/" + selectedDateTxt
        
        let sat = persistStorage.value(forKey: "satellite") as! Int
        let layer = persistStorage.value(forKey: "layer") as! Int
        let context = persistStorage.value(forKey: "context") as! Int
        
        var satTxt = ""
        var layerTxt = ""
        var contextTxt = ""
        
       
        switch context {
        case 0:
            contextTxt = "land"
        case 1:
            contextTxt = "marine"
        case 2:
            contextTxt = "atmosphere"
        default:
            print("error context index")
        }
        
        switch sat {
            
        //Sentinel 1
        case 1:
            satTxt = "sentinel1"
            switch layer {
            case 1:
                layerTxt = "WATER-ROUGHNESS"
            case 2:
                layerTxt = "URBAN-DETECTION"
            case 3:
                layerTxt = "ENHANCED-VISUALIZATION"
            case 4:
                layerTxt = "IW_VV"
            case 5:
                layerTxt = "IW_VH"
            default:
                print("error layer index")
            }
            
            
        //Sentinel 2
        case 2:
            satTxt = "sentinel2"
            switch layer {
            case 1:
                layerTxt = "MOISTURE"
            case 2:
                layerTxt = "3_NDVI"
            default:
                print("error layer index")
            }
            
        //Sentinel 3
        case 3:
            satTxt = "sentinel3"
            switch layer {
            case 1:
                layerTxt = "F1_VISUALIZED"
            case 2:
                layerTxt = "F2_VISUALIZED"
            default:
                print("error layer index")
            }
            
        //Sentinel 5
        case 5:
            satTxt = "sentinel5"
            switch layer {
            case 1:
                layerTxt = "SO2"
            case 2:
                layerTxt = "O3"
            case 3:
                layerTxt = "NO2"
            case 4:
                layerTxt = "HCHO"
            case 5:
                layerTxt = "CO"
            case 6:
                layerTxt = "CH4"
            default:
                print("error layer index")
            }
            
        default:
            print("error sat index")
        }
        
        
        
        // L'URL del file TIFF
        let tiffURL = URL(string: "your layer provider url")!
        

        let session = URLSession.shared
                let downloadTask = session.downloadTask(with: tiffURL) { localURL, response, error in
                    if let error = error {
                        print("Errore durante il download del file: \(error)")
                        return
                    }

                    if let localURL = localURL {
                        // Ottieni un riferimento alla directory dei documenti
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        // Costruisci un nome di file per il documento scaricato
                        let destinationURL = documentsDirectory.appendingPathComponent("\(satTxt)_\(contextTxt)_\(layerTxt)_\(intervalDate.replacingOccurrences(of: "/", with: "-")).tiff")

                        do {
                            // Verifica se esiste già un file con lo stesso nome e, se sì, cambia il nome
                            if FileManager.default.fileExists(atPath: destinationURL.path) {
                                let newFileName = "downloadedFile_\(UUID().uuidString).tiff"
                                let newDestinationURL = documentsDirectory.appendingPathComponent(newFileName)
                                try FileManager.default.moveItem(at: localURL, to: newDestinationURL)
                                self.presentDocumentPicker(forURL: newDestinationURL)
                            } else {
                                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                                self.presentDocumentPicker(forURL: destinationURL)
                            }
                        } catch {
                            print("Errore durante il salvataggio del file: \(error)")
                        }
                    }
                }

                downloadTask.resume()
    }
    
    func presentDocumentPicker(forURL url: URL) {
        self.activityInstance.hideIndicator()
        DispatchQueue.main.async(execute: {
            let documentPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        })
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Gestisci il documento selezionato
            if let pickedURL = urls.first {
                print("Documento selezionato: \(pickedURL.path)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.activityInstance.hideIndicator()
            // L'utente ha annullato la scelta del documento
        }
    
    // MARK: - Overrides
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.webView.frame = CGRect(origin: .zero, size: size)
            let cornerRadius: CGFloat = 12.0
            let frame = CGSize(width: self!.view.frame.size.width-40, height: self!.searchBar.frame.size.height)
            let backgroundImage = self!.createImageWithColor(color: UIColor(named: "LightColor")!.withAlphaComponent(0.9), size: frame, cornerRadius: cornerRadius, borderWidth: 1.0, borderColor: UIColor(named: "GrayAlpha")!)
            self!.searchBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
        }, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true 
    }
    
    override func viewDidLoad() {
        
        legendImage.layer.cornerRadius = 12
        legendImage.clipsToBounds = true
        legendImage.alpha = 0
        legendImage.layer.borderColor = UIColor(named: "GrayAlpha")?.cgColor
        legendImage.layer.borderWidth = 1
        
       
        
        persistStorage.setValue(0, forKey: "context")
        persistStorage.setValue(0, forKey: "satellite")
        persistStorage.setValue(0, forKey: "layer")
        
        super.viewDidLoad()
        
        updateUI()
        
        webViewInit()
        
        coreLocationInit()
 
        
    }

}

