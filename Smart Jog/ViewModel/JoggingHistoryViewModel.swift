//
//  JoggingHistoryViewModel.swift
//  Smart Jog
//
//  Created by Beena on 23/10/20.
//  Copyright © 2020 Christy_Beena. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol JoggingHistoryVMProtocol {
    func fetchedList(joggingHistories : [JoggingHistory])
}

class JoggingHistoryViewModel {
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var joggingHistoryDelegate:JoggingHistoryVMProtocol?

    var joggingHistories : [JoggingHistory] = []{
        didSet{
            joggingHistoryDelegate?.fetchedList(joggingHistories : joggingHistories)
        }
    }
    
    func saveHistory(){
        do{
            try context?.save()
            print("Successsfully saved")
        }catch let error{
            print("Error in saving data\(error.localizedDescription)")
        }
    }
    
    //MARK:- Data loading methods
    
    func loadHistories(){
        let loadHistoryrequest : NSFetchRequest<JoggingHistory> = JoggingHistory.fetchRequest()
        do{
            joggingHistories = try (context?.fetch(loadHistoryrequest) ?? [])
            
        }catch{
            print("error in fetching data \(error)")
        }
    }
    func deleteHistory(at index:Int){
        context?.delete(joggingHistories[index])
        joggingHistories.remove(at: index)
        loadHistories()
    }
    

    

    
}
