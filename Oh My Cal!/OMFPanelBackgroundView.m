///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "OMFPanelBackgroundView.h"

#import "OMCLCDScreen.h"
#import "OMCSettingsBar.h"
#import "OMCBinaryOperationBox.h"
#import "OMCBinaryOperationPanel.h"

#import "OMCCalWithBasicStyle.h"
#import "OMCCalWithProgrammerStyle.h"

#import "OMFMainPanelController.h"

#define ARROW_WIDTH     20.f
#define ARROW_HEIGHT    8.f

#define CORNER_RADIUS   30.f

#define GRAY_SCALE      .12549f
#define ALPHA_VAL       .98f

#define VISUAL_MAGIC    53.f // This magic number just for producing a beautiful appearance

CGFloat static const kPaddingVal = 12.f;
CGFloat static const kLCDHeight = 150.f;
CGFloat static const kBinaryOperationBoxHeight = 60.f;
CGFloat static const kPaddingBetweenBinaryOperationPanelAndKeyboard = 8.f;

// OMFPanelBackgroundView class
@implementation OMFPanelBackgroundView

@synthesize _mainPanelController;

@synthesize _currentCalStyle;
@synthesize _LCDScreen;
@synthesize _settingsBar;
@synthesize _binaryOperationBox;
    @synthesize _binaryOperationPanel;

@synthesize _calWithBasicStyle;
@synthesize _calWithProgrammerStyle;

@synthesize _basicStyleMenuItem;
@synthesize _scientificStyleMenuItem;
@synthesize _programmertyleMenuItem;

@synthesize arrowX = _arrowX;

#define DEBUG_CODE \
    NSLog( @"LCD Screen: %@", NSStringFromRect( self._LCDScreen.frame ) );                  \
    NSLog( @"Settings Bar: %@", NSStringFromRect( self._settingsBar.frame ) );              \
    NSLog( @"Binary Operation Box: %@", NSStringFromRect( self._binaryOperationBox.frame ) );   \
    NSLog( @"Cal With Basic Style: %@", NSStringFromRect( self._calWithBasicStyle.frame ) );    \
    NSLog( @"Cal With Programmer Style: %@", NSStringFromRect( self._calWithProgrammerStyle.frame ) );  \
    printf( "\n\n" )

#pragma mark Conforms <NSAwakeFromNib> protocol
- ( void ) awakeFromNib
    {
    self._currentCalStyle = ( OMCCalStyle )[ [ USER_DEFAULTS objectForKey: OMCDefaultsKeyCalStyle ] intValue ];
    [ self _checkCorrectStyleMenuItem: self._currentCalStyle ];

    [ self _switchCalStyle: self._currentCalStyle ];
    }

- ( void ) _removeAllSubview
    {
    [ [ self _LCDScreen ] removeFromSuperview ];
    [ [ self _settingsBar ] removeFromSuperview ];
    [ [ self _binaryOperationBox ] removeFromSuperview ];
    [ [ self _calWithBasicStyle ] removeFromSuperview ];
    [ [ self _calWithProgrammerStyle ] removeFromSuperview ];
    }

- ( void ) _switchCalStyle: ( OMCCalStyle )_CalStyle
    {
    [ self _removeAllSubview ];

    NSView* currentCal = nil;
    NSMutableArray* components = [ NSMutableArray arrayWithObjects: self._LCDScreen, self._settingsBar, nil ];

    CGFloat newWindowHeight = 0.f;
    NSRect newWindowFrame = NSZeroRect;

    switch( _CalStyle )
        {
    case OMCBasicStyle:         currentCal = self._calWithBasicStyle;       break;
    case OMCScientificStyle:    currentCal = self._calWithProgrammerStyle;/* TODO currentCal = self._calWithScientificStyle: */ break;
    case OMCProgrammerStyle:    currentCal = self._calWithProgrammerStyle;  break;
        }

    // From bottom to top:

    /* Cal with any style */
    [ currentCal setFrameOrigin: NSZeroPoint ];

    /* Binary Operation Box */
    BOOL isBasicStyle = ( currentCal == self._calWithBasicStyle );
    // TODO: BOOL isScientificStyle;
    BOOL isProgrammerStyle = ( currentCal == self._calWithProgrammerStyle );
    if ( isProgrammerStyle )
        {
        [ self._binaryOperationBox setFrame: NSMakeRect( NSMinX( self.bounds ) + kPaddingVal
                                                       , NSMaxY( currentCal.frame ) + kPaddingBetweenBinaryOperationPanelAndKeyboard
                                                       , NSWidth( currentCal.bounds ) - kPaddingVal * 2
                                                       , kBinaryOperationBoxHeight ) ];
        [ components addObject: self._binaryOperationBox ];
        }

    /* Settings Bar */
    CGFloat maxYForSettingBar = 0.f;
    if ( isBasicStyle )
        maxYForSettingBar = NSMaxY( self._calWithBasicStyle.frame ) + kPaddingBetweenBinaryOperationPanelAndKeyboard;
    else if ( isProgrammerStyle )
        maxYForSettingBar = NSMaxY( self._binaryOperationBox.frame );
    // TODO: else if ( isScientifictStyle )

    [ self._settingsBar setFrame: NSMakeRect( NSMinX( self.bounds ) + kPaddingVal
                                            , maxYForSettingBar
                                            , NSWidth( currentCal.bounds ) - kPaddingVal * 2
                                            , 20 ) ];

    [ self._settingsBar._arySegControl setHidden: !isProgrammerStyle ]; // Be visible only for programmer style

    /* LCD Screen */
    [ self._LCDScreen setFrame: NSMakeRect( NSMinX( self.bounds ) + kPaddingVal
                                          , NSMaxY( self._settingsBar.frame ) + 4.f
                                          , NSWidth( currentCal.bounds ) - kPaddingVal * 2
                                          , kLCDHeight
                                          ) ];

    newWindowHeight = NSHeight( currentCal.bounds )
                        + NSHeight( self._LCDScreen.bounds )
                        + ( isProgrammerStyle ? NSHeight( self._binaryOperationBox.bounds ) : 0.f )
                        + VISUAL_MAGIC; // This magic number just for producing a beautiful appearance

    CGPoint oldOrigin = [ self.window frame ].origin;
    newWindowFrame = NSMakeRect( oldOrigin.x, oldOrigin.y // Because of the openPanel: method in OMCMainPanelController, the origin of window does not matter.
                               , NSWidth( currentCal.bounds )
                               , newWindowHeight
                               );

    [ components addObject: currentCal ];

    [ [ self window ] setFrame: [ self._mainPanelController frameBasedOnFrameOfStatusItemView: newWindowFrame ]
                       display: YES
                       animate: YES ];

    [ self setSubviews: components ];
    }

#pragma mark Customize Drawing
- ( void ) drawRect: ( NSRect )_DirtyRect
    {
    NSBezierPath* bezierPath = [ NSBezierPath bezierPath ];

    NSRect bounds = [ self bounds ];
    [ bezierPath moveToPoint: NSMakePoint( self.arrowX, NSMaxY( bounds ) ) ];
    [ bezierPath lineToPoint: NSMakePoint( self.arrowX + ARROW_WIDTH / 2, NSMaxY( bounds ) - ARROW_HEIGHT ) ];
    [ bezierPath lineToPoint: NSMakePoint( NSMaxX( bounds ) - CORNER_RADIUS, NSMaxY( bounds ) - ARROW_HEIGHT ) ];

    NSPoint rightTopCorner = NSMakePoint( NSMaxX( bounds ), NSMaxY( bounds ) - ARROW_HEIGHT );
    [ bezierPath curveToPoint: NSMakePoint( NSMaxX( bounds ), NSMaxY( bounds ) - ARROW_HEIGHT - CORNER_RADIUS )
                controlPoint1: rightTopCorner
                controlPoint2: rightTopCorner ];

    [ bezierPath lineToPoint: NSMakePoint( NSMaxX( bounds ), NSMinY( bounds ) + CORNER_RADIUS ) ];

    NSPoint rightBottomCorner = NSMakePoint( NSMaxX( bounds ), NSMinY( bounds ) );
    [ bezierPath curveToPoint: NSMakePoint( NSMaxX( bounds ) - CORNER_RADIUS, NSMinY( bounds ) )
                controlPoint1: rightBottomCorner
                controlPoint2: rightBottomCorner ];

    [ bezierPath lineToPoint: NSMakePoint( NSMinX( bounds ) + CORNER_RADIUS, NSMinY( bounds ) ) ];

    NSPoint leftBottomCorner = bounds.origin;
    [ bezierPath curveToPoint: NSMakePoint( NSMinX( bounds ), NSMinY( bounds ) + CORNER_RADIUS )
                controlPoint1: leftBottomCorner
                controlPoint2: leftBottomCorner ];

    [ bezierPath lineToPoint: NSMakePoint( NSMinX( bounds ), NSMaxY( bounds ) - ARROW_HEIGHT - CORNER_RADIUS ) ];

    NSPoint leftTopCorner = NSMakePoint( NSMinX( bounds ), NSMaxY( bounds ) - ARROW_HEIGHT );
    [ bezierPath curveToPoint: NSMakePoint( NSMinX( bounds ) + CORNER_RADIUS, NSMaxY( bounds ) - ARROW_HEIGHT )
                controlPoint1: leftTopCorner
                controlPoint2: leftTopCorner ];

    [ bezierPath lineToPoint: NSMakePoint( self.arrowX - ARROW_WIDTH / 2, NSMaxY( bounds ) - ARROW_HEIGHT ) ];
    [ bezierPath closePath ];

    [ NSGraphicsContext saveGraphicsState ];
        {
        [ [ NSColor colorWithDeviceWhite: GRAY_SCALE alpha: ALPHA_VAL ] setFill ];
        [ bezierPath fill ];

        [ [ NSColor clearColor ] setStroke ];
        [ bezierPath stroke ];
        }
    [ NSGraphicsContext restoreGraphicsState ];
    }

#pragma mark Accessors
- ( CGFloat ) arrowX
    {
    return self->_arrowX;
    }

- ( void ) setArrowX: ( CGFloat )_ArrowX
    {
    if ( self->_arrowX != _ArrowX )
        {
        self->_arrowX = _ArrowX;

        [ self setNeedsDisplay: YES ];
        }
    }

#pragma mark IBActions
- ( IBAction ) calStyleChanged: ( id )_Sender
    {
    NSMenuItem* sender = ( NSMenuItem* )_Sender;
    self._currentCalStyle = ( OMCCalStyle )[ sender tag ];

    [ self _checkCorrectStyleMenuItem: self._currentCalStyle ];
    [ self _switchCalStyle: self._currentCalStyle ];

//    [ self._mainPanelController closePanel ];
//    [ self._mainPanelController openPanel ];
    }

- ( void ) _checkCorrectStyleMenuItem: ( OMCCalStyle )_CalStyle
    {
    [ self._basicStyleMenuItem setState: _CalStyle == OMCBasicStyle ];
    [ self._scientificStyleMenuItem setState: _CalStyle == OMCScientificStyle ];
    [ self._programmertyleMenuItem setState: _CalStyle == OMCProgrammerStyle ];

    [ USER_DEFAULTS setInteger: self._currentCalStyle forKey: OMCDefaultsKeyCalStyle ];
    }

@end // OMFPanelBackgroundView

/////////////////////////////////////////////////////////////////////////////

/****************************************************************************
 **                                                                        **
 **      _________                                      _______            **
 **     |___   ___|                                   / ______ \           **
 **         | |     _______   _______   _______      | /      |_|          **
 **         | |    ||     || ||     || ||     ||     | |    _ __           **
 **         | |    ||     || ||     || ||     ||     | |   |__  \          **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _       **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|      **
 **                                           ||                           **
 **                                    ||_____||                           **
 **                                                                        **
 ***************************************************************************/
///:~