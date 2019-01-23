//
//  HttpManager.swift
//  GetWeather
//
//  Created by 赵宇鹏 on 2019/1/21.
//  Copyright © 2019年 赵宇鹏. All rights reserved.
//

import UIKit
import Alamofire

class HttpManager: NSObject {

    class func requestWeather(dateStr:String?, success:@escaping ((_ response:Any) -> Void), error:((_ error:Error?) -> Void)? = nil) -> () {
        guard let dateStr = dateStr else {
            return
        }
        print(dateStr)
        Alamofire.request(weatherURL,
                          method: .get,
                          parameters:["date_time":dateStr],
                          encoding: URLEncoding.default
            ).responseJSON { (response) in
                if response.error != nil {
                    guard let error = error else { return }
                    error(response.error)
                    return
                }
                success(response.result.value)
        }
    }
}
