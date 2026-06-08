//
//  MainCelenderViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class MainCalendarViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var recordCountLabel: UILabel!
    
    @IBOutlet weak var emotionView: UIView!
    @IBOutlet weak var firstEmotionImageView: UIImageView!
    @IBOutlet weak var secondEmotionImageView: UIImageView!
    @IBOutlet weak var thirdEmotionImageView: UIImageView!
    @IBOutlet weak var fourthEmotionImageView: UIImageView!
    @IBOutlet weak var fifthEmotionImageView: UIImageView!
    @IBOutlet weak var sixthEnotionImageView: UIImageView!
    @IBOutlet weak var recordEmoBtn: UIButton!
    
    private var selectedDate = Date()
    private var selectedDateRecords: [EmotionRecord] = []
    
    private var emotionImageViews: [UIImageView] {
        return [
            firstEmotionImageView,
            secondEmotionImageView,
            thirdEmotionImageView,
            fourthEmotionImageView,
            fifthEmotionImageView,
            sixthEnotionImageView
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TextColor")!
        ]
        emotionView.layer.cornerRadius = 10
        emotionView.clipsToBounds = true
        
        datePicker.date = Date()
        selectedDate = datePicker.date
        
        changeBtnTitle(for: selectedDate)
        updateMainView(for: selectedDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        datePicker.date = Date()
        
        changeBtnTitle(for: Date())
        updateMainView(for: Date())
    }
    
    @IBAction func datePickerValueChange(_ sender: UIDatePicker) {
        updateMainView(for: sender.date)
    }
    
    private func changeBtnTitle(for date: Date) {
        let btnTitle = "오늘" + date.toMonthDateString() + " 감정 기록하기"
        var config = recordEmoBtn.configuration ?? UIButton.Configuration.filled()
        var title = AttributedString(btnTitle)
        title.font = .systemFont(ofSize: 22, weight: .bold)
        config.attributedTitle = title
        recordEmoBtn.configuration = config
    }
    
    private func updateMainView(for date: Date) {
        selectedDate = date

        navigationItem.title = date.toKoreanTitleWithYearString()

        let recordDate = date.toRecordDateString()

        FirestoreService.shared.fetchEmotionRecords(recordDate: recordDate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self?.selectedDateRecords = records
                    self?.applyEmotionRecords(records)

                case .failure(let error):
                    print("감정 기록 조회 실패:", error.localizedDescription)
                    self?.selectedDateRecords = []
                    self?.applyEmotionRecords([])
                }
            }
        }
    }

    private func applyEmotionRecords(_ records: [EmotionRecord]) {
        recordCountLabel.text = "기록된 감정 \(records.count)개"

        resetEmotionImages()

        guard !records.isEmpty else {
            return
        }

        for (index, record) in records.prefix(emotionImageViews.count).enumerated() {
            emotionImageViews[index].image = UIImage(named: record.emotion.imageName)
        }
    }

    private func resetEmotionImages() {
        for imageView in emotionImageViews {
            imageView.image = UIImage(systemName: "questionmark.circle.dashed")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmotionList" {
            guard let listVC = segue.destination as? EmoListViewController else {
                return
            }

            listVC.records = selectedDateRecords
            listVC.selectedDate = selectedDate
        }
    }
}
