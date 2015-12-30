//
//  NewsFeeder.swift
//  FrameMe
//
//  Created by Suraj Pathak on 30/12/15.
//  Copyright © 2015 Suraj Pathak. All rights reserved.
//

import Foundation

struct EspnNews {
    var title: String = ""
    var story: String = ""
    var imageUrlString: String = ""
}

struct NewsFeeder {
    static func loadHeadlines() -> [EspnNews] {
        guard let newsJsonData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("espnNews_sample", ofType: "json")!) else {
            return []
        }
        var newsArray = [EspnNews]()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(newsJsonData, options: .AllowFragments)
            
            if let headlines = json["headlines"] as? [[String: AnyObject]] {
                for headline in headlines {
                    var espnNews = EspnNews()
                    if let title = headline["headline"] as? String {
                        espnNews.title = title
                    }
                    if let story = headline["story"] as? String {
                        espnNews.story = story
                    }
                    if let images = headline["images"] as? [AnyObject] {
                        let firstImage = images[0]
                        if let url = firstImage["url"] as? String {
                            espnNews.imageUrlString = url
                        }
                    }
                    newsArray.append(espnNews)
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
        newsArray.appendContentsOf(newsArray)
        newsArray.appendContentsOf(newsArray)
        return newsArray
    }
}
