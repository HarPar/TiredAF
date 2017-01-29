//
//  ViewController.h
//  VRtest2
//
//  Created by toby hacks on 2017-01-28.
//  Copyright © 2017 toby hacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController{
    
    IBOutlet SCNView * view1;
    IBOutlet SCNView * view2;
    
    IBOutlet UIView * camera;
    IBOutlet UIView * camera2; 
    
    IBOutlet UIImageView * v1;
    IBOutlet UIImageView * v2;
    
    IBOutlet UIImageView * secondLine;
    IBOutlet UIImageView * screenLog; 
    
    IBOutlet UIImageView * dark;
    
    IBOutlet UILabel * time1;
    IBOutlet UILabel * time2;
    IBOutlet UILabel * time1d;
    IBOutlet UILabel * time2d;
    
    UIView * smart; 
    
    SCNScene * mainScene;
    
    AVCaptureSession *session;
    AVCaptureDevice * device;
    AVCaptureDeviceInput *input;
    AVCaptureVideoPreviewLayer * previewLayer;
    
    AVCaptureSession *session2;
    AVCaptureDevice * device2;
    AVCaptureDeviceInput *input2;
    AVCaptureVideoPreviewLayer * newCaptureVideoPreviewLayer2;
    
    NSTimer * f1;
}


@end

