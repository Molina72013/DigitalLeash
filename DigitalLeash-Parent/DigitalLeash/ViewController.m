//
//  ViewController.m
//  DigitalLeash
//
//  Created by Cristian Molina on 7/25/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface ViewController ()


@end

static NSString* blue = @"blue";

static NSString* red = @"red";

@implementation ViewController{
    CLLocationManager* locationManger;

    __weak IBOutlet UIButton *status;
    __weak IBOutlet UIButton *update;
    __weak IBOutlet UIButton *create;
    id currentSender;
    
     NSMutableDictionary* currentData;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self refreshLabelsAndHeader];
    locationManger = [[CLLocationManager alloc] init];
    [locationManger requestWhenInUseAuthorization];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissal:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)create:(id)sender {
    if([_username.text isEqualToString:@""])
    {
        [self headerChangeColor:red message:@"Error: no username"];
    } else {
        currentSender = sender;
        
        locationManger.delegate = self;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManger requestLocation];
        //   [self printInfo:sender];
    }
}

- (IBAction)update:(id)sender {
    if([_username.text isEqualToString:@""])
    {
        [self headerChangeColor:red message:@"Error: no username"];
    } else
    {

        currentSender = sender;
        
        locationManger.delegate = self;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManger requestLocation];
        // currentSender = sender;
        
        //   [self printInfo:sender];
    }
}

- (IBAction)status:(id)sender
{
    if([_username.text isEqualToString:@""])
    {
        [self headerChangeColor:red message:@"Error: no username"];
    } else
    {
        currentSender = sender;
        
        locationManger.delegate = self;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManger requestLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:@"Failed to Get Your Location"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK button tapped");
                               }];
    
    [alertController addAction:okButton];
    
    [self presentViewController:alertController animated:true completion:nil];
    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    

    CLLocation* newLocation = [locations lastObject];
  //  NSLog(@"didUpdateToLocation: %@", newtLocation);

    
    CLLocation* oldLocation;
    
    if(locations.count > 1)
    {
        oldLocation = [locations objectAtIndex:locations.count-2];
    } else
    {
        oldLocation = nil;
    }
    
    if(newLocation != nil)
    {
        _longitude.text = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude];
        _latitude.text = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude];
    }
    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

    
    if (currentSender == status)
    {
        [currentData setObject:_longitude.text forKey:@"longitude"];
        [currentData setObject:_latitude.text forKey:@"latitude"];
        [self checkUserForUpdate];
    } else
    {
        [self checkUserForUpdate];
    }
        

//    NSLog(@"The user is located at %@ longitude, %@ latitude, and the user name is %@, and the radius is %@", _longitude.text, _latitude.text, _username.text, _raidus.text);
    //1st run it pints the storyboard value  for label texts
    

  //  [self printInfo:[UIButton self];
}

-(void) createUser
{
        if(currentSender == status || currentSender == update)
        {
            [self headerChangeColor:red message:@"LOLOL"];
        } else
        {
    
    
    
        NSDictionary* childDict = @{
                                    @"username":self.username.text,
                                    @"latitude":self.latitude.text,
                                    @"longitude":self.longitude.text,
                                    @"radius":self.raidus.text,
                                    };
        NSError* error;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:childDict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        
        //   [request setValue:_username.text forHTTPHeaderField:@"userid"];
        
        [request setHTTPMethod:@"PUT"];
        
        [request setHTTPBody:jsonData];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error)
            {
                NSLog(@"Status code: %li", (long)((NSHTTPURLResponse *) response).statusCode);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self headerChangeColor:blue message:@""];
                });
            }
            else
            {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        
        [task resume];
        }
    
}

-(void) checkUserForUpdate {
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];
    
    //        NSURLComponents* components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:urlString] resolvingAgainstBaseURL:false];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    request.HTTPMethod = @"GET";
    

    
    NSURLSessionDataTask* task  = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //NSLog(@"got response: 3");
        
        if (error == nil)
        {
            NSDictionary* responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"checkUserForUpdate");
            NSLog(@"got response: %@", responseBody);
            self->currentData = [NSMutableDictionary dictionaryWithDictionary: responseBody];
            if( responseBody){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUser];
                    
                });
              //  [self updateUser]; moved into Queue
            } else if (!response)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self createUser];
                });
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self headerChangeColor:red message:@"Error: no username found"];
                });
            }
            
            
        }else{
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self headerChangeColor:red message:@"Error: no interenet connection"];
            });
        }
    }];
   
    [task resume];
    
}


-(void) updateUser {
    
    if (currentSender == create)
    {
        NSLog(@"Sorry the username is taken");
        [self headerChangeColor:red message:@"Error: username already taken"];
    } else if (currentSender == update)
    {
    
        NSLog(@"create did not get peformed");
        
        
        NSDictionary* childDict = @{
                                    @"latitude":self.latitude.text,
                                    @"longitude":self.longitude.text,
                                    @"radius":self.raidus.text,
                                    };
        NSError* error;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:childDict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.username.text];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        
        //   [request setValue:_username.text forHTTPHeaderField:@"userid"];
        
        [request setHTTPMethod:@"PATCH"];
        
        [request setHTTPBody:jsonData];
        
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error)
            {
                NSLog(@"!error");
                NSLog(@"Status code: %li", (long)((NSHTTPURLResponse *) response).statusCode);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self headerChangeColor:blue message:@""];
                });
            }
            else
            {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        
        [task resume];
    } else if (currentSender  ==  status)
    {
        NSDictionary* currentStatus = [NSDictionary dictionaryWithDictionary:currentData];
        
       // [currentStatus ob]
        
        if([currentStatus objectForKey:@"current_longitude"] && [currentStatus objectForKey:@"current_latitude"])
        {
            [self headerChangeColor: blue message:@""];

            [self isChildInRadius];
        } else if ([currentStatus objectForKey:@"username"])
        {
            [self headerChangeColor:red message:@"Child hasn't reported a location"];
        } else
        {
            [self headerChangeColor:red message:@"The user doesn't not exist"];
            
        }
    }

}
-(void) isChildInRadius
{
    NSDictionary* parent = [NSDictionary dictionaryWithDictionary:currentData];
    
    float parentLatitude = [[parent objectForKey:@"latitude"] floatValue];
    float parentLogitude = [[parent objectForKey:@"longitude"] floatValue];
    float childLatitude = [[parent objectForKey:@"current_latitude"] floatValue];
    float childLongitude = [[parent objectForKey:@"current_longitude"] floatValue];
    
    
    
    
    CLLocation *parentLocaiton = [[CLLocation alloc] initWithLatitude:parentLatitude longitude:parentLogitude];
    CLLocation *childsLocation = [[CLLocation alloc] initWithLatitude:childLatitude longitude:childLongitude];
    
    
    
    CLLocationDistance distnace = [childsLocation distanceFromLocation:parentLocaiton];
    
    float meters = [[parent objectForKey:@"radius"] floatValue];
    
    if (meters >= distnace)
    {
        NSLog(@"Child is in range");
        [self performSegueWithIdentifier:@"greenlight" sender:self];
    } else
    {
        NSLog(@"You can start paniciing");
        [self performSegueWithIdentifier:@"redlight" sender:self];
    }
    
    
}
    

-(void) headerChangeColor:(NSString*)c message:(NSString*)m
{
    if (c == red)
    {
        UIColor *myColor = [UIColor colorWithRed:(243.0 / 255.0) green:(130.0 / 255.0)
                                            blue:(130.0 / 255.0) alpha: 1];
        self.header.backgroundColor = myColor;
        
        _headerLabel.text = [NSString stringWithFormat:@"%@", m];
        
        
    } else if(c == blue)        //else if([c isEqualToString:green])
    {
        UIColor *myColor = [UIColor colorWithRed:(18.0 / 255.0) green:(154.0 / 255.0)
                                            blue:(199.0 / 255.0) alpha: 1];
        self.header.backgroundColor = myColor;
        
        _headerLabel.text = [NSString stringWithFormat:@"%@", m];
    }
    
}

-(void) refreshLabelsAndHeader
{
    [self headerChangeColor:blue message:@""];
    _longitude.text = @"0";
    _latitude.text = @"0";
}


@end
