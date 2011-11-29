#import "CinderIPodPlayerImpl.h"

#include "CinderIPodPlayer.h"

@implementation CinderIPodPlayerImpl

- (id)init:(cinder::ipod::Player*)player
{
    self = [super init];

    m_player = player;
    m_controller = [MPMusicPlayerController iPodMusicPlayer];
    m_library = [MPMediaLibrary defaultMediaLibrary];
    
    m_suppress_events = false;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver: self
           selector: @selector (onStateChanged:)
               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
             object: m_controller];

    [nc addObserver: self
           selector: @selector (onTrackChanged:)
               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
             object: m_controller];

    [m_controller beginGeneratingPlaybackNotifications];
    
    [nc addObserver: self
           selector: @selector (onLibraryChanged:)
               name: MPMediaLibraryDidChangeNotification
             object: m_library];

    [m_library beginGeneratingLibraryChangeNotifications];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    // TODO: end generating notifications on m_controller? on library?
    [m_controller dealloc]; // TODO: is this necessary if we aren't the ones allocing iPodMusicPlayer?
}

- (void)onStateChanged:(NSNotification *)notification
{
    static NSString * const stateKey = @"MPMusicPlayerControllerPlaybackStateKey";
    NSNumber *number = [[notification userInfo] objectForKey:stateKey];
    MPMusicPlaybackState state = [number integerValue];
    // state is the new state
    // MPMusicPlayerController *player = [notification object];
    // state may not be equal to player.playbackState
    
    std::cout << "CinderIPod onStateChanged" << std::endl;
    std::cout << "new state = " << state << std::endl;
    
    if (!m_suppress_events) {
        std::cout << "dispatching callback" << std::endl;
        m_cb_state_change.call(m_player);
    }
    
    std::cout << std::endl;        
}

- (void)onTrackChanged:(NSNotification *)notification
{
    if (!m_suppress_events)
        m_cb_track_change.call(m_player);
}

- (void)onLibraryChanged:(NSNotification *)notification
{
    if (!m_suppress_events)
        m_cb_library_change.call(m_player);
}

@end
