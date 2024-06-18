//
//  Task.swift
//  myToDoList
//
//  Created by 1234 on 18.06.2024.
//

import Foundation

class Task: NSObject, NSCoding, Codable {
    
    var name: String?
    var date: String?
    var descriptionTask: String?
    var isDone: Bool?
    var image: Data?
    
    private var nameKey = "name"
    private var isDoneKey = "isDone"
    private var dateKey = "date"
    private var descriptionTaskKey = "descriptionTask"
    private var imageKey = "image"


    init(name: String, isDone: Bool = false, date: String = "", descriptionTask: String = "", image: Data?) {
        self.name = name
        self.date = date
        self.descriptionTask = descriptionTask
        self.isDone = isDone
        self.image = image
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(date, forKey: dateKey)
        aCoder.encode(descriptionTask, forKey: descriptionTaskKey)
        aCoder.encode(isDone, forKey: isDoneKey)
        aCoder.encode(image, forKey: imageKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: nameKey) as? String,
              let date = aDecoder.decodeObject(forKey: dateKey) as? String,
              let descriptionTask = aDecoder.decodeObject(forKey: descriptionTaskKey) as? String,
              let isDone = aDecoder.decodeObject(forKey: isDoneKey) as? Bool,
              let image = aDecoder.decodeObject(forKey: imageKey) as? Data

              else { return }
        
        self.name = name
        self.date = date
        self.descriptionTask = descriptionTask
        self.isDone = isDone
        self.image = image
    }
}
