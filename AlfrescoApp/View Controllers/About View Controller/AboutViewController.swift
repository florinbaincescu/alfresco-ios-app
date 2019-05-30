/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile iOS App.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var versionInfoView: UIView!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var buildDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("about.title", comment: "About Title")
        self.aboutTextView.text = NSLocalizedString("about.content", comment: "Main about text block")
        self.versionNumberLabel.text = String(format: NSLocalizedString("about.version.number", comment: "Version: %@ (%@)"),
                                              Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! CVarArg,
                                              Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! CVarArg)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = formatter.string(from: buildDate())
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: buildDate())
        
        self.buildDateLabel.text = String(format: NSLocalizedString("about.build.date.time", comment: "Build Date: %@ %@"), dateString, timeString)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.shared()?.trackScreen(withName: kAnalyticsViewAbout)
    }

// MARK: - Helpers
    
    func buildDate() -> Date {
        var bdate = Date()
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date {
            bdate = infoDate
        }
        return bdate
    }
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
