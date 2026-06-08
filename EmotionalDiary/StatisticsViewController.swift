//
//  StatisticsViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class StatisticsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var monthPickerView: UIPickerView!

    @IBOutlet weak var recordedDaysCardView: UIView!
    @IBOutlet weak var totalRecordsCardView: UIView!
    @IBOutlet weak var mainEmotionCardView: UIView!

    @IBOutlet weak var recordedDaysLabel: UILabel!
    @IBOutlet weak var totalRecordsLabel: UILabel!
    @IBOutlet weak var mainEmotionLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    private var selectedMonth: Int = Calendar.current.component(.month, from: Date())

    private let years: [Int] = Array(2020...Calendar.current.component(.year, from: Date()))
    private let months: [Int] = Array(1...12)

    private var stats: [EmotionStat] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPickerView()
        setupTableView()

        updatePickerSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchMonthlyRecords()
    }

    private func setupUI() {
        let cardViews = [
            recordedDaysCardView,
            totalRecordsCardView,
            mainEmotionCardView
        ]

        cardViews.forEach { view in
            view?.layer.cornerRadius = 16
            view?.clipsToBounds = true
            view?.layer.borderWidth = 1
            view?.layer.borderColor =
                UIColor(named: "LightTextColor")?.cgColor
                ?? UIColor.lightGray.cgColor
        }
    }

    private func setupPickerView() {
        monthPickerView.dataSource = self
        monthPickerView.delegate = self
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
    }

    @IBAction func previousMonthTapped(_ sender: UIButton) {
        moveMonth(by: -1)
    }

    @IBAction func nextMonthTapped(_ sender: UIButton) {
        moveMonth(by: 1)
    }

    private func moveMonth(by value: Int) {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1

        guard let currentDate = Calendar.current.date(from: components),
              let movedDate = Calendar.current.date(
                byAdding: .month,
                value: value,
                to: currentDate
              )
        else {
            return
        }

        selectedYear = Calendar.current.component(.year, from: movedDate)
        selectedMonth = Calendar.current.component(.month, from: movedDate)

        updatePickerSelection()
        fetchMonthlyRecords()
    }

    private func updatePickerSelection() {
        if let yearIndex = years.firstIndex(of: selectedYear) {
            monthPickerView.selectRow(yearIndex, inComponent: 0, animated: true)
        }

        monthPickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: true)
    }

    private func currentYearMonthString() -> String {
        return String(format: "%04d-%02d", selectedYear, selectedMonth)
    }

    private func fetchMonthlyRecords() {
        let yearMonth = currentYearMonthString()

        FirestoreService.shared.fetchMonthlyEmotionRecords(yearMonth: yearMonth) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self?.applyMonthlyRecords(records)

                case .failure(let error):
                    print("월별 감정 기록 조회 실패:", error.localizedDescription)
                    self?.applyMonthlyRecords([])
                }
            }
        }
    }

    private func applyMonthlyRecords(_ records: [EmotionRecord]) {
        let totalCount = records.count
        let recordedDays = Set(records.map { $0.recordDate }).count

        recordedDaysLabel.text = "\(recordedDays)일"
        totalRecordsLabel.text = "\(totalCount)개"

        let emotionCounts = Dictionary(grouping: records, by: { $0.emotion })
            .mapValues { $0.count }
        
        var latestEmotionOrder: [Emotion: Int] = [:]
        
        for (index, record) in records.enumerated() {
            latestEmotionOrder[record.emotion] = index
        }

        stats = Emotion.allCases.map { emotion in
            let count = emotionCounts[emotion] ?? 0
            let percent = totalCount == 0 ? 0.0 : Double(count) / Double(totalCount)

            return EmotionStat(
                emotion: emotion,
                count: count,
                percent: percent
            )
        }
        .sorted {
            if $0.count == $1.count {
                let leftLatestIndex = latestEmotionOrder[$0.emotion] ?? -1
                let rightLatestIndex = latestEmotionOrder[$1.emotion] ?? -1
                return leftLatestIndex > rightLatestIndex
            }
            return $0.count > $1.count
        }
        
        mainEmotionLabel.text = totalCount == 0 
            ? "-"
            : (stats.first?.emotion.title ?? "-")
        
        tableView.reloadData()
    }
    
    // ------------------------------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : months.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])년"
        } else {
            return "\(months[row])월"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYear = years[row]
        } else {
            selectedMonth = months[row]
        }

        fetchMonthlyRecords()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EmotionStatCell",
            for: indexPath
        ) as! EmotionStatCell

        cell.configure(stat: stats[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
