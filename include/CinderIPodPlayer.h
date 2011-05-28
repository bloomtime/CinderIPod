#pragma once

#include "CinderIPodPlayerImpl.h"
#include "CinderIPod.h"

namespace cinder { namespace ipod {

class Player {
public:

    enum State {
        StateStopped         = MPMusicPlaybackStateStopped,
        StatePlaying         = MPMusicPlaybackStatePlaying,
        StatePaused          = MPMusicPlaybackStatePaused,
        StateInterrupted     = MPMusicPlaybackStateInterrupted,
        StateSeekingForward  = MPMusicPlaybackStateSeekingForward,
        StateSeekingBackward = MPMusicPlaybackStateSeekingBackward
    };

    enum ShuffleMode {
        ShuffleModeDefault = MPMusicShuffleModeDefault, 
        ShuffleModeOff     = MPMusicShuffleModeOff, 
        ShuffleModeSongs   = MPMusicShuffleModeSongs, 
        ShuffleModeAlbums  = MPMusicShuffleModeAlbums        
    };    
    
    enum RepeatMode {
        RepeatModeDefault = MPMusicRepeatModeDefault, 
        RepeatModeNone    = MPMusicRepeatModeNone, 
        RepeatModeOne     = MPMusicRepeatModeOne, 
        RepeatModeAll     = MPMusicRepeatModeAll
    };
    
    Player();
    ~Player();

//    void play( TrackRef playlist );
    void play( PlaylistRef playlist );
    void play( PlaylistRef playlist, const int index );
	void play();
	void pause();
    void stop();
    void skipNext();
    void skipPrev();

    void   setPlayheadTime(double time);
    double getPlayheadTime();

    void        setShuffleMode(ShuffleMode mode);
    ShuffleMode getShuffleMode();
    
    void       setRepeatMode(RepeatMode mode);
    RepeatMode getRepeatMode();

    bool hasPlayingTrack();
    TrackRef getPlayingTrack();
    State    getPlayState();

    string getPlayStateString();
        
    template<typename T>
    CallbackId registerTrackChanged( T *obj, bool (T::*callback)(Player*) ){
        return m_pod->m_cb_track_change.registerCb(std::bind1st(std::mem_fun(callback), obj));
    }
    template<typename T>
    CallbackId registerStateChanged( T *obj, bool (T::*callback)(Player*) ){
        return m_pod->m_cb_state_change.registerCb(std::bind1st(std::mem_fun(callback), obj));
    }
    template<typename T>
    CallbackId registerLibraryChanged( T *obj, bool (T::*callback)(Player*) ){
        return m_pod->m_cb_library_change.registerCb(std::bind1st(std::mem_fun(callback), obj));
    }

protected:

    CinderIPodPlayerImpl *m_pod;

};

} } // namespace cinder::ipod
