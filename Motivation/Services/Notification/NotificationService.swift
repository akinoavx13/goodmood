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
    func removeAllPendingNotifications(type: NotificationService.NotificationType)
    @discardableResult func requestAuthorization() async -> Bool
    func notificationStatus() async -> UNAuthorizationStatus
}

final class NotificationService: NotificationServiceProtocol {
    
    enum NotificationType: String {
        case quote
    }
    
    // MARK: - Properties
    
    private let notificationCenter: UNUserNotificationCenter
    
    private let trackingService: TrackingServiceProtocol
    
    // MARK: - Lifecycle
    
    init(notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current(),
         trackingService: TrackingServiceProtocol) {
        self.notificationCenter = notificationCenter
        self.trackingService = trackingService
        
        Task {
            await trackNotificationStatus()
        }
    }
    
    // MARK: - Methods
    
    func triggerNotification(type: NotificationType,
                             datetime: TimeInterval,
                             title: String?,
                             subtitle: String?,
                             body: String?) {
        let now = Date().timeIntervalSince1970
        
        guard now < datetime else { return }
        
        let content = UNMutableNotificationContent()
        
        if let title = title { content.title = title }
        if let subtitle = subtitle { content.subtitle = subtitle }
        if let body = body { content.body = body }
        
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: datetime - now, repeats: false)
        let request = UNNotificationRequest(identifier: getIdentifier(type: type), content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func removeAllPendingNotifications(type: NotificationType) {
        notificationCenter.getPendingNotificationRequests { [weak self] notificationRequests in
            guard let self = self else { return }
            
            let identifiers = notificationRequests.compactMap { notificationRequest -> String? in
                guard notificationRequest.identifier.contains(type.rawValue) else { return nil }
                
                return notificationRequest.identifier
            }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
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
        } else {
            self.trackingService.set(userProperty: .hasNotificationEnabled, value: NSNumber(value: false))
        }
    }
}
