//
//  MoreInfoViewController.swift
//  Parking
//
//  Created by Koh Jia Rong on 22/4/18.
//  Copyright © 2018 Koh Jia Rong. All rights reserved.
//

import UIKit
import WebKit

class HDBWebViewController: UIViewController {
    
    lazy var webView : WKWebView = {
        let v = WKWebView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .bar)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.progressTintColor = .customGreen
        return v
    }()
    
    var titleText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupWebView()
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let title = title {
            navigationItem.title = title
        }
        
        progressView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setupWebView() {
        let url = URL(string: "https://www.ura.gov.sg/Corporate/Car-Parks/Short-Term-Parking")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress == 1.0 {
                progressView.isHidden = true
            }
        }
    }
}
