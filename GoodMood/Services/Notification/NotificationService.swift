//
//  NotificationService.swift
//  Motivation
//
//  Created by Maxime Maheo on 23/02/2022.
//

import UserNotifications

protocol NotificationServiceProtocol: AnyObject {
    func triggerNotification(type: NotificationService.NotificationType,
                             datetime: TimeInterval,
                             title: String?,
                             subtitle: String?,
                             body: String?)
    func removeAllPendingNotifications(type: NotificationService.NotificationType) async
    @discardableResult func requestAuthorization() async -> Bool
    func notificationStatus() async -> UNAuthorizationStatus
}

final class NotificationService: NotificationServiceProtocol {
    
    enum NotificationType: String {
        case quote
    }
    
    // MARK: - Properties
    
    private let nbMaxNotifScheduled = 64
    private var nbNotifScheduled = 0
    
    private let notificationCenter: UNUserNotificationCenter
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current(),
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.notificationCenter = notificationCenter
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        
        Task {
            await trackNotificationStatus()
            nbNotifScheduled = await getPendingRequests().count
        }
    }
    
    // MARK: - Methods
    
    func triggerNotification(type: NotificationType,
                             datetime: TimeInterval,
                             title: String?,
                             subtitle: String?,
                             body: String?) {
        let now = Date().timeIntervalSince1970
        
        guard now < datetime && nbNotifScheduled < nbMaxNotifScheduled else { return }
        
        let content = UNMutableNotificationContent()
        
        if let title = title { content.title = title }
        if let subtitle = subtitle { content.subtitle = subtitle }
        if let body = body { content.body = body }
        
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: datetime - now, repeats: false)
        let request = UNNotificationRequest(identifier: getIdentifier(type: type), content: content, trigger: trigger)
            
        nbNotifScheduled += 1
        notificationCenter.add(request)
    }
    
    func removeAllPendingNotifications(type: NotificationType) async {
        let pendingNotificationRequests = await getPendingRequests()
        let identifiers = pendingNotificationRequests.compactMap { pendingNotificationRequest -> String? in
            guard pendingNotificationRequest.identifier.contains(type.rawValue) else { return nil }
            
            return pendingNotificationRequest.identifier
        }
        
        nbNotifScheduled -= identifiers.count
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            notificationCenter
                .requestAuthorization(options: [.alert, .sound]) { [weak self] isGranted, _ in
                    self?.trackingService.set(userProperty: .hasNotificationEnabled, value: NSNumber(value: isGranted))
                    
                    continuation.resume(returning: isGranted)
                }
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func getIdentifier(type: NotificationType, identifier: String? = nil) -> String { "\(type.rawValue)_\(identifier ?? UUID().uuidString)" }
    
    private func trackNotificationStatus() async {
        let notificationStatus = await notificationStatus()
        
        if notificationStatus != .denied,
           notificationStatus != .notDetermined {
            self.trackingService.set(userProperty: .hasNotificationEnabled, value: NSNumber(value: true))
            self.preferenceService.save(isNotificationEnabled: true)
        } else {
            self.trackingService.set(userProperty: .hasNotificationEnabled, value: NSNumber(value: false))
            self.preferenceService.save(isNotificationEnabled: false)
        }
    }
    
    private func getPendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests {
                continuation.resume(returning: $0)
            }
        }
    }
}
