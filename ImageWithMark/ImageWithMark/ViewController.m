//
//  ViewController.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/8/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ViewController.h"
#import "ImageMarkView.h"
#import "ImageTextWaterMarkView.h"

@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) ImageMarkView *markView;
@property (nonatomic, retain) ImageTextWaterMarkView *waterView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(importImage:)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)];
    self.navigationItem.rightBarButtonItems = @[rightItem,saveItem];
    UIBarButtonItem *penItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(editWithPen:)];
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(editWithText:)];
    self.navigationItem.leftBarButtonItems = @[penItem,textItem];
    self.navigationController.navigationBar.translucent = NO;
    self.markView = [[ImageMarkView alloc] init];
    [self.view addSubview:self.markView];
    self.waterView = [[ImageTextWaterMarkView alloc] init];
    [self.view addSubview:self.waterView];
    self.waterView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageView.frame = self.view.bounds;
    self.markView.frame = self.view.bounds;
    self.markView.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)importImage:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}
- (void)saveImage:(id)sender{
    self.markView.backgroundColor = [UIColor clearColor];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)editWithPen:(id)sender{
    self.markView.hidden = NO;
}
- (void)editWithText: (id)sender{
    self.waterView.hidden = NO;
}
#pragma mark - ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    if (buttonIndex == 0)
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    else if (buttonIndex == 1)
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else
        return;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}
#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%@",info);
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark -SaveImageComplete
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    self.markView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
}
#pragma touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.waterView endEditing:YES];
}
@end
