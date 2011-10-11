#include <string>
#include <sstream>

#include "cinder/app/AppCocoaTouch.h"
#include "cinder/app/Renderer.h"
#include "cinder/gl/TextureFont.h"

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
    mTextureFont = gl::TextureFont::create( Font( "Helvetica-Bold", 24 ) );
    
    mPlayer.registerStateChanged(this, &PlanetaryTestApp::onStateChanged);
    mPlayer.registerTrackChanged(this, &PlanetaryTestApp::onTrackChanged);
    mPlayer.registerLibraryChanged(this, &PlanetaryTestApp::onLibraryChanged);
}

void PlanetaryTestApp::update()
{
    // this should be the only value that needs polling
    mElapsedTrackTime = mPlayer.getPlayheadTime();    
}

void PlanetaryTestApp::draw()
{
    gl::clear( Color::white() );
    gl::setMatricesWindow( getWindowSize() );
    gl::enableAlphaBlending();
    
    gl::color( Color::black() );

    Vec2f center = getWindowCenter();
    
    Vec2f textOffset = mTextureFont->measureString( mCurrentTrackName );
    textOffset *= 0.5;
    textOffset.y -= 48;
    mTextureFont->drawString( mCurrentTrackName, center - textOffset );

    textOffset = mTextureFont->measureString( mCurrentPlayStateString );
    textOffset *= 0.5;
    mTextureFont->drawString( mCurrentPlayStateString, center - textOffset );

    stringstream ss;
    ss << "Elapsed: " << (int)mElapsedTrackTime << " of Total: " << (int)mCurrentTrackLength;
    string elapsed = ss.str();
    textOffset = mTextureFont->measureString( elapsed );
    textOffset *= 0.5;    
    textOffset.y += 48;
    mTextureFont->drawString( elapsed, center - textOffset );
}

CINDER_APP_COCOA_TOUCH( PlanetaryTestApp, RendererGl )
