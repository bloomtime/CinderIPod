#pragma once

#include "cinder/Cinder.h"
#include "cinder/Surface.h"
#include "cinder/cocoa/CinderCocoaTouch.h"

#include <MediaPlayer/MediaPlayer.h>

#include <vector>
#include <string>
#include <ostream>

using std::string;
using std::vector;

namespace cinder { namespace ipod {

class Track {
public:

    Track(MPMediaItem *media_item);
    ~Track();

    string   getTitle();
    string   getAlbumTitle();
    string   getArtist();

    uint64_t getAlbumId();
    uint64_t getArtistId();
	uint64_t getItemId();

    int      getPlayCount();
    int      getStarRating();
    double   getLength();

    Surface getArtwork(const Vec2i &size);

    MPMediaItem* getMediaItem(){
        return m_media_item;
    };

protected:

    MPMediaItem *m_media_item;

};

typedef std::shared_ptr<Track> TrackRef;

class Playlist {
public:

    Playlist(MPMediaItemCollection *collection);
    ~Playlist();

    string getAlbumTitle();
    string getArtistName();

	TrackRef operator[](const int index) { 
        return TrackRef(new Track([[m_collection items] objectAtIndex: index ]));
    };
	
    size_t size(){ return [[m_collection items] count ]; };

    MPMediaItemCollection* getMediaItemCollection();
    MPMediaItem* getRepresentativeItem();
	
private:
	
	MPMediaItem *m_representative_item;
	MPMediaItemCollection *m_collection;

};

typedef std::shared_ptr<Playlist> PlaylistRef;


PlaylistRef         getAllTracks();
PlaylistRef         getAlbum(uint64_t album_id);
PlaylistRef         getArtist(uint64_t artist_id);
vector<PlaylistRef> getAlbums();
vector<PlaylistRef> getAlbumsWithArtist(const string &artist_name);
vector<PlaylistRef> getArtists();

} } // namespace cinder::ipod
