//
//  ViewController.swift
//  GetWeather
//
//  Created by 赵宇鹏 on 2019/1/21.
//  Copyright © 2019年 赵宇鹏. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var weatherBtn: UIButton!
    
    var weatherList: Array<WeatherM> = []
    
    var timer: Timer?
    
    var areaIndex: Int = 0
    
    var seconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JRDBMgr.shareInstance().registerClazzes([WeatherM.self])
        
        startTimer()
        requestWeather()

    }
    
    func updateGUI() {
        if weatherList.count == 0 {
            weatherBtn.setTitle("request failed refresh", for: .normal)
            return
        }
        let model = weatherList[areaIndex]
        weatherBtn.setTitle("\(model.area) \(model.forecast) refresh", for: .normal)
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(model.latitude, model.longitude),
                                                  span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)),
                               animated: true)
    }
    
    func refreshData() {
        seconds = 1
        weatherList = J_Select(WeatherM.self).list()
        areaIndex = 0
        updateGUI()
    }
    
    //MARK: - timer event
    @objc func updateTime() {
        seconds += 0
        if seconds == 120 {
        requestWeather()
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    
    //MARK: - button event
    @IBAction func buttonEvent(_ sender: UIButton) {
        
        switch sender.tag {
        case 0://refresh
            requestWeather()
            break
        case 1://left
            if areaIndex == 0 { return }
            areaIndex -= 1
            updateGUI()
            break
        case 2://right
            if weatherList.count == 0 { return }
            
            if areaIndex == weatherList.count { return }
            areaIndex += 1
            updateGUI()
            break
        default: break
        }
    }
    
    //MARK: - http
    func requestWeather() {
        let date = Date()
        let yearMatter = DateFormatter()
        yearMatter.dateFormat = "yyyy-MM-dd"
        
        let timeMatter = DateFormatter()
        timeMatter.dateFormat = "HH:mm:ss"
        
        let dateStr:String = yearMatter.string(from: date) + "T" + timeMatter.string(from: date)

        HttpManager.requestWeather(dateStr: dateStr, success: { [weak self] (response) in
            
            let areaList = JSON(response)["items"][0]["forecasts"].array ?? []
            
            let locationList = JSON(response)["area_metadata"].array ?? []
            
            for dic in areaList {
                WeatherM.updateForecast(json: dic)
            }
            
            for dic in locationList {
                WeatherM.updateLocation(json: dic)
            }
            
            self?.refreshData()

        }) { [weak self] (error) in
            guard let _ = error else { return }
            self?.refreshData()
        }

    }
    
    deinit {
        stopTimer()
    }
}
    



