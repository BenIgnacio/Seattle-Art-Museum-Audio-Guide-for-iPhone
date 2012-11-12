//
//  iPhoneStreamingPlayerViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//
/*
 Additions to this file made by Benjamin Ignacio on 4/6/2012 for Seattle Art Museum 
 audio guide iPhone app. Changes are:
 - Set mp3 source to "http://www.seattleartmuseum.org/emuseumMedia/media/full/SAMaudio_*.mp3".
 - Remove volume slider.
 - Change wait animation to standard iPhone wait animation.
 - On play end, dismiss play view and return to tableview.
 - Change play-stop images.
 - Add art images, title, artist and info.
 - Add imports and instance vars for SAM audio guide app.
 
 THANK YOU to Matt Gallagher(cocoawithlove.com) for creating and sharing audiostreamer classes and app.
 
 */

#import <UIKit/UIKit.h>
#import "Item.h" //Added for SAM audio guide app

@class AudioStreamer;

@interface iPhoneStreamingPlayerViewController : UIViewController
{
	IBOutlet UITextField *downloadSourceField;
	IBOutlet UIButton *button;
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UISlider *progressSlider;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
}

//added for SAM audio guide
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *artist;
@property (nonatomic, retain) IBOutlet UIView *artFrame;
@property (nonatomic, retain) IBOutlet UITextView *Title;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitIndicator;
@property (nonatomic, retain) IBOutlet UILabel *SAMprogress;
@property (nonatomic, retain) IBOutlet UILabel *SAMduration;
@property (nonatomic, retain) IBOutlet UIView *controlPanel;
//end add

- (IBAction)buttonPressed:(id)sender;
- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(UISlider *)aSlider;

@end

