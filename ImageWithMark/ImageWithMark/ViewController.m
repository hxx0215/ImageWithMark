//
//  ViewController.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/8/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ViewController.h"
#import "ImageMarkView.h"
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) ImageMarkView *markView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(importImage:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    UIBarButtonItem *penItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(editWithPen:)];
    self.navigationItem.leftBarButtonItems = @[penItem];
    self.navigationController.navigationBar.translucent = NO;
    self.markView = [[ImageMarkView alloc] init];
    [self.view addSubview:self.markView];
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
- (void)editWithPen:(id)sender{
    self.markView.hidden = NO;
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
@end
