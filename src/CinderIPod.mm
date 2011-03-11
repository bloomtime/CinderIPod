#include "CinderIPod.h"

namespace cinder { namespace ipod {


// TRACK

//Track::Track()
//{
//}
Track::Track(MPMediaItem *media_item)
{
    m_media_item = [media_item retain];
}
Track::~Track()
{
    [m_media_item release];	
}

string Track::getTitle()
{
    return string([[m_media_item valueForProperty: MPMediaItemPropertyTitle] UTF8String]);
}
string Track::getAlbumTitle()
{
    return string([[m_media_item valueForProperty: MPMediaItemPropertyAlbumTitle] UTF8String]);
}
string Track::getArtist()
{
    return string([[m_media_item valueForProperty: MPMediaItemPropertyArtist] UTF8String]);
}

uint64_t Track::getAlbumId()
{
    return [[m_media_item valueForProperty: MPMediaItemPropertyAlbumPersistentID] longLongValue];
}
uint64_t Track::getArtistId()
{
    return [[m_media_item valueForProperty: MPMediaItemPropertyArtistPersistentID] longLongValue];
}
uint64_t Track::getItemId()
{
    return [[m_media_item valueForProperty: MPMediaItemPropertyPersistentID] longLongValue];
}

int Track::getPlayCount()
{
	return [[m_media_item valueForProperty: MPMediaItemPropertyPlayCount] intValue];
}
int Track::getStarRating()
{
	return [[m_media_item valueForProperty: MPMediaItemPropertyRating] intValue];
}
	
double Track::getLength()
{
    return [[m_media_item valueForProperty: MPMediaItemPropertyPlaybackDuration] doubleValue];
}

Surface Track::getArtwork(const Vec2i &size)
{
    MPMediaItemArtwork *artwork = [m_media_item valueForProperty: MPMediaItemPropertyArtwork];
    UIImage *artwork_img = [artwork imageWithSize: CGSizeMake(size.x, size.y)];

    if(artwork_img)
        return cocoa::convertUiImage(artwork_img, true);
    else
        return Surface();
}



// PLAYLIST

//Playlist::Playlist()
//{
//}
Playlist::Playlist(MPMediaItemCollection *media_collection)
{
	m_collection = [media_collection retain];
//    NSArray *items = [media_collection items];
//    for(MPMediaItem *item in items){
//        pushTrack(new Track(item));
//    }
}
Playlist::~Playlist()
{
	[m_collection release];
}

//void Playlist::pushTrack(TrackRef track)
//{
//    m_tracks.push_back(track);
//}
//void Playlist::pushTrack(Track *track)
//{
//    m_tracks.push_back(TrackRef(track));
//}
//
string Playlist::getAlbumTitle()
{
    MPMediaItem *item = [m_collection representativeItem];
    return string([[item valueForProperty: MPMediaItemPropertyAlbumTitle] UTF8String]);
}

string Playlist::getArtistName()
{
    MPMediaItem *item = [m_collection representativeItem];
    return string([[item valueForProperty: MPMediaItemPropertyArtist] UTF8String]);
}

MPMediaItemCollection* Playlist::getMediaItemCollection()
{
	return m_collection;
//    NSMutableArray *items = [NSMutableArray array];
//    for(Iter it = m_tracks.begin(); it != m_tracks.end(); ++it){
//        [items addObject: (*it)->getMediaItem()];
//    }
//    return [MPMediaItemCollection collectionWithItems:items];
}



// IPOD

PlaylistRef getAllTracks()
{
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    MPMediaItemCollection *tracks = [MPMediaItemCollection collectionWithItems: [query items]];

    return PlaylistRef(new Playlist(tracks));
}

PlaylistRef getAlbum(uint64_t album_id)
{
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate: [MPMediaPropertyPredicate
           predicateWithValue: [NSNumber numberWithInteger: MPMediaTypeMusic]
                  forProperty: MPMediaItemPropertyMediaType
    ]];
    [query addFilterPredicate: [MPMediaPropertyPredicate
           predicateWithValue: [NSNumber numberWithUnsignedLongLong: album_id]
                  forProperty: MPMediaItemPropertyAlbumPersistentID
    ]];
    MPMediaItemCollection *tracks = [MPMediaItemCollection collectionWithItems: [query items]];

    return PlaylistRef(new Playlist(tracks));
}

vector<PlaylistRef> getAlbums()
{
    MPMediaQuery *query = [MPMediaQuery albumsQuery];

    vector<PlaylistRef> albums;

    NSArray *query_groups = [query collections];
    for(MPMediaItemCollection *group in query_groups){
        PlaylistRef album = PlaylistRef(new Playlist(group));
        albums.push_back(album);
    }

    return albums;
}

vector<PlaylistRef> getAlbumsWithArtist(const string &artist_name)
{
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate: [MPMediaPropertyPredicate
           predicateWithValue: [NSNumber numberWithInteger: MPMediaTypeMusic]
                  forProperty: MPMediaItemPropertyMediaType
    ]];
    [query addFilterPredicate: [MPMediaPropertyPredicate
           predicateWithValue: [NSString stringWithUTF8String: artist_name.c_str()]
                  forProperty: MPMediaItemPropertyArtist
    ]];
    [query setGroupingType: MPMediaGroupingAlbum];

    vector<PlaylistRef> albums;

    NSArray *query_groups = [query collections];
    for(MPMediaItemCollection *group in query_groups){
        PlaylistRef album = PlaylistRef(new Playlist(group));
        albums.push_back(album);
    }

    return albums;
}

PlaylistRef getArtist(uint64_t artist_id)
{
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	[query addFilterPredicate: [MPMediaPropertyPredicate
								predicateWithValue: [NSNumber numberWithInteger: MPMediaTypeMusic]
								forProperty: MPMediaItemPropertyMediaType
								]];
	[query addFilterPredicate: [MPMediaPropertyPredicate
								predicateWithValue: [NSNumber numberWithUnsignedLongLong: artist_id]
								forProperty: MPMediaItemPropertyArtistPersistentID
								]];
	MPMediaItemCollection *group = [MPMediaItemCollection collectionWithItems: [query items]];
	
	return PlaylistRef(new Playlist(group));
}
	
vector<PlaylistRef> getArtists()
{
	std::cout << "ipod::getArtists()" << std::endl;
	
	NSDate *start = [NSDate date];

    MPMediaQuery *query = [MPMediaQuery artistsQuery];
    NSArray *query_groups = [query collections];

	std::cout << [start timeIntervalSinceNow] << " seconds to run query" << std::endl;

	start = [NSDate date];
	
    vector<PlaylistRef> artists;
    for(MPMediaItemCollection *group in query_groups){
        artists.push_back(PlaylistRef(new Playlist(group)));
    }

	std::cout << [start timeIntervalSinceNow] << " seconds to build playlist refs" << std::endl;

    return artists;
}

} } // namespace cinder::ipod
