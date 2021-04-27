//
//  NotificationsPermissionView.swift
//  
//
//  Created by Oleg Dreyman on 2/24/21.
//

#if canImport(UIKit)
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
    
    public var onEnabled: (NotificationsPermissionView<Control>) -> Void = { _ in }
    public var onDisabled: (NotificationsPermissionView<Control>) -> Void = { _ in }
    public var onDeniedBySystem: (NotificationsPermissionView<Control>) -> Void = { _ in }
    
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
        control.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            control.topAnchor.constraint(equalTo: self.topAnchor),
            control.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            control.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
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
            selector: #selector(refreshState),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        refreshState()
    }
    
    @objc
    private func refreshState() {
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
                    self.onEnabled(self)
                }
            }
        )
    }
    
    private func didAttemptToTurnOff() {
        LocalNotifications.disable(group: group)
        self.onDisabled(self)
    }
    
    private func checkStatusAfterCantEnable() {
        LocalNotifications.currentAuthorizationStatus(forGroup: group) { (status) in
            if status == .systemDenied {
                self.onDeniedBySystem(self)
                // show "go to settings popup"
            }
        }
    }
}

public typealias NotificationsPermissionSwitch = NotificationsPermissionView<UISwitch>

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
#endif
