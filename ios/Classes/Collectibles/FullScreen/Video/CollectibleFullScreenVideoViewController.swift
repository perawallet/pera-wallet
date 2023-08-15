import Foundation
import UIKit
import MacaroonUIKit
import AVFoundation

final class CollectibleFullScreenVideoViewController:
    FullScreenContentViewController {
    private(set) lazy var videoPlayerView = VideoPlayerView()
    
    private var player: AVPlayer {
        return draft.player
    }
    
    private let draft: CollectibleFullScreenVideoDraft
    
    init(
        draft: CollectibleFullScreenVideoDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        super.init(configuration: configuration)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        addVideo()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        player.play()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        player.pause()
    }
   
    override func bindData() {
        super.bindData()

        videoPlayerView.player = player
    }
}

extension CollectibleFullScreenVideoViewController {
    private func addVideo() {
        videoPlayerView.clipsToBounds = true
        
        contentView.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints {
            $0.edges == 0
        }
    }
}
