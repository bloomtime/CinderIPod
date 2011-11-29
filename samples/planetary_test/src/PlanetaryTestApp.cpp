#include <string>
#include <sstream>
#include <vector>
#include <cmath>

#include "cinder/app/AppCocoaTouch.h"
#include "cinder/app/Renderer.h"
#include "cinder/gl/TextureFont.h"
#include "cinder/gl/Texture.h"

#include "CinderIPodPlayer.h"

using namespace ci;
using namespace ci::app;
using namespace ci::ipod;
using namespace std;

class PlanetaryTestApp : public AppCocoaTouch {
  public:
	void setup();
	void update();
	void draw();

    void drawCovers();

    void touchesEnded( TouchEvent event );
    
    // receive notifications from ipod player
    bool onStateChanged(Player *player);
    bool onTrackChanged(Player *player);
    bool onLibraryChanged(Player *player);
    
    // ipod player bits
    Player mPlayer;
    Player::State mCurrentPlayState;
    string mCurrentPlayStateString;
    double mElapsedTrackTime;
    double mCurrentTrackLength;
    string mCurrentTrackName;
    
    vector<PlaylistRef> mAlbums;
    vector<gl::Texture> mTextures;
    
    // text for debugging
    gl::TextureFontRef mTextureFont;
};

bool PlanetaryTestApp::onStateChanged(Player *player)
{
    std::cout << "State Changed at " << getElapsedSeconds() << std::endl;
    mCurrentPlayState = mPlayer.getPlayState();
    mCurrentPlayStateString = mPlayer.getPlayStateString();
    return false;
}

bool PlanetaryTestApp::onTrackChanged(Player *player)
{
    std::cout << "Track Changed at " << getElapsedSeconds() << std::endl;    
    if (mPlayer.hasPlayingTrack()) {
        mElapsedTrackTime = mPlayer.getPlayheadTime();
        mCurrentTrackLength = mPlayer.getPlayingTrack()->getLength();
        mCurrentTrackName = mPlayer.getPlayingTrack()->getTitle();
    } else {
        mElapsedTrackTime = 0.0;
        mCurrentTrackLength = 0.0;
        mCurrentTrackName = "No Track is Playing";
    }
    return false;
}

bool PlanetaryTestApp::onLibraryChanged(Player *player)
{
    std::cout << "Library Changed at " << getElapsedSeconds() << std::endl;
    return false;
}

void PlanetaryTestApp::setup()
{
    std::cout << "Loading Font at " << getElapsedSeconds() << std::endl;
    mTextureFont = gl::TextureFont::create( Font( "Helvetica-Bold", 24 ) );
    
    std::cout << "Loading Albums at " << getElapsedSeconds() << std::endl;
    mAlbums = getAlbums();
    
    Vec2f coverSize(48.0f,48.0f);
    int rows = floor( getWindowWidth() / coverSize.x );
    int cols = floor( getWindowHeight() / coverSize.y );
    float scale = [[[UIApplication sharedApplication] keyWindow] contentScaleFactor];
    std::cout << "scale factor (pt:px) is: " << scale << std::endl;    
    Vec2i pointSize(coverSize.x / scale, coverSize.y / scale );
    int maxNumCovers = std::min((int)mAlbums.size(), (int)(rows * cols));
    for (int i = 0; i < maxNumCovers; i++) {
        Surface surface = mAlbums[i]->firstTrack()->getArtwork( pointSize );
        if (surface) {
            mTextures.push_back( gl::Texture( surface ) );
        } else {
            mTextures.push_back( gl::Texture() );
        }
    }
    
    std::cout << "Registering Player notifications at " << getElapsedSeconds() << std::endl;
    mPlayer.registerStateChanged(this, &PlanetaryTestApp::onStateChanged);
    mPlayer.registerTrackChanged(this, &PlanetaryTestApp::onTrackChanged);
    mPlayer.registerLibraryChanged(this, &PlanetaryTestApp::onLibraryChanged);
}

void PlanetaryTestApp::update()
{
    // this should be the only value that needs polling:
    mElapsedTrackTime = mPlayer.getPlayheadTime();    
    
    // shouldn't need to poll this, but just to be sure:
    mCurrentPlayState = mPlayer.getPlayState();
    mCurrentPlayStateString = mPlayer.getPlayStateString();    
}

void PlanetaryTestApp::touchesEnded( TouchEvent event )
{
    vector<TouchEvent::Touch> touches = event.getTouches();
    if (touches.size() > 0) {
        Vec2f pos = touches[0].getPos();
        Vec2i coverSize(48,48);
        int col = floor(pos.x / (float)coverSize.x);
        int cols = floor( getWindowHeight() / (float)coverSize.y );
        int row = floor(pos.y / (float)coverSize.y);
        int index = col + (row * cols);
        if (index >= 0 && index < mAlbums.size()) {
            if (mPlayer.getCurrentPlaylist() == mAlbums[index]) {
                if (mCurrentPlayState == Player::StatePlaying) {
                    mPlayer.pause();
                } else {
                    mPlayer.play();
                }
            } else {
                mPlayer.play(mAlbums[index]);
            }
        }
    }
}

void PlanetaryTestApp::drawCovers()
{
    Vec2i coverSize(48,48);
    Vec2f coverPos(0,0);
    int rows = floor( getWindowWidth() / coverSize.x );
    int cols = floor( getWindowHeight() / coverSize.y );
    int maxNumCovers = std::min((int)mAlbums.size(), (int)(rows * cols));
    int i = 0;
    gl::color( Color::white() );
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols && i < maxNumCovers; c++) {
            gl::Texture texture = mTextures[i];
            if (texture) {
                gl::color( Color::white() );
                gl::draw(texture, Rectf( coverPos, coverPos+coverSize ));
            }
            gl::color( Color::black() );
            gl::drawStrokedRect( Rectf( coverPos, coverPos+coverSize ) );
            coverPos.x += coverSize.x;
            i++;
        }
        coverPos.x = 0;
        coverPos.y += coverSize.y;        
    }
}

void PlanetaryTestApp::draw()
{
    gl::clear( Color::white() );
    gl::setMatricesWindow( getWindowSize() );
    gl::enableAlphaBlending();

    drawCovers();
    
    Vec2f center = getWindowCenter();
    
    Vec2f trackSize = mTextureFont->measureString( mCurrentTrackName );
    Vec2f trackPos = center - (trackSize * 0.5);
    trackPos.y -= 48;

    Vec2f stateSize = mTextureFont->measureString( mCurrentPlayStateString );
    Vec2f statePos = center - (stateSize * 0.5);

    stringstream ss;
    ss << "Elapsed: " << (int)mElapsedTrackTime << " of Total: " << (int)mCurrentTrackLength;
    string elapsed = ss.str();
    Vec2f timeSize = mTextureFont->measureString( elapsed );
    Vec2f timePos = center - (timeSize * 0.5);    
    timePos.y += 48;
    
    Rectf bgRect(trackPos, trackSize);
    bgRect.include( Rectf( statePos, stateSize ) );
    bgRect.include( Rectf( timePos, timeSize ) );
    gl::color( ColorA( 1.0, 1.0, 1.0, 0.25 ) );
    gl::drawSolidRect( bgRect );
    
    gl::color( Color::black() );    
    mTextureFont->drawString( mCurrentTrackName, trackPos );
    mTextureFont->drawString( mCurrentPlayStateString, statePos );
    mTextureFont->drawString( elapsed, timePos );
}

CINDER_APP_COCOA_TOUCH( PlanetaryTestApp, RendererGl )
