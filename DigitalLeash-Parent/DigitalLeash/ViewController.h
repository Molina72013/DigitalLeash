//
//  ViewController.h
//  DigitalLeash
//
//  Created by Cristian Molina on 7/25/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>



@interface ViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIView *header;

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *raidus;


@property (weak, nonatomic) IBOutlet UILabel *longitude;

@property (weak, nonatomic) IBOutlet UILabel *latitude;

- (IBAction)dismissal:(id)sender;

- (IBAction)create:(id)sender;


- (IBAction)update:(id)sender;

- (IBAction)status:(id)sender;



@end

