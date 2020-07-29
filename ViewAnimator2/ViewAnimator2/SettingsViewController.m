//
//  SettingsViewController.m
//  ViewAnimator2
//
//  Created by Gulshan on 29/07/20.
//  Copyright © 2020 Gulshan. All rights reserved.
//

#import "SettingsViewController.h"

@import AVFoundation;

@interface SettingsViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *audioSessionCategoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.audioSessionCategoryLabel.text = [[AVAudioSession sharedInstance] category];
    self.versionLabel.text = @"TEST";
}
@end

