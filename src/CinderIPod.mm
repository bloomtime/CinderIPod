#include "CinderIPod.h"

namespace cinder { namespace ipod {


// TRACK

Track::Track()
{
}
Track::Track(MPMediaItem *media_item)
{
    m_media_item = [media_item retain];
}
Track::~Track()
{
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
double Track::getReleaseDate()
{
    return [[m_media_item valueForProperty: MPMediaItemPropertyReleaseDate] timeIntervalSince1970];
}
int Track::getReleaseYear()
{
    NSDate *date = [m_media_item valueForProperty: MPMediaItemPropertyReleaseDate];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *components = [gregorian components: NSYearCalendarUnit fromDate: date];
    NSInteger year = [components year];
    [gregorian release];
    return year;
}
int Track::getReleaseMonth()
{
    NSDate *date = [m_media_item valueForProperty: MPMediaItemPropertyReleaseDate];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *components = [gregorian components: NSMonthCalendarUnit fromDate: date];
    NSInteger year = [components year];
    [gregorian release];
    return year;
}
int Track::getReleaseDay()
{
    NSDate *date = [m_media_item valueForProperty: MPMediaItemPropertyReleaseDate];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *components = [gregorian components: NSDayCalendarUnit fromDate: date];
    NSInteger year = [components year];
    [gregorian release];
    return year;
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

Playlist::Playlist()
{
}
Playlist::Playlist(MPMediaItemCollection *media_collection)
{
    NSArray *items = [media_collection items];
    for(MPMediaItem *item in items){
        pushTrack(new Track(item));
    }
}
Playlist::~Playlist()
{
}

void Playlist::pushTrack(TrackRef track)
{
    m_tracks.push_back(track);
}
void Playlist::pushTrack(Track *track)
{
    m_tracks.push_back(TrackRef(track));
}

string Playlist::getAlbumTitle()
{
    MPMediaItem *item = [getMediaItemCollection() representativeItem];
    return string([[item valueForProperty: MPMediaItemPropertyAlbumTitle] UTF8String]);
}

string Playlist::getArtistName()
{
    MPMediaItem *item = [getMediaItemCollection() representativeItem];
    return string([[item valueForProperty: MPMediaItemPropertyArtist] UTF8String]);
}

uint64_t Playlist::getAlbumId()
{
    MPMediaItem *item = [getMediaItemCollection() representativeItem];
    return [[item valueForProperty: MPMediaItemPropertyAlbumPersistentID] longLongValue];
}
    
uint64_t Playlist::getArtistId()
{
    MPMediaItem *item = [getMediaItemCollection() representativeItem];
    return [[item valueForProperty: MPMediaItemPropertyArtistPersistentID] longLongValue];
}
    
double Playlist::getTotalLength()
{
    double length = 0;
    for(Iter it = m_tracks.begin(); it != m_tracks.end(); ++it){
        length += (*it)->getLength();
    }
    return length;
}    
    
MPMediaItemCollection* Playlist::getMediaItemCollection()
{
    NSMutableArray *items = [NSMutableArray array];
    for(Iter it = m_tracks.begin(); it != m_tracks.end(); ++it){
        [items addObject: (*it)->getMediaItem()];
    }
    return [MPMediaItemCollection collectionWithItems:items];
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
    MPMediaQuery *query = [MPMediaQuery artistsQuery];

    vector<PlaylistRef> artists;

    NSArray *query_groups = [query collections];
    for(MPMediaItemCollection *group in query_groups){
        PlaylistRef artist = PlaylistRef(new Playlist(group));
        artists.push_back(artist);
    }

    return artists;
}

vector<PlaylistRef> getPlaylists()
{
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    
    vector<PlaylistRef> playlists;
    
    // TODO: perhaps filter by the MPMediaPlaylistPropertyPlaylistAttributes property?
//        enum {
//            MPMediaPlaylistAttributeNone    = 0,
//            MPMediaPlaylistAttributeOnTheGo = (1 << 0),
//            MPMediaPlaylistAttributeSmart   = (1 << 1),
//            MPMediaPlaylistAttributeGenius  = (1 << 2)
//        };
//    typedef NSInteger MPMediaPlaylistAttribute;    
    
    NSArray *query_groups = [query collections];
    for(MPMediaItemCollection *group in query_groups){
        PlaylistRef playlist = PlaylistRef(new Playlist(group));
        playlists.push_back(playlist);
    }
    
    return playlists;
}
    
} } // namespace cinder::ipod
