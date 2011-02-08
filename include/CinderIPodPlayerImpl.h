#pragma once

#include "cinder/Function.h"
#include "CinderIPod.h"

#import <MediaPlayer/MediaPlayer.h>

namespace cinder { namespace ipod {
    class Player;
} }

@interface CinderIPodPlayerImpl : NSObject {
@public
    MPMusicPlayerController *m_controller;
    MPMediaItem             *m_playing_item;

    cinder::ipod::Player    *m_player;

    cinder::CallbackMgr<bool(cinder::ipod::Player*)> m_cb_state_change;
    cinder::CallbackMgr<bool(cinder::ipod::Player*)> m_cb_track_change;
}

-(id)init:(cinder::ipod::Player*)player;
-(void)onStateChanged:(NSNotification *)notification;
-(void)onTrackChanged:(NSNotification *)notification;

@end
