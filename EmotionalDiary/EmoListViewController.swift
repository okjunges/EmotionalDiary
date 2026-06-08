//
//  EmoListViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class EmoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var records: [EmotionRecord] = []
    var selectedDate: Date?
    
    private var selectedRecord: EmotionRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TextColor")!
        ]
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        
        tableView.rowHeight = 120
        tableView.estimatedRowHeight = 120
        
        if let selectedDate = selectedDate {
            navigationItem.title = selectedDate.toKoreanTitleWithYearString()
        }

        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let selectedDate = selectedDate else { return }

        FirestoreService.shared.fetchEmotionRecords(recordDate: selectedDate.toRecordDateString()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self?.records = records
                    self?.updateUI()

                case .failure(let error):
                    print("목록 새로고침 실패:", error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        let isEmpty = records.isEmpty

        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        if !isEmpty {
            tableView.reloadData()
        }
    }

    // ------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EmotionRecordCell",
            for: indexPath
        ) as! EmotionRecordCell

        let record = records[indexPath.row]
        cell.configure(record: record)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedRecord = records[indexPath.row]
        performSegue(withIdentifier: "showEmotionDetail", sender: self)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmotionDetail" {
            guard let detailVC = segue.destination as? EmoDetailViewController else {
                return
            }

            detailVC.record = selectedRecord
            detailVC.selectedDate = selectedDate
        }
    }
}
