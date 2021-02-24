//
//  NotificationsPermissionView.swift
//  
//
//  Created by Oleg Dreyman on 2/24/21.
//

import UIKit

public class NotificationsPermissionView<Control: UIView>: UIView {
    
    public var permissionAsker: () -> LocalNotifications.ApplicationLevelPermissionAsker? = { nil }
    
    public var applicationLevelStrategy: LocalNotifications.PermissionStrategy.GroupLevel {
        if let permissionAsker = permissionAsker() {
            return .askPermission(.alwaysIfNotAllowed, permissionAsker)
        } else {
            return .allowAutomatically
        }
    }
    
    public var didEnable: (NotificationsPermissionView<Control>) -> Void = { _ in }
    public var didDisable: (NotificationsPermissionView<Control>) -> Void = { _ in }
    public var didDeniedBySystem: (NotificationsPermissionView<Control>) -> Void = { _ in }
    
    let setOn: () -> ()
    let setOff: () -> ()
    let setDisabled: () -> ()
    let setEnabled: () -> ()
    
    public let control: Control
    public let group: LocalNotificationsGroup
    
    public init<Adapter: NotificationsPermissionViewAdapter>(group: LocalNotificationsGroup, adapter: Adapter) where Adapter.Control == Control {
        self.group = group
        self.control = adapter.control
        
        self.setOn = adapter.setOn
        self.setOff = adapter.setOff
        self.setEnabled = adapter.setEnabled
        self.setDisabled = adapter.setDisabled
        
        super.init(frame: adapter.control.frame)
        didLoad(adapter: adapter)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didLoad<Adapter: NotificationsPermissionViewAdapter>(adapter: Adapter) where Adapter.Control == Control {
        addSubview(control)
        
        setDisabled()
        adapter.receiveTurnOnAttempted { [weak self] in
            self?.didAttemptToTurnOn()
        }
        adapter.receiveTurnOffAttempted { [weak self] in
            self?.didAttemptToTurnOff()
        }
        
        LocalNotifications.currentAuthorizationStatus(forGroup: group) { (status) in
            self.setEnabled()
            if status.isEnabled {
                self.setOn()
            } else {
                self.setOff()
            }
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(appWillBecomeActive),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc
    private func appWillBecomeActive() {
        LocalNotifications.currentAuthorizationStatus(forGroup: group) { (status) in
            self.setEnabled()
            if status.isEnabled {
                self.setOn()
            } else {
                self.setOff()
            }
        }
    }
    
    private func didAttemptToTurnOn() {
        LocalNotifications.reschedule(
            group: self.group,
            permissionStrategy: .init(
                groupLevel: applicationLevelStrategy,
                systemLevel: .askPermission
            ),
            completion: { isAllowed in
                if !isAllowed {
                    self.setOff()
                    self.checkStatusAfterCantEnable()
                } else {
                    self.didEnable(self)
                }
            }
        )
    }
    
    private func didAttemptToTurnOff() {
        LocalNotifications.disable(group: group)
        self.didDisable(self)
    }
    
    private func checkStatusAfterCantEnable() {
        LocalNotifications.currentAuthorizationStatus(forGroup: group) { (status) in
            if status == .systemDenied {
                self.didDeniedBySystem(self)
                // show "go to settings popup"
            }
        }
    }
}

extension NotificationsPermissionView where Control == UISwitch {
    public convenience init(group: LocalNotificationsGroup) {
        let uiswitch = UISwitch()
        let adapter = __UISwitchAdapter(control: uiswitch)
        self.init(group: group, adapter: adapter)
    }
}

public protocol NotificationsPermissionViewAdapter {
    associatedtype Control: UIView
    
    var control: Control { get }
    
    func receiveTurnOnAttempted(completion: @escaping () -> ())
    func receiveTurnOffAttempted(completion: @escaping () -> ())
    
    func setOn()
    func setOff()
    func setDisabled()
    func setEnabled()
}

final class __UISwitchAdapter: NSObject, NotificationsPermissionViewAdapter {
    typealias Control = UISwitch
    
    let control: UISwitch
    
    init(control: UISwitch) {
        self.control = control
    }
    
    deinit {
        print("deinit adapter")
    }
    
    var turnOn: () -> () = { }
    var turnOff: () -> () = { }
    
    func receiveTurnOnAttempted(completion: @escaping () -> ()) {
        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        turnOn = completion
    }
    
    func receiveTurnOffAttempted(completion: @escaping () -> ()) {
        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        turnOff = completion
    }
    
    func setOn() {
        control.isOn = true
    }
    
    func setOff() {
        control.isOn = false
    }
    
    func setEnabled() {
        control.isEnabled = true
    }
    
    func setDisabled() {
        control.isEnabled = false
    }
    
    @objc
    func valueChanged() {
        if control.isOn {
            turnOn()
        } else {
            turnOff()
        }
    }
}
