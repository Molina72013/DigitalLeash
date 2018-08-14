//
//  ViewController.m
//  ChidApp
//
//  Created by Cristian Molina on 7/27/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()



@end

static NSString* green = @"green";
static NSString* red = @"red";

@implementation ViewController
{
    CLLocationManager* _locationManager;
    NSString* _latitude;
    NSString* _longitude;

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self headerChangeColor:green message:@""];
    _locationManager = [[CLLocationManager alloc] init];
    //persmisison time
   
    
    [_locationManager requestWhenInUseAuthorization];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doneWithScreen:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)done:(id)sender
{
    NSLog(@"Pushed button");
    if([_username.text isEqualToString:@""])
    {
        [self headerChangeColor:red message:@"Errod: no username"];
    } else
    {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [_locationManager requestLocation];
    }
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self errorMessage];
}



-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"Updating Location");
    CLLocation* newLocation = [locations lastObject];
    
    CLLocation* oldLocation; //= [locations objectAtIndex:locations.count-2];
    
    if(locations.count > 1)
    {
        oldLocation = [locations objectAtIndex:locations.count-2];
    } else
    {
        oldLocation = nil;
    }
    
    
    if(newLocation != nil)
    {
        _latitude = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude];
        _longitude = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude];
        NSLog(@"Longitude: %@, Latitude: %@", _latitude, _longitude);
        
    }
    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

  //  [_locationManager stopUpdatingLocation];

   [self checkOrCreateUser];
    
}














-(void) errorMessage
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"ERROR"
                                                                             message:@"Failed to Get Your Location"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OK button was tapped for the error");
                                                   }];
    
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:true completion:nil];
}




-(void) checkOrCreateUser
{
    NSLog(@"Checking");
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString* url = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];
    
    NSURL* nsurlurl = [NSURL URLWithString:url];
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsurlurl];
    
    request.HTTPMethod = @"GET";
    
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil)
        {
            NSDictionary* responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"got respone: %@", responseBody);
            if(responseBody)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUser];
                    NSLog(@"Updating User");// happens 2nd cause of main

                });
               
            } else
            {
                NSLog(@"Error the user doesn't exist");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self headerChangeColor:red message:@"Error: the user doesn't exist"];
                });
                
            }
        } else
        {
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            //[self createUser];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self headerChangeColor:red message:@"Error: no connection"];
            });
        }
        
        
    }];

    
    [task resume];
}



//-(void) createUser
//{
//    NSDictionary* childDict = @{
//                                @"username":self.username.text,
//                                @"current_latitude":_latitude,
//                                @"current_longitude":_longitude,
//                                };
//
//    NSError* error;
//
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:childDict
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//
//    NSString* url = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];
//
//    NSURL* nsurlurl = [NSURL URLWithString:url];
//
//    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:nsurlurl];
//
//    [request setHTTPMethod:@"PUT"];
//
//    [request setHTTPBody:jsonData];
//
//    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (!error)
//        {
//            NSLog(@"Status code: %li", (long)((NSHTTPURLResponse *)response).statusCode);
//        } else
//        {
//            NSLog(@"Eroor: %@", error.localizedDescription);
//        }
//    }];
//
//    [task resume];
//}


-(void) updateUser
{
    NSDictionary* childDict = @{
                                @"current_latitude":_latitude,
                                @"current_longitude":_longitude,
                                };
    
    NSError* error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:childDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString* url = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];

    NSURL* nsurlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:nsurlurl];
    
    [request setHTTPMethod:@"PATCH"];
    
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"Status code: %li", (long)((NSHTTPURLResponse *)response).statusCode);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"donescreen" sender:self];

                [self headerChangeColor:green message:@""];

            });
            
        } else
        {
            NSLog(@"Error: %@", error.localizedDescription);
           
        }
    }];
    
    [task resume];
    NSLog(@"Updated User");//1

}


-(void) headerChangeColor:(NSString*)c message:(NSString*)m
{
    if (c == red)
    {
        UIColor *myColor = [UIColor colorWithRed:(243.0 / 255.0) green:(130.0 / 255.0)
                                            blue:(130.0 / 255.0) alpha: 1];
        self.header.backgroundColor = myColor;
      
        _headerLabel.text = [NSString stringWithFormat:@"%@", m];

        
    } else if(c == green)        //else if([c isEqualToString:green])
    {
        UIColor *myColor = [UIColor colorWithRed:(127.0 / 255.0) green:(180.0 / 255.0)
                                            blue:(27.0 / 255.0) alpha: 1];
        self.header.backgroundColor = myColor;
        
        _headerLabel.text = [NSString stringWithFormat:@"%@", m];
    }
    
}




@end




















