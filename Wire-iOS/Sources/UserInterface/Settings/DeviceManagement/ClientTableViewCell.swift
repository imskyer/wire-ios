//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//


import UIKit
import Cartography
import CoreLocation
import Contacts

class ClientTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel(frame: CGRect.zero)
    let labelLabel = UILabel(frame: CGRect.zero)
    let activationLabel = UILabel(frame: CGRect.zero)
    let fingerprintLabel = UILabel(frame: CGRect.zero)
    let verifiedLabel = UILabel(frame: CGRect.zero)
    
    var showVerified: Bool = false {
        didSet {
            self.updateVerifiedLabel()
        }
    }
    
    var showLabel: Bool = false {
        didSet {
            self.updateLabel()
        }
    }
    
    var fingerprintLabelFont: UIFont? {
        didSet {
            self.updateFingerprint()
        }
    }
    var fingerprintLabelBoldFont: UIFont? {
        didSet {
            self.updateFingerprint()
        }
    }
    var fingerprintTextColor: UIColor? {
        didSet {
            self.updateFingerprint()
        }
    }
    
    var userClient: UserClient? {
        didSet {
            guard let userClient = self.userClient else { return }
            if let userClientModel = userClient.model {
                nameLabel.text = userClientModel
            }
            
            self.updateLabel()
            
            if let activationDate = userClient.activationDate, userClient.activationLocationLatitude != 0 && userClient.activationLocationLongitude != 0 {
                
                let localClient = self.userClient
                CLGeocoder().reverseGeocodeLocation(userClient.activationLocation, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) -> Void in
                    
                    if let placemark = placemarks?.first,
                        let addressCountry = placemark.addressDictionary?[CNPostalAddressCountryKey] as? String,
                        let addressCity = placemark.addressDictionary?[CNPostalAddressCityKey],
                        localClient == self.userClient &&
                            error == nil {
                        
                        self.activationLabel.text = "\("registration.devices.activated_in".localized) \(addressCity), \(addressCountry.uppercased()) — \(String(describing: activationDate.formattedDate))"
                    }
                })
                
                self.activationLabel.text = activationDate.formattedDate
            }
            else if let activationDate = userClient.activationDate {
                self.activationLabel.text = activationDate.formattedDate
            }
            else {
                self.activationLabel.text = ""
            }
            
            self.updateFingerprint()
            self.updateVerifiedLabel()
        }
    }
    
    var wr_editable: Bool

    var variant: ColorSchemeVariant? {
        didSet {
            switch variant {
            case .dark?, .none:
                self.verifiedLabel.textColor = UIColor(white: 1, alpha: 0.4)
                fingerprintTextColor = .white
                nameLabel.textColor = .white
                labelLabel.textColor = .white
                activationLabel.textColor = .white
            case .light?:
                let textColor = UIColor(scheme: .textForeground, variant: .light)
                self.verifiedLabel.textColor = textColor
                fingerprintTextColor = textColor
                nameLabel.textColor = textColor
                labelLabel.textColor = textColor
                activationLabel.textColor = textColor
            }
        }
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.wr_editable = true
        
        nameLabel.accessibilityIdentifier = "device name"
        labelLabel.accessibilityIdentifier = "device label"
        activationLabel.accessibilityIdentifier = "device activation date"
        fingerprintLabel.accessibilityIdentifier = "device fingerprint"
        verifiedLabel.accessibilityIdentifier = "device verification status"
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [self.nameLabel, self.labelLabel, self.activationLabel, self.fingerprintLabel, self.verifiedLabel].forEach(self.contentView.addSubview)
        
        constrain(self.contentView, self.nameLabel, self.labelLabel) { contentView, nameLabel, labelLabel in
            nameLabel.top == contentView.top + 16
            nameLabel.left == contentView.left + 16
            nameLabel.right <= contentView.right - 16
            
            labelLabel.top == nameLabel.bottom + 2
            labelLabel.left == contentView.left + 16
            labelLabel.right <= contentView.right - 16
        }
        
        constrain(self.contentView, self.labelLabel, self.activationLabel, self.fingerprintLabel, self.verifiedLabel) { contentView, labelLabel, activationLabel, fingerprintLabel, verifiedLabel in
            
            fingerprintLabel.top == labelLabel.bottom + 4
            fingerprintLabel.left == contentView.left + 16
            fingerprintLabel.right <= contentView.right - 16
            fingerprintLabel.height == 16
            
            activationLabel.top == fingerprintLabel.bottom + 8
            activationLabel.left == contentView.left + 16
            activationLabel.right <= contentView.right - 16
            
            verifiedLabel.top == activationLabel.bottom + 4
            verifiedLabel.left == contentView.left + 16
            verifiedLabel.right <= contentView.right - 16
            verifiedLabel.bottom == contentView.bottom - 16
        }
        
        self.backgroundColor = UIColor.clear
        self.backgroundView = UIView()
        self.selectedBackgroundView = UIView()

        setupStyle()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if self.wr_editable {
            super.setEditing(editing, animated: animated)
        }
    }

    func setupStyle() {
        nameLabel.font = .normalSemiboldFont
        labelLabel.font = .smallSemiboldFont
        activationLabel.font = .smallLightFont
        verifiedLabel.font = .smallFont
        fingerprintLabelFont = .smallLightFont
        fingerprintLabelBoldFont = .smallSemiboldFont
    }

    func updateVerifiedLabel() {
        if let userClient = self.userClient,
            self.showVerified {
            
            if userClient.verified {
                self.verifiedLabel.text = NSLocalizedString("device.verified", comment: "");
            }
            else {
                self.verifiedLabel.text = NSLocalizedString("device.not_verified", comment: "");
            }
        }
        else {
            self.verifiedLabel.text = ""
        }
    }
    
    func updateFingerprint() {
        if let fingerprintLabelBoldMonoFont = self.fingerprintLabelBoldFont?.monospaced(),
            let fingerprintLabelMonoFont = self.fingerprintLabelFont?.monospaced(),
            let fingerprintLabelTextColor = self.fingerprintTextColor,
            let userClient = self.userClient, userClient.remoteIdentifier != nil {
                
                self.fingerprintLabel.attributedText =  userClient.attributedRemoteIdentifier(
                    [.font: fingerprintLabelMonoFont, .foregroundColor: fingerprintLabelTextColor],
                    boldAttributes: [.font: fingerprintLabelBoldMonoFont, .foregroundColor: fingerprintLabelTextColor],
                    uppercase: true
                )
        }
    }
    
    func updateLabel() {
        if let userClientLabel = self.userClient?.label, self.showLabel {
            self.labelLabel.text = userClientLabel
        }
        else {
            self.labelLabel.text = ""
        }
    }
}
