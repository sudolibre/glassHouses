//
//  BillDetailViewController.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/17/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit
import QuickLook
import WebKit

class LegislationDetailViewController: UIViewController, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    var legislation: Legislation!
    var dataSource: LegislationDetailDataSource!
    var legislationWebView: WKWebView!

    //var dataSource: SponsorCollectionDataSource
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var outterView: UIView!
    @IBOutlet var billStatusView: LegislationStatusView!
    @IBOutlet var billNameLabel: UILabel!
    @IBOutlet var billChamberLabel: UILabel!
    @IBOutlet var billDescriptionLabel: UILabel!
    @IBOutlet var sponsorCollectionView: UICollectionView!
    @IBOutlet var sponsorCountLabel: UILabel!
    
    func tapOnWebView(_ sender: UITapGestureRecognizer) {
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = dataSource
        show(quickLookController, sender: nil)
    }
    
    override func viewDidLoad() {
        scrollView.contentSize = outterView.bounds.size
        //billStatusView.status = legislation.status
        billStatusView.status = .senate
        
        
        //DELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETE
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "legislationJSON", ofType: nil) else {
            fatalError("articleJSON not found")
        }
        let url = URL(fileURLWithPath: pathString)
        let jsonData = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let optionalResult = Legislation(json: json)
        legislation = optionalResult!
        dataSource = LegislationDetailDataSource(imageStore: ImageStore(), legislation: legislation)
        //DELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETEDELEEEEEEEEEETE
        
        sponsorCollectionView.dataSource = dataSource
        
        for id in legislation.sponsorIDs {
            OpenStatesAPI.fetchLegislatorByID(id: id) { (legislator) in
                self.dataSource.addLegislator(legislator)
                self.sponsorCollectionView.reloadData()
            }
        }
        legislationWebView = {
            let webView = WKWebView(frame: .zero)
            self.outterView.addSubview(webView)
            webView.backgroundColor = UIColor.cyan
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.topAnchor.constraint(equalTo: sponsorCollectionView.bottomAnchor, constant: 10).isActive = true
            webView.widthAnchor.constraint(equalTo: outterView.widthAnchor).isActive = true
            webView.heightAnchor.constraint(equalToConstant: 500).isActive = true
            webView.centerXAnchor.constraint(equalTo: outterView.centerXAnchor).isActive = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnWebView(_:)))
            tapRecognizer.delegate = self
            webView.addGestureRecognizer(tapRecognizer)
            return webView
        }()
        
        let session = URLSession.shared
        let cacheDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let documentName = legislation.documentURL.lastPathComponent
        session.dataTask(with: legislation.documentURL) { (data, response, error) in
            if let data = data {
                let filePath = cacheDirectory.appendingPathComponent(documentName)
                self.dataSource.addDocumentURL(filePath)
                try! data.write(to: filePath, options: .atomic)
                DispatchQueue.main.async {
                    self.legislationWebView.loadFileURL(filePath, allowingReadAccessTo: filePath)
                }
                return
            }
            if let response = response {
                print(response.debugDescription)
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
        
    }
    

    
}

class LegislationDetailDataSource: NSObject, UICollectionViewDataSource, QLPreviewControllerDataSource {
    var documentURLs: [URL] = []
    var sponsors: [Legislator] = []
    var imageStore: ImageStore
    
    subscript(index: Int) -> Legislator {
        return sponsors[index]
    }
    func addDocumentURL(_ url: URL) {
        documentURLs.append(url)
    }
    
    func addLegislator(_ legislator: Legislator) {
        sponsors.append(legislator)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return documentURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURLs[index] as NSURL
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sponsorCell", for: indexPath) as! SponserCollectionCell
        let sponsor = sponsors[indexPath.row]
        cell.legislator = sponsor
        if let avatarImage = imageStore.getImage(forKey: sponsor.photoKey) {
            cell.avatarImageView.image = avatarImage
        } else {
            imageStore.fetchRemoteImage(forURL: sponsor.photoURL, completion: { (image) in
                self.imageStore.setImage(image, forKey: sponsor.photoKey)
                DispatchQueue.main.async {
                    cell.avatarImageView.image = image
                }
            })
        }
        return cell
    }
    
    init(imageStore: ImageStore, legislation: Legislation) {
        self.imageStore = imageStore
    }
}

