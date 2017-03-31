//
//  BillDetailViewController.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/17/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit
import QuickLook
import WebKit
import Social

class LegislationDetailViewController: UIViewController, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    var legislation: Legislation!
    var dataSource: LegislationDetailDataSource!
    var legislationWebView: WKWebView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var outterView: UIView!
    @IBOutlet var billStatusView: LegislationStatusView!
    @IBOutlet var billNameLabel: UILabel!
    @IBOutlet var billChamberLabel: UILabel!
    @IBOutlet var billDescriptionLabel: UILabel!
    @IBOutlet var sponsorCollectionView: UICollectionView!
    @IBOutlet var sponsorCountLabel: UILabel!
    
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        var initialText = "\(legislation.id) "
        switch legislation.status {
        case .introduced:
            initialText += "introduced"
        case .house:
            initialText += "passed house"
        case .senate:
            initialText += "passed senate"
        case .law:
            initialText += "signed into law"
        }
        let shareSheet = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: .default) { (action) in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                composeVC.setInitialText(initialText)
                composeVC.add(self.legislation.documentURL)
                self.present(composeVC, animated: true, completion: nil)
                }
            } else {
                self.showLoginMessage(forServiceName: "Twitter")
            }
        }
        let facebookAction = UIAlertAction(title: "Share on Facebook", style: .default) { (action) in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                    composeVC.setInitialText(initialText)
                    composeVC.add(self.legislation.documentURL)
                    self.present(composeVC, animated: true, completion: nil)
                }
            } else {
                self.showLoginMessage(forServiceName: "Facebook")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        shareSheet.addAction(cancelAction)
        shareSheet.addAction(tweetAction)
        shareSheet.addAction(facebookAction)
        present(shareSheet, animated: true, completion: nil)
    }
    
    func showLoginMessage(forServiceName name: String) {
        let ac = UIAlertController(title: "Share Unavailable", message: "You mused be logged in to your \(name) account", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        ac.addAction(dismiss)
        present(ac, animated: true, completion: nil)
    }
    
    func tapOnWebView(_ sender: UITapGestureRecognizer) {
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = dataSource
        show(quickLookController, sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        billNameLabel.text = legislation.id
        billDescriptionLabel.text = legislation.description
        sponsorCountLabel.text = "Sponors (\(legislation.sponsorIDs.count))"
    }
    
    override func viewDidLoad() {
        scrollView.contentSize = outterView.bounds.size
        billStatusView.status = legislation!.status
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

