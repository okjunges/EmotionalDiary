//
//  WriteEmoViewController.swift
//  EmotionalDiary
//
//  Created by 김완수 on 5/11/26.
//

import UIKit

class WriteEmoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoImg: UIImageView!
    
    enum Step: Int, CaseIterable {
        case timeSlot
        case emotion
        case situation
        case energy
        case intensity
        case socialContext
        case memo
    }

    struct Option {
        let title: String
        let imageName: String?
        let value: Any
    }

    private var currentStep: Step = .timeSlot
    private var options: [Option] = []
    private var selectedIndex: Int?

    private var recentRecords: [EmotionRecord] = []

    private var selectedEmotion: Emotion?
    private var selectedSituation: Situation?
    private var selectedEnergy: Energy?
    private var selectedIntensity: Int?
    private var selectedSocialContext: SocialContext?
    private var selectedTimeSlot: TimeSlot?
    private var memoText: String = ""
    
    private var originalViewY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalViewY = view.frame.origin.y
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TextColor")!
        ]
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")!

        questionView.layer.cornerRadius = 10
        questionView.clipsToBounds = true

        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 110)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView.collectionViewLayout = layout
        
        memoImg.isHidden = true
        memoTextView.delegate = self
        memoTextView.isHidden = true
        memoTextView.layer.cornerRadius = 10
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.text = "간단하게 기록해보세요..."
        memoTextView.textColor = .lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        setupKeyboardObservers()
        loadRecentRecords()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func loadRecentRecords() {
        FirestoreService.shared.fetchRecentEmotionRecords(limit: 10) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self?.recentRecords = records
                case .failure(let error):
                    print("최근 감정 조회 실패:", error.localizedDescription)
                    self?.recentRecords = []
                }

                self?.configureStep(.timeSlot)
            }
        }
    }

    private func configureStep(_ step: Step) {
        currentStep = step
        if step != .memo {
            selectedIndex = nil
        }

        switch step {
        case .timeSlot:
            questionLabel.text = "기록하고 싶은 감정은 어느 시간대와 가까운가요?"
            options = TimeSlot.allCases.map {
                Option(title: $0.title, imageName: nil, value: $0)
            }
            
        case .emotion:
            questionLabel.text = makeEmotionQuestion()
            options = Emotion.allCases.map {
                Option(title: "\($0.title)\n", imageName: $0.imageName, value: $0)
            }

        case .situation:
            questionLabel.text = makeSituationQuestion()
            options = (selectedEmotion?.situations ?? []).map {
                Option(title: "\n\($0.rawValue)", imageName: nil, value: $0)
            }

        case .energy:
            questionLabel.text = "오늘 에너지는 어느 정도였나요?"
            options = Energy.allCases.map {
                Option(title: "\n\($0.title)", imageName: nil, value: $0)
            }

        case .intensity:
            questionLabel.text = makeIntensityQuestion()
            options = [1, 2, 3, 4, 5].map {
                Option(title: "\n\($0)", imageName: nil, value: $0)
            }

        case .socialContext:
            questionLabel.text = "그때 누구와 함께 있었나요?"
            options = SocialContext.allCases.map {
                Option(title: "\n\($0.title)", imageName: nil, value: $0)
            }
            
        case .memo:
            questionLabel.text = "그 당시의 상황을 간단하게 기록해보세요.\n(150자 이내)"
            options = []
        }
        
        let isMemoStep = step == .memo

        collectionView.isHidden = isMemoStep
        memoTextView.isHidden = !isMemoStep
        memoImg.isHidden = !isMemoStep

        if isMemoStep {
            if memoText.isEmpty {
                memoTextView.text = "간단하게 기록해보세요..."
                memoTextView.textColor = .lightGray
            } else {
                memoTextView.text = memoText
                memoTextView.textColor = .black
            }

            memoTextView.becomeFirstResponder()
        } else {
            memoTextView.resignFirstResponder()
        }
        
        updateButtons()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }

    private func updateButtons() {
        previousButton.isEnabled = currentStep != .timeSlot
        previousButton.alpha = previousButton.isEnabled ? 1.0 : 0.4

        switch currentStep {
        case .socialContext:
            nextButton.setTitle("메모하기", for: .normal)
            let hasSelected = hasSelectionForCurrentStep()
            nextButton.isEnabled = hasSelected
            nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.4

        case .memo:
            nextButton.setTitle("저장", for: .normal)
            nextButton.isEnabled = true
            nextButton.alpha = 1.0
            
        default:
            nextButton.setTitle("다음", for: .normal)
            let hasSelected = hasSelectionForCurrentStep()
            nextButton.isEnabled = hasSelected
            nextButton.alpha = hasSelected ? 1.0 : 0.4
        }
    }
    
    private func hasSelectionForCurrentStep() -> Bool {
        switch currentStep {
        case .timeSlot:
            return selectedTimeSlot != nil
        case .emotion:
            return selectedEmotion != nil
        case .situation:
            return selectedSituation != nil
        case .energy:
            return selectedEnergy != nil
        case .intensity:
            return selectedIntensity != nil
        case .socialContext:
            return selectedSocialContext != nil
        case .memo:
            return true
        }
    }

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if currentStep == .memo {
            memoText = memoTextView.textColor == .lightGray ? "" : memoTextView.text
        }

        guard let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        configureStep(previousStep)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if currentStep == .memo {
            memoText = memoTextView.textColor == .lightGray ? "" : memoTextView.text
            saveEmotionRecord()
            return
        }

        guard hasSelectionForCurrentStep() else { return }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        configureStep(nextStep)
    }

    private func saveCurrentSelection(_ option: Option) {
        switch currentStep {
        case .timeSlot:
            let newTimeSlot = option.value as? TimeSlot
            if selectedTimeSlot != newTimeSlot {
                selectedEmotion = nil
                selectedSituation = nil
                selectedEnergy = nil
                selectedIntensity = nil
                selectedSocialContext = nil
                memoText = ""
            }
            selectedTimeSlot = newTimeSlot
            
        case .emotion:
            let newEmotion = option.value as? Emotion
            if selectedEmotion != newEmotion {
                selectedSituation = nil
                selectedEnergy = nil
                selectedIntensity = nil
                selectedSocialContext = nil
                memoText = ""
            }
            selectedEmotion = newEmotion

        case .situation:
            let newSituation = option.value as? Situation
            if selectedSituation != newSituation {
                selectedEnergy = nil
                selectedIntensity = nil
                selectedSocialContext = nil
                memoText = ""
            }
            selectedSituation = newSituation

        case .energy:
            let newEnergy = option.value as? Energy
            if selectedEnergy != newEnergy {
                selectedIntensity = nil
                selectedSocialContext = nil
                memoText = ""
            }
            selectedEnergy = newEnergy

        case .intensity:
            let newIntensity = option.value as? Int
            if selectedIntensity != newIntensity {
                selectedSocialContext = nil
                memoText = ""
            }
            selectedIntensity = newIntensity

        case .socialContext:
            let newSocialContext = option.value as? SocialContext
            if selectedSocialContext != newSocialContext {
                memoText = ""
            }
            selectedSocialContext = newSocialContext
            
        case .memo:
            break
        }
    }
    
    private func isOptionSelected(_ option: Option) -> Bool {
        switch currentStep {
        case .timeSlot:
            return (option.value as? TimeSlot) == selectedTimeSlot
            
        case .emotion:
            return (option.value as? Emotion) == selectedEmotion

        case .situation:
            return (option.value as? Situation) == selectedSituation

        case .energy:
            return (option.value as? Energy) == selectedEnergy

        case .intensity:
            return (option.value as? Int) == selectedIntensity

        case .socialContext:
            return (option.value as? SocialContext) == selectedSocialContext

        case .memo:
            return false
        }
    }

    private func saveEmotionRecord() {
        guard
            let emotion = selectedEmotion,
            let situation = selectedSituation,
            let energy = selectedEnergy,
            let intensity = selectedIntensity,
            let socialContext = selectedSocialContext,
            let timeSlot = selectedTimeSlot
        else {
            return
        }

        let today = Date()

        let record = EmotionRecord(
            id: nil,
            emotion: emotion,
            situation: situation,
            energy: energy,
            intensity: intensity,
            socialContext: socialContext,
            timeSlot: timeSlot,
            memo: memoText,
            recordDate: today.toRecordDateString(),
            yearMonth: today.toYearMonthString()
        )

        FirestoreService.shared.addEmotionRecord(record: record) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("감정 기록 저장 실패:", error.localizedDescription)
                }
            }
        }
    }

    private func makeEmotionQuestion() -> String {
        guard !recentRecords.isEmpty else {
            return "지금 기분은 어때요?"
        }

        if let selectedTimeSlot = selectedTimeSlot {
            let sameTimeSlotRecords = recentRecords.filter {
                $0.timeSlot == selectedTimeSlot
            }

            if !sameTimeSlotRecords.isEmpty,
               let mostEmotion = mostFrequentEmotion(records: sameTimeSlotRecords) {

                return "최근 \(selectedTimeSlot.saveTitle)에는 \(mostEmotion.question) 감정이 자주 보였어요.\n"
                    + makeEmotionQuestionText(for: mostEmotion)
            }
        }

        guard let mostEmotion = mostFrequentEmotion(records: recentRecords) else {
            return "지금 기분은 어때요?"
        }

        return "최근에는 \(mostEmotion.question) 감정이 자주 보였어요.\n" + makeEmotionQuestionText(for: mostEmotion)
    }
    
    private func mostFrequentEmotion(records: [EmotionRecord]) -> Emotion? {
        guard !records.isEmpty else { return nil }

        let emotionCounts = Dictionary(grouping: records, by: { $0.emotion })
            .mapValues { $0.count }

        return records.max { left, right in
            let leftCount = emotionCounts[left.emotion] ?? 0
            let rightCount = emotionCounts[right.emotion] ?? 0

            if leftCount == rightCount {
                return false
            }

            return leftCount < rightCount
        }?.emotion
    }
    
    private func makeEmotionQuestionText(for emotion: Emotion) -> String {
        switch emotion {
        case .happy:
            return "계속 행복한 일이 가득했으면 좋겠어요.\n지금 기분은 어때요?"
        case .satisfied:
            return "오늘도 만족하셨나요?\n지금 기분을 선택해주세요!"
        case .normal:
            return "무난한 감정이 자주 기록됐어요.\n지금은 어떤 기분인가요?"
        case .worried:
            return "고민은 잘 해결 됐나요?\n지금의 감정을 선택해주세요!"
        case .sad:
            return "아픈일이 빠르게 해결되길 바래요.\n지금 마음은 어떤가요?"
        case .angry:
            return "최근 화나는 일이 조금 있었던 것 같아요.\n지금 기분은 어떤가요?"
        case .stress:
            return "지금은 스트레스 받지 않길 바라요.\n지금의 감정은 어떤가요?"
        case .tired:
            return "앞으로는 활기찬 일이 많길 기도해요.\n지금 컨디션은 어떤가요?"
        case .calm:
            return "편안한 감정만큼 안정적인건 없죠\n지금 기분도 편안한가요?"
        }
    }

    private func makeSituationQuestion() -> String {
        guard let selectedEmotion = selectedEmotion else {
            return "그 감정은 어떤 상황과 가까웠나요?"
        }

        var targetRecords = recentRecords.filter {
            $0.emotion == selectedEmotion
        }

        if let selectedTimeSlot = selectedTimeSlot {
            let sameTimeAndEmotionRecords = recentRecords.filter {
                $0.timeSlot == selectedTimeSlot && $0.emotion == selectedEmotion
            }

            if !sameTimeAndEmotionRecords.isEmpty {
                targetRecords = sameTimeAndEmotionRecords
            }
        }

        let situationCounts = Dictionary(grouping: targetRecords, by: { $0.situation })
            .mapValues { $0.count }

        if let mostSituation = situationCounts.max(by: { $0.value < $1.value })?.key {
            return "최근 \(selectedEmotion.question) 감정은\n'\(mostSituation.rawValue)' 상황과 자주 연결됐어요.\n지금은 어떤 상황과 가까웠나요?"
        }

        return "지금 \(selectedEmotion.question) 감정은 어떤 상황과 가까웠나요?"
    }
    
    private func makeIntensityQuestion() -> String {
        guard let selectedEmotion = selectedEmotion else {
            return "그 감정은 얼마나 강했나요?"
        }
        
        switch selectedEmotion {
        case .happy:
            return "그 순간의 행복감은 어느 정도였나요?"
        case .satisfied:
            return "만족감은 얼마나 크게 느껴졌나요?"
        case .normal:
            return "그 감정은 어느 정도로 느껴졌나요?"
        case .worried:
            return "고민은 얼마나 크게 느껴졌나요?"
        case .sad:
            return "슬픔은 어느 정도였나요?"
        case .angry:
            return "화난 감정은 얼마나 강했나요?"
        case .stress:
            return "스트레스는 어느 정도였나요?"
        case .tired:
            return "피곤함은 얼마나 크게 느껴졌나요?"
        case .calm:
            return "편안함은 어느 정도였나요?"
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard currentStep == .memo,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let textViewFrame = memoTextView.convert(memoTextView.bounds, to: view)
        let textViewBottomY = textViewFrame.maxY

        let keyboardTopY = view.bounds.height - keyboardFrame.height
        let padding: CGFloat = 20

        if textViewBottomY > keyboardTopY - padding {
            let moveY = textViewBottomY - keyboardTopY + padding
            view.frame.origin.y = originalViewY - moveY
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = originalViewY
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EmotionOptionCell",
            for: indexPath
        ) as! EmotionOptionCell

        let option = options[indexPath.item]
        let isSelected = isOptionSelected(option)

        cell.configure(
            title: option.title,
            imageName: option.imageName,
            isSelected: isSelected
        )
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item

        let option = options[indexPath.item]
        saveCurrentSelection(option)

        updateButtons()
        collectionView.reloadData()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 150 {
            textView.text = String(textView.text.prefix(150))
        }

        memoText = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            textView.text = "간단하게 기록해보세요..."
            textView.textColor = .lightGray
        }
    }
}
