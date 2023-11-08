//
//  LineupViewModel.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Combine
import UIKit

final class LineupViewModel {
    
    // MARK: - Publishers
    
    @Published private(set) var acts: [ActViewModel] = []
    
    // TODO: Consume error message publisher in view controller
    @Published private(set) var errorMessage: String? = nil
    
    // MARK: - Public API
    
    /// When day is set, acts is updated to contain the day's acts.
    /// `didSet` property observer enables updating day via view controller.
    var day: Int {
        didSet {
            guard allActs.count > 0 else { return }
            if day >= 0, day < allActs.count {
                acts = allActs[day]
            } else {
                acts = allActs[0]
            }
        }
    }
    
    // MARK: - Private Properties
    
    /// Contains all data from fetch request.
    private var allActs: [[ActViewModel]] = [[]]
    
    private var cancellables: Set<AnyCancellable> = []
    private let apiService: APIService
    
    // MARK: - Initialization
    
    init(apiService: APIService = JSONAPIService()) {
        self.day = 0
        self.apiService = apiService
        fetchLineup()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Helper Methods
    
    /// Default day is:
    /// - the current day if current date is during festival
    /// - the first day if current date in the past or future
    func setDefaultDay() {
        // TODO: use a date provider associated with the view model to ensure logic can be unit tested
        let currentDate = Date()
        guard let festivalStartDate = allActs.first?.first?.startDate,
              let festivalEndDate = allActs.last?.last?.endDate
        else {
            return
        }
        
        let calendar = Calendar.current
        
        if currentDate >= festivalStartDate && currentDate <= festivalEndDate {
            for i in 0..<allActs.count {
                let firstAct = allActs[i][0]
                let firstActDate = firstAct.startDate
                if calendar.isDate(currentDate, inSameDayAs: firstActDate) {
                    // If current day matches the day of the first act, set day to i
                    day = i
                    return
                }
            }
        } else {
            day = 0
        }
    }
    
    private func fetchLineup() {
        apiService.fetchLineup()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error", error)
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Success")
                }
            }, receiveValue: { [weak self] allDays in
                guard let self = self else { return }
                self.allActs = []
                for day in allDays {
                    let acts = day.compactMap(ActViewModel.init)
                    self.allActs.append(acts)
                }
                self.acts = self.allActs[self.day]
                self.setDefaultDay()
            })
            .store(in: &cancellables)
    }
    
}
