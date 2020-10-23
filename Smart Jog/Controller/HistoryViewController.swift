//
//  HistoryViewController.swift
//  Smart Jog
//
//  Created by Beena on 23/10/20.
//  Copyright © 2020 Christy_Beena. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    let HistoryVM = JoggingHistoryViewModel()
    var histories:[JoggingHistory]=[]{
        didSet{
            self.historyListView.reloadData()
        }
    }

    @IBOutlet weak var historyListView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryVM.joggingHistoryDelegate = self
        loadHistories()

        historyListView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    
    //MARK:- Data manipulation methods

    
    func loadHistories(){
        
        HistoryVM.loadHistories()

         
    }


}
extension HistoryViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let history = histories[indexPath.row]
        if let historyCell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell{
            historyCell.avarageSpeedLabel.text = history.avarageSpeed ?? ""
            if let date = history.date{
                let delimiter = " "
                let newstr = date
                var dateFormatted = newstr.components(separatedBy: delimiter)
                historyCell.dateLabel.text = dateFormatted.first ?? ""
            }
            
            historyCell.locationLabel.text = history.startPoint ?? ""
            historyCell.distanceCoveredLabel.text = history.totalDistance ?? ""


            
            
        cell = historyCell
        }
        return cell
    }
    
    
}

extension HistoryViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Do you want to delete this item", message: "", preferredStyle: .alert)
                          
                           let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.HistoryVM.deleteHistory(at: indexPath.row)
                           })
                           alert.addAction(ok)
                      let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                           })
                           alert.addAction(cancel)
                           DispatchQueue.main.async(execute: {
                              self.present(alert, animated: true)
                      })
        
    }
}
extension HistoryViewController:JoggingHistoryVMProtocol{
    func fetchedList(joggingHistories: [JoggingHistory]) {
        self.histories = joggingHistories
    }
    
    
}
