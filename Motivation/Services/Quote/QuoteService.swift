//
//  QuoteService.swift
//  Motivation
//
//  Created by Maxime Maheo on 23/02/2022.
//

import Foundation

protocol QuoteServiceProtocol: AnyObject {
    
    // MARK: - Methods
    
    func triggerNotificationsIfNeeded(nbDays: Int) async
}

final class QuoteService: QuoteServiceProtocol {
    
    // MARK: - Properties
    
    private var quotes: [Quote] = []
    
    private let calendar: Calendar
    private let databaseService: DatabaseServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(calendar: Calendar = Calendar.current,
         databaseService: DatabaseServiceProtocol,
         notificationService: NotificationServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.databaseService = databaseService
        self.notificationService = notificationService
        self.preferenceService = preferenceService
        self.calendar = calendar
    }

    // MARK: - Methods
    
    func triggerNotificationsIfNeeded(nbDays: Int) async {
        var notificationStatus = await notificationService.notificationStatus()
        
        if notificationStatus == .notDetermined {
            await notificationService.requestAuthorization()
            
            notificationStatus = await notificationService.notificationStatus()
        }
        
        guard notificationStatus != .denied else { return }
        
        
        let nbNotifPerDay = preferenceService.getNbTimesNotif()
        let startAt = preferenceService.getStartAtTime().timeIntervalSince1970
        let endAt = preferenceService.getEndAtTime().timeIntervalSince1970
        
        notificationService.removeAllPendingNotifications(type: .quote)
        
        refreshQuotes()
        
        (0...nbDays)
            .compactMap { index -> Date? in
                var dayComponent = DateComponents()
                dayComponent.day = index
                
                return calendar.date(byAdding: dayComponent, to: Date(timeIntervalSince1970: startAt))
            }
            .forEach { date in
                triggerNotifications(date: date,
                                     nbNotifPerDay: nbNotifPerDay,
                                     offset: (endAt - startAt) / Double(nbNotifPerDay))
            }
    }
    
    // MARK: - Private methods
    
    private func triggerNotifications(date: Date,
                                      nbNotifPerDay: Int,
                                      offset: Double) {
        (0...nbNotifPerDay)
            .forEach { index in
                let quote = quotes.removeFirst()
                let triggerTime = date + Double(index) * offset
                
                notificationService.triggerNotification(type: .quote,
                                                        datetime: triggerTime.timeIntervalSince1970,
                                                        title: nil,
                                                        subtitle: nil,
                                                        body: quote.content)
            }
    }
    
    private func refreshQuotes() {
        if let quotes = try? databaseService.getQuotes(language: RMQuote.RMLanguage.user,
                                                       category: preferenceService.getSelectedCategory()) {
            self.quotes = quotes
        } else {
            quotes = []
        }
    }
}
