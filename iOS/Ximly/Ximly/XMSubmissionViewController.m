//
//  XMSubmissionViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMSubmissionViewController.h"

#import "XMImageCache.h"
#import "XMXimlyHTTPClient.h"

@interface XMSubmissionViewController ()

@end

@implementation XMSubmissionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Photo", @"Photo");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.photoSourceSelectionSheet = [[UIActionSheet alloc] initWithTitle:@"Submit Photo from ..."
                                                                    delegate:self
                                                             cancelButtonTitle:nil
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:nil];
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [self.photoSourceSelectionSheet addButtonWithTitle:@"Camera"];
        [self.photoSourceSelectionSheet addButtonWithTitle:@"Photo Library"];
    }
    else {
        [self.photoSourceSelectionSheet addButtonWithTitle:@"Photo Library"];
    }
    [self.photoSourceSelectionSheet addButtonWithTitle:@"Cancel"];
}

- (void)startSubmissionWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate
{
    self.delegate = submissionDelegate;
    self.pickedImage = nil;
    [self.photoSourceSelectionSheet showInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == -1) {
        return;
    }

	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    BOOL cancelled = NO;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        switch (buttonIndex) {
            case 0:
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 2:
                cancelled = YES;
                break;
            default:
                break;
        };
    } else {
        switch (buttonIndex) {
            case 0:
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                cancelled = YES;
                break;
            default:
                break;
        };
        
    }
    
    if (cancelled == YES) {
        self.view.hidden = YES;
        [self.view removeFromSuperview];
        [self.delegate submissionCancelled];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)submitToCloud
{
    if (!self.pickedImage) {
        return;
    }
    
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    
    XMJob *theJob = [XMJob new];
    theJob.jobData = [@{kJobRequestIDKey : [XMXimlyHTTPClient newRequestID], kJobStatusKey : @"PROCESSING", kJobSubmissionTimeKey : [NSString stringWithFormat:@"%lld", (long long)[[NSDate date] timeIntervalSince1970]*1000]} mutableCopy];
    
    [XMImageCache saveImage:self.pickedImage withKey:theJob.requestID];
    
    [[XMXimlyHTTPClient sharedClient] submitImage:UIImagePNGRepresentation(self.pickedImage) withMetaData:[theJob submissionMetaData]];
    [self.delegate jobSubmitted:theJob];
    [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMITTED object:theJob];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.pickedImage = [XMSubmissionViewController editedImageFromMediaWithInfo:editingInfo];
    
    [self submitToCloud];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    [self.delegate submissionCancelled];
}


// editedImageFromMediaWithInfo: is copied from http://pastebin.com/Qwm8SVnc
// TODO: Move this into a utilities class
static inline double radians (double degrees) {return degrees * M_PI/180;}

+(UIImage*)editedImageFromMediaWithInfo:(NSDictionary*)info{
    if(![info   objectForKey:UIImagePickerControllerCropRect])return nil;
    if(![info   objectForKey:UIImagePickerControllerOriginalImage])return nil;
    
    UIImage *originalImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    CGRect rect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -rect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -rect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, rect.size.width, rect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resultImage;
}

@end
