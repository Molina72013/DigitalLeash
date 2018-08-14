//
//  ViewController.h
//  ChidApp
//
//  Created by Cristian Molina on 7/27/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ViewController : UIViewController  <CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UIView *header;

@property (weak, nonatomic) IBOutlet UITextField *username;

- (IBAction)doneWithScreen:(id)sender;

- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;


@end

