//
//  VKLoginViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 8/12/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit
import WebKit

//Класс для отображения экрана входа в веб формате
class VKLoginViewController : UIViewController {
    //Название перехода для входа
    let loginSegueName : String = "LoginSegueWebView"
    //Веб форма
    @IBOutlet var webView: WKWebView! {
        didSet{
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Вызовем метод закгрузки страницы
        loadLoginPage()
        
    }
    //Метод загрузки страницы входа
    func loadLoginPage(){
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7565388"),
            URLQueryItem(name: "scope", value: "262150"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.92")
        ]
        
        let request = URLRequest(url: components.url!)
        webView.load(request)
    }
}

extension VKLoginViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url,
            url.path == "/blank.html",
            let fragment = url.fragment else { decisionHandler(.allow); return }
        
        let params = getURLParams(URLfragment: fragment)
        
        guard let token = params["access_token"],
            let userIDString = params["user_id"],
            let userIDInt = Int(userIDString) else {
                decisionHandler(.allow)
                return
        }
        
        Session.instance.token = token
        Session.instance.userID = userIDInt
        //Если вход был выполнем вызовем переход
        performSegue(withIdentifier: loginSegueName, sender: self)
        
        decisionHandler(.cancel)
    }
    
    //Метод получения параметров URL в виде словаря
    func getURLParams(URLfragment : String?) -> [String:String]{
       return URLfragment!
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
    }
}
