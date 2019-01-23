//
//  WeatherM.swift
//  GetWeather
//
//  Created by 赵宇鹏 on 2019/1/21.
//  Copyright © 2019年 赵宇鹏. All rights reserved.
//

import UIKit

open class WeatherM: NSObject {

    @objc var area: String = ""
    
    @objc var forecast: String = ""
    
    @objc var latitude: Double = 0
    
    @objc var longitude: Double = 0
    
    convenience init(jsonData:Any) {
        self.init()
        
        area = JSON(jsonData)["area"].string ?? ""
        
        latitude = JSON(jsonData)["latitude"].double ?? 0
        
        longitude = JSON(jsonData)["longitude"].double ?? 0
        
        forecast = JSON(jsonData)["forecast"].string ?? ""
    }
    
    class func updateLocation(json:Any?) {
        guard let json = json else { return }
        let model: WeatherM? = J_Select(WeatherM.self).Where("area = '\(JSON(json)["name"].string ?? "")'").list().first
        
        guard let dbModel = model else { return }
        
        if dbModel.latitude == 0 || dbModel.longitude == 0 {
            dbModel.latitude = JSON(json)["label_location"]["latitude"].double ?? 0
            dbModel.longitude = JSON(json)["label_location"]["longitude"].double ?? 0
            dbModel.jr_saveOrUpdateOnly()
        }
    }
    
    class func updateForecast(json:Any?) {
        guard let json = json else { return }
        
        let model = WeatherM(jsonData: json)
        
        let dbModel: WeatherM? = J_Select(WeatherM.self).Where("area = '\(model.area)'").list().first
        
        if dbModel == nil {
            model.jr_save()
        }else {
            dbModel?.forecast = model.forecast
            dbModel?.jr_saveOrUpdateOnly()
        }
    }
    
}
