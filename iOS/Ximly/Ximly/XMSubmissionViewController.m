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
#import "UIImage+XMAdditions.h"
#import "Flurry.h"

#define kMaxImageDimension      500
#define kPurchaseSuccessfulAlertTitle   @"Purchase Successful!"            // TODO: Put in strings file

#define kRequestFormatActionSheetTitle @"Make me a ..."

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
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
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

    if ([actionSheet.title isEqualToString:kRequestFormatActionSheetTitle]) {
        switch (buttonIndex) {
            case 0:
                self.requestPPTSlide = NO;
                [self submitToCloud];
                break;
            case 1:
                self.requestPPTSlide = YES;
                [self submitToCloud];
                break;
            case 2:
                self.view.hidden = YES;
                [self.view removeFromSuperview];
                [self.delegate submissionCancelled];
                break;
            default:
                break;
        };
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        BOOL cancelled = NO;
        
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
            switch (buttonIndex) {
                case 0:
                    [Flurry logEvent:@"Submit Photo: Camera"];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    [Flurry logEvent:@"Submit Photo: Roll"];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    [Flurry logEvent:@"Submit Photo: Cancel"];
                    cancelled = YES;
                    break;
                default:
                    break;
            };
        } else {
            switch (buttonIndex) {
                case 0:
                    [Flurry logEvent:@"Submit Photo: Roll"];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 1:
                    [Flurry logEvent:@"Submit Photo: Cancel"];
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
}

- (void)submitToCloud
{
    [Flurry logEvent:@"Submit Photo to Cloud"];
    if (!self.pickedImage) {
        return;
    }
        
    if ([XMXimlyHTTPClient getImagesLeft] > 0) {
        [self _submitToCloud];
    } else {
        [self askUserToPurchaseTranscriptions];
    }
    
}

- (void)_submitToCloud
{
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    
    XMJob *theJob = [XMJob new];
    theJob.requestID = [XMXimlyHTTPClient newRequestID];
    theJob.status = kJobStatusOpenString;
    theJob.submissionTime = [NSDate date];
    theJob.requestedResponseFormat = self.requestPPTSlide ? @"ppt" : @"txt";
    
    NSData *imageData = [XMImageCache saveImage:self.pickedImage forJob:theJob];
    self.pickedImage = nil;
    
    [self.delegate jobSubmitted:theJob];
    [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMITTED object:theJob];
    [[XMXimlyHTTPClient sharedClient] submitImage:imageData forJob:theJob];
}

- (void)askUserToPurchaseTranscriptions
{
    if ([XMPurchaseManager isPurchasingEnabled]) {
        [[XMPurchaseManager sharedInstance] setDelegate:self];
        self.isFetchingProducts = YES;
        [[XMPurchaseManager sharedInstance] fetchProducts];
    }
}


- (void)didFetchProducts:(NSDictionary *)products
{
    if ([products count] == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Buy Transcriptions"
                                                            message:@"Please make a purchase to continue using the app."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:[NSString stringWithFormat:@"5-pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts]      objectForKey:kLevel1ProductCode] price] stringValue]],
                                                                    [NSString stringWithFormat:@"20-pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel2ProductCode] price] stringValue]],
                                                                    [NSString stringWithFormat:@"100-pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel3ProductCode] price] stringValue]], nil];
        [alertView show];
    }
}

- (void)failedToStartPurchase
{
    //TODO
}

- (void)didProcessTransactionSuccessfully:(int)numAvailable
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kPurchaseSuccessfulAlertTitle
                                                        message:[NSString stringWithFormat:@"Purchase successful.  You have %d transcriptions left.  One will be used to process the current photo.", numAvailable]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)didProcessTransactionUnsuccessfully
{
    [self alertUserToFailedPurchase];
}

- (void)didProcessTransactionWithAppleError:(NSError *)error
{
    NSString *errorMsg = [NSString stringWithFormat:@"Purchase: Apple Error with code:%d", error.code];
    NSLog(@"%@", errorMsg);
    
    switch (error.code)  {
        case SKErrorUnknown:
        case SKErrorPaymentCancelled:
            // Do nothing
            break;
        default:
            // TODO
            break;
    }
}

- (void)didProcessTransactionWithXimlyError:(int)errorCode
{
    // TODO
}

-(void)alertUserToFailedPurchase
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Failed"
                                                         message:@"Please make sure your payment information on iTunes is up-to-date and try again later."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:kPurchaseSuccessfulAlertTitle]) {
        [self _submitToCloud];
    } else {
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:
                [[XMPurchaseManager sharedInstance] purchaseLevel1Product];
                break;
                
            case 2:
                [[XMPurchaseManager sharedInstance] purchaseLevel2Product];
                break;
                
            case 3:
                [[XMPurchaseManager sharedInstance] purchaseLevel3Product];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    [picker dismissViewControllerAnimated:YES completion:nil];

    
    self.requestFormatActionSheet = [[UIActionSheet alloc] initWithTitle:kRequestFormatActionSheetTitle
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Text transcript", @"PowerPoint slide", nil];
    
    [self.requestFormatActionSheet performSelector:@selector(showInView:) withObject:self.view afterDelay:0.01];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [Flurry logEvent:@"Cancel Image Picker"];
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
