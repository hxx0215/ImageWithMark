//
//  ImageTextWaterMarkView.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/10/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ImageTextWaterMarkView.h"
@interface ImageTextWaterMarkView()<UITextFieldDelegate>
@property (nonatomic, retain)UITextField *textField;
@property (nonatomic, retain)UIImageView *rotateView;
@property (nonatomic, assign)CGPoint moveBeginPoint;
@property (nonatomic, assign)CGPoint moveBeginCenter;
@property (nonatomic, assign)CGFloat fontSize;
@end
@implementation ImageTextWaterMarkView
- (instancetype)init{
    self = [super init];
    if (self){
        self.fontSize = 18.0;
        self.textField = [[UITextField alloc] initWithFrame:self.bounds];
        [self addSubview:self.textField];
        self.rotateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cropTag.png"]];
        [self addSubview:self.rotateView];
        [self resizeWithContent:NSLocalizedString(@"输入水印内容", nil)];
        self.textField.placeholder = @"输入水印内容";
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.rotateView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectContent:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)moveGesture:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        self.moveBeginPoint = [recognizer locationInView:self.superview];
        self.moveBeginCenter = self.center;
    }
    if ((recognizer.state == UIGestureRecognizerStateChanged)||(recognizer.state == UIGestureRecognizerStateEnded)){
        CGPoint current = [recognizer locationInView:self.superview];
        CGPoint vector = CGPointMake(current.x - self.moveBeginPoint.x, current.y - self.moveBeginPoint.y);
        CGPoint destiCenter = CGPointMake(self.moveBeginCenter.x + vector.x, self.moveBeginCenter.y + vector.y);
        self.center = destiCenter;
    }
}
- (void)selectContent:(UITapGestureRecognizer *)recognizer{
    NSLog(@"tap");
}
- (void)resizeWithContent:(NSString*)str{
    if (!str || [str isEqualToString:@""])
        str = NSLocalizedString(@"输入水印内容", nil);
    CGFloat delta = 2;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:self.fontSize];
    self.textField.font = font;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : font}];
    CGRect rectSize = [attributedString boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, rectSize.size.width + delta, rectSize.size.height + delta);
    self.rotateView.frame = CGRectMake(self.bounds.size.width - self.rotateView.bounds.size.width /2  , self.bounds.size.height - self.rotateView.bounds.size.height /2  , self.rotateView.bounds.size.width, self.rotateView.bounds.size.height);
    self.textField.frame = self.bounds;
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    [self resizeWithContent:textField.text];
}
@end
