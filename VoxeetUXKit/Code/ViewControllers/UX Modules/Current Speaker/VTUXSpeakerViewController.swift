//
//  VTUXSpeakerViewController.swift
//  VoxeetUXKit
//
//  Created by Corentin Larroque on 13/06/2019.
//  Copyright © 2019 Voxeet. All rights reserved.
//

import VoxeetSDK
import SDWebImage

@objc public class VTUXSpeakerViewController: UIViewController {
    @IBOutlet weak private var avatar: UIRoundImageView!
    @IBOutlet weak private var name: UILabel!
    
    private var speaker: VTParticipant?
    
    private let voiceLevelTimeInterval: TimeInterval = 0.1
    private var voiceLevelTimer: Timer?
    
    private let inactiveAlpha: CGFloat = 0.6
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Speaker configuration.
        let speakerConfiguration = VoxeetUXKit.shared.conferenceController?.configuration.speaker
        avatar.layer.borderColor = (speakerConfiguration?.speakingColor ?? .clear).cgColor
        
        // Init voice level timer.
        voiceLevelTimer = Timer(timeInterval: voiceLevelTimeInterval, target: self, selector: #selector(refreshVoiceLevel), userInfo: nil, repeats: true)
        RunLoop.current.add(voiceLevelTimer!, forMode: .common)
    }
    
    @objc override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop voice level timer.
        voiceLevelTimer?.invalidate()
    }
    
    @objc public func updateSpeaker(participant: VTParticipant) {
        speaker = participant
        
        // Update avatar and name.
        let avatarURL = participant.info.avatarURL ?? ""
        let imageURLStr = avatarURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let placeholderImage = UIImage(named: "UserPlaceholder", in: Bundle(for: type(of: self)), compatibleWith: nil)
        avatar.sd_setImage(with: URL(string: imageURLStr), placeholderImage: placeholderImage)
        name.text = participant.info.name
        name.alpha = inactiveAlpha
        
        // Refresh new voice level.
        refreshVoiceLevel()
    }
    
    @objc private func refreshVoiceLevel() {
        DispatchQueue.main.async {
            if let speaker = self.speaker {
                let audioLevel = VoxeetSDK.shared.conference.audioLevel(participant: speaker)
                
                if audioLevel >= 0.05 && self.name.alpha != 1 {
                    self.avatar.layer.borderWidth = self.avatar.frame.width * (3/100) /* 3% */
                    self.name.alpha = 1
                } else if audioLevel < 0.05 && self.name.alpha == 1 {
                    self.avatar.layer.borderWidth = 0
                    self.name.alpha = self.inactiveAlpha
                }
            }
        }
    }
}
