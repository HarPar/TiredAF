//
//  ViewController.m
//  VRtest2
//
//  Created by toby hacks on 2017-01-28.
//  Copyright © 2017 toby hacks. All rights reserved.
//

#import "ViewController.h"
#import <MyoKit/MyoKit.h>

@interface ViewController ()

@end

@implementation ViewController

int ti = 0;
BOOL currentSync = false;
double pitch, yaw, roll = 0;
- (void)viewDidLoad
{
    


    view1.center = CGPointMake(166.75, view1.center.y);
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
 
    
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [session addInput:input];
    

    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    AVCaptureVideoOrientation newOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    // set the orientation of preview layer :( which will be displayed in the device )
    [previewLayer.connection setVideoOrientation:newOrientation];
    
    
    
    
    
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width/2, self.view.bounds.size.height)];
    
    NSUInteger replicatorInstances = 2;
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height);
   
    replicatorLayer.instanceCount = replicatorInstances;
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(self.view.bounds.size.width/2, 0.0, 0.0);
    
    [replicatorLayer addSublayer:previewLayer];
    [self.view.layer addSublayer:replicatorLayer];

    [session startRunning];

    
    f1 = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(getpairs) userInfo:NULL repeats:YES];
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                             target:self
                                           selector:@selector(tick:)
                                           userInfo:NULL
                                            repeats:YES];

    [super viewDidLoad];
    
 
    mainScene = [SCNScene sceneNamed:@"shed.dae"];

    
    
    //view1.scene = [SCNScene sceneNamed:@"mug.dae"];

    view1.allowsCameraControl = YES;
    view1.autoenablesDefaultLighting = YES;
    view1.backgroundColor = [UIColor clearColor];
    
    
    
    [self.view addSubview:view1];
    
    //view2 = [SCNScene copyWithZone: view1];
    
    

    //view2.scene = [SCNScene sceneNamed:@"mug.dae"];
    view2.allowsCameraControl = YES;
    view2.autoenablesDefaultLighting = YES;
    view2.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:view2];
    [self.view addSubview:dark];
    [self.view addSubview:time1d];
    [self.view addSubview:time2d];
    

    [self duplicate];
    
    
    [[TLMHub sharedHub] attachToAdjacent];
    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
    [[TLMHub sharedHub] setShouldSendUsageData:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Unsync arm
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    
    //rotation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    
    [self.view addSubview:time1];
    [self.view addSubview:time2];
}


- (void)didReceiveOrientationEvent:(NSNotification*)notification {
    TLMOrientationEvent *orientation = notification.userInfo[kTLMKeyOrientationEvent];
    
    //TODO: do something with the orientation object.
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientation.quaternion];
    if (!currentSync){
        //NSLog(@"PITCH:%f YAW:%f ROLL:%f ", angles.pitch.radians, angles.yaw.radians, angles.roll.radians);
    }
    pitch = angles.pitch.radians;
    yaw = angles.yaw.radians;
    roll = angles.roll.radians;
}

- (void)didSyncArm:(NSNotification *)notification {
    
    if (-0.5 <= pitch && pitch <= 0.5 && -1 <= yaw && yaw <= 1 && -0.5 <= roll && roll <= 0.5){
        // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
        TLMArmSyncEvent *armEvent = notification.userInfo[kTLMKeyArmSyncEvent];
    
        // Update the armLabel with arm information.
        NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
        NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
        //NSLog(@"Arm: %@ X-Direction: %@", armString, directionString);
    
        currentSync = true;
    }
}

- (void)didUnsyncArm:(NSNotification *)notification {
    //NSLog(@"UNSYNCCCC");
    currentSync = false;
   
}

- (void)didReceivePoseChange:(NSNotification*)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    
    //TODO: do something with the pose object.

    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeDoubleTap:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            //NSLog(@"REST");
            break;
        case TLMPoseTypeFist:
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            //NSLog(@"FIST");
            break;
        case TLMPoseTypeWaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            //NSLog(@"WAVE IN");
            
            break;
        case TLMPoseTypeWaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            //NSLog(@"WAVE OUT");
            break;
        case TLMPoseTypeFingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            //NSLog(@"FINGER SPREAD");
            break;
    }

    
    
}
bool dim = NO;
double lastscore=0;
float xPos = -20;
-(void)getpairs{
    
    ti ++;
    
    /*
    if (view1.center.x < 0 || view2.center.x<333){
        view1.center = CGPointMake(333, view1.center.y);
        view2.center = CGPointMake(666, view2.center.y);
    }
    else if(view1.center.x >333 || view2.center.x>666){
        view1.center = CGPointMake(0, view1.center.y);
        view2.center = CGPointMake(333, view2.center.y);
    }
    ////////
    
    if (view1.center.y < 0){
        view1.center = CGPointMake(view1.center.x, 375);
        view2.center = CGPointMake(view2.center.x, 375);
    }
    else if(view1.center.y >375){
        view1.center = CGPointMake(view1.center.x, 0);
        view2.center = CGPointMake(view2.center.x, 0);
    }
     */
    float tolerance = 3.9;
    

    double score = fabs(pitch) + fabs(yaw) + fabs(roll);
    
    
    
    if (ti %20 == 0){
        float difference = score/1 - lastscore;
        difference = fabs(difference) * 1000;
        NSLog(@"%f", difference);
        if (difference > tolerance){
            dim = NO;
        }
        else{
            dim = YES;
        }
        score = 0;
    }
    else if (ti%10 == 0){
        score = score/1;
        
        lastscore = score;
        score = 0;
    }
    
    if (dim == YES){
        [dark setAlpha:dark.alpha+0.0005];
        if (dark.alpha > 1){
            [dark setAlpha:1];
        }
    }
    else{
        [dark setAlpha:dark.alpha-0.001];
        if (dark.alpha < 0){
            [dark setAlpha:0];
        }
    }
    //Swapping Times
    if (dark.alpha > 0.8){
        time1.hidden = YES;
        time2.hidden = YES;
        time1d.hidden = NO;
        time2d.hidden = NO;
    }
    else{
        time1d.hidden = YES;
        time2d.hidden = YES;
        time1.hidden = NO;
        time2.hidden = NO;
    }
        
    /////ANIMATIONS BELOW
    xPos = xPos + 0.5;
    float yPos = -3*xPos*xPos/196 + 225 * xPos/49 - 2175/49;
    
    view1.center = CGPointMake(xPos-10, 375-yPos);
    view2.center = CGPointMake(xPos + 375, 375-yPos);
    
    if (xPos > 350){
        xPos = -20;
    }

    

    
}

//Function to update time
- (void)tick:(NSTimer*)t
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *timeString = [dateFormatter stringFromDate:now];
    [time1 setText:timeString];
    [time2 setText:timeString];
    
    [time1d setText:timeString];
    [time2d setText:timeString];
}







-(void)duplicate{
 
    view2.scene = mainScene;
    view1.scene = mainScene;
    
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
   
    NSLog(@"HIII");
    
    [self duplicate];
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
