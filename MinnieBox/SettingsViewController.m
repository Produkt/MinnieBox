//
//  SettingsViewController.m
//  MinnieBox
//
//  Created by Victor Baro on 31/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "SettingsViewController.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface SettingsViewController ()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIView *developedViewContainer;
@property (weak, nonatomic) IBOutlet UIView *designedViewContainer;
@property (weak, nonatomic) TTTAttributedLabel *bottomMessage;
@property (weak, nonatomic) IBOutlet UIView *textContainer;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupBorders];
    [self setupAttributedLabel];
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.bottomMessage.frame = self.textContainer.frame;
}
- (void)setupBorders {
    CGFloat borderWidth = 1.0f;
    UIColor *borderColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logoutButton.layer.borderColor = borderColor.CGColor;
    self.logoutButton.layer.borderWidth = borderWidth;
    self.developedViewContainer.layer.borderColor = borderColor.CGColor;
    self.developedViewContainer.layer.borderWidth = 0.8f;
    self.designedViewContainer.layer.borderColor = borderColor.CGColor;
    self.designedViewContainer.layer.borderWidth = 0.8f;
}

- (void) setupAttributedLabel {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:self.textContainer.frame];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    
    NSString *text = @"Minniebox was created during the London Dropbox Hackathon.\n Inspired by DaisyDisk";
    label.text = text;
    label.delegate = self;
    NSRange range = [label.text rangeOfString:@"DaisyDisk"];
    [label addLinkToURL:[NSURL URLWithString:@"http://www.daisydiskapp.com"] withRange:range];
    
    [self.view addSubview:label];
    self.bottomMessage = label;
}
#pragma mark -  ibactions
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)produktPressed:(id)sender {
    [self openTwitterWithUsername:@"produkt"];
}
- (IBAction)fillitoPressed:(id)sender {
    [self openTwitterWithUsername:@"victorbaro"];
}
- (IBAction)victorPressed:(id)sender {
    [self openTwitterWithUsername:@"fillito"];
}
- (IBAction)hugoPressed:(id)sender {
    [self openTwitterWithUsername:@"hugocornejo"];
}

- (void)openTwitterWithUsername:(NSString *)userName {
    // URLs to try
    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",userName]];
    NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@",userName]];
    NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@",userName]];

    
    if ([[UIApplication sharedApplication] canOpenURL:tweetbotURL]) {
        [[UIApplication sharedApplication] openURL:tweetbotURL];
    } else if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        [self openSafariWithURL:webURL];
    }
}
- (void)openSafariWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}
#pragma mark -  TTTAtributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [self openSafariWithURL:url];
}

@end
