//
//  iPhoneStreamingPlayerViewController.m
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
 Source file adapted and modified by Benjamin Ignacio on 4/6/2012 for Seattle Art Museum 
 audio guide iPhone app. Changes are:
 - Set mp3 source to "http://www.seattleartmuseum.org/emuseumMedia/media/full/SAMaudio_*.mp3".
 - Change wait animation to standard iPhone wait animation.
 - On play end, dismiss play view and return to tableview.
 - Change play-stop images.
 - Add art images, title, artist and info.
 - Comment out all "release" because I'm using ARC.
 - added viewWillAppear method.
 - Disable device auto-lock in CreateStreamer.
 - Re-enable device auto-lock in DestroyStreamer.
 
 THANK YOU to Matt Gallagher(cocoawithlove.com) for creating and sharing audiostreamer classes and app.
 
 - Thanks to http://icons.mysitemyway.com/ for the media player icons.
 
 */

#import "iPhoneStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation iPhoneStreamingPlayerViewController

@synthesize item, imageView, artist, artFrame, Title, waitIndicator, SAMduration, SAMprogress, controlPanel;

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[UIImage imageNamed:@"playButton.png"] forState:0];
	}
	else
	{
		[button setImage:image forState:0];
        
        //Replace below with iOS UIActivityIndicatorView. - Ben
        /*
		if ([button.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]])
		{
			[self spinButton]; //replaced this with wait indicator
            
		}
        */

        //Replacement for above. - Ben
        button.hidden = TRUE;
        [waitIndicator startAnimating];
		if (!([button.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]]))
		{
            [waitIndicator stopAnimating];
            button.hidden = FALSE;
        }
        //end replacement
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; //enable device auto-lock
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
/*
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}

	[self destroyStreamer];
	
    NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)downloadSourceField.text,
			NULL,
			NULL,
			kCFStringEncodingUTF8)
		autorelease];

    NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(nil,
                                                         (CFStringRef)audioURL,
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];

    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
		[NSTimer
			scheduledTimerWithTimeInterval:0.1
			target:self
			selector:@selector(updateProgress:)
			userInfo:nil
			repeats:YES];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playbackStateChanged:)
		name:ASStatusChangedNotification
		object:streamer];
}
*/

//
// Mods to createStreamer by Ben Ignacio for SAM audio guide:
//  - set audioURL to http://www.seattleartmuseum.org/emuseumMedia/media/full/SAMaudio_*.mp3
//

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];

    
    //Added by Ben Ignacio
    // set url path to mp3.
    NSString *audioURL = [NSString stringWithFormat:@"http://www.seattleartmuseum.org/emuseumMedia/media/full/SAMaudio_%d.mp3", [item.id intValue]];
    
    NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(nil,
                                                         (CFStringRef)audioURL,
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];
    
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
    
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //disable device auto-lock so audio is not interrupted.

}

//
// viewDidLoad
//
// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
    [self setButtonImage:[UIImage imageNamed:@"playButton.png"]];

    //Added by Ben for SAM audio Guide app
    artFrame.layer.cornerRadius = 10; //round the corners
    controlPanel.layer.cornerRadius = 10;
}

//
//Added by Ben Ignacio
//
- (void)viewWillAppear:(BOOL)animated
{
    [self createStreamer];
    [self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
    [streamer start];
	[self setButtonImage:[UIImage imageNamed:@"playButton.png"]];
    NSString *imageName = [NSString stringWithFormat:@"%d.jpg", [item.id intValue]];
    imageView.image = [UIImage imageNamed:imageName];
    artist.text = item.artist; 
    Title.text = item.name;
}

 
- (void)viewDidDisappear:(BOOL)animated
{
    [streamer stop];
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];

	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];

	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playButton.png"]])
	{
//		[downloadSourceField resignFirstResponder]; Not using this. - Ben
		[self createStreamer];
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		[streamer start]; 
	}
	else
	{
		[streamer stop];
	}
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
	}
	else if ([streamer isPlaying])
	{
		[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImage:[UIImage imageNamed:@"playButton.png"]];
	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
/*
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			[positionLabel setText:
				[NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
					progress,
					duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"Time Played:";
	}
}
*/
//
// Modify updateProgress to modify progress and duration labels
//

- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
            SAMprogress.text = [NSString stringWithFormat: @"%.1f", progress];
            SAMduration.text = [NSString stringWithFormat: @"%.1f", duration - progress];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"Time Played:";
	}
}



//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
	[super dealloc];
}

@end
