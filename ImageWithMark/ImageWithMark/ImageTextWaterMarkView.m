//
//  ImageTextWaterMarkView.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/10/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ImageTextWaterMarkView.h"
#import <math.h>
@interface ImageTextWaterMarkView()<UITextFieldDelegate>
@property (nonatomic, retain)UITextField *textField;
@property (nonatomic, retain)UIImageView *rotateView;
@property (nonatomic, assign)CGPoint moveBeginPoint;
@property (nonatomic, assign)CGPoint moveBeginCenter;
@property (nonatomic, assign)CGPoint moveRotateBeginCenter;
@property (nonatomic, assign)CGFloat fontSize;
@property (nonatomic, assign)CGAffineTransform rotateBeginTransform;
@property (nonatomic, assign)CGFloat rotateBeginAngle;
@property (nonatomic, assign)CGFloat moveBeginFontSize;
@end
@implementation ImageTextWaterMarkView
static CGFloat distance(CGPoint a, CGPoint b){
    return sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y));
}
- (instancetype)init{
    self = [super init];
    if (self){
        self.frame = self.superview.bounds;
        self.fontSize = 18.0;
        self.textField = [[UITextField alloc] init];
        [self addSubview:self.textField];
        self.rotateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cropTag.png"]];
        [self addSubview:self.rotateView];
        [self resizeWithContent:NSLocalizedString(@"输入水印内容", nil)];
        self.textField.placeholder = @"输入水印内容";
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.layer.borderWidth = 1.0;
        self.textField.layer.borderColor = [UIColor redColor].CGColor;
        self.textField.clipsToBounds = YES;
        self.textField.layer.shouldRasterize = YES;
        self.textField.delegate = self;
        self.rotateView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectContent:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *rotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
        [self.rotateView addGestureRecognizer:rotateGesture];
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
        self.moveBeginPoint = [recognizer locationInView:self];
        self.moveBeginCenter = self.textField.center;
        self.moveRotateBeginCenter = self.rotateView.center;
    }
    if ((recognizer.state == UIGestureRecognizerStateChanged)||(recognizer.state == UIGestureRecognizerStateEnded)){
        CGPoint current = [recognizer locationInView:self];
        CGPoint vector = CGPointMake(current.x - self.moveBeginPoint.x, current.y - self.moveBeginPoint.y);
        CGPoint destiCenter = CGPointMake(self.moveBeginCenter.x + vector.x, self.moveBeginCenter.y + vector.y);
        self.textField.center = destiCenter;
        self.rotateView.center = CGPointMake(self.moveRotateBeginCenter.x + vector.x, self.moveRotateBeginCenter.y + vector.y);
    }
}
- (void)selectContent:(UITapGestureRecognizer *)recognizer{
    NSLog(@"tap");
}
- (void)rotateGesture:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        self.moveBeginPoint = [recognizer locationInView:self];
        self.moveBeginCenter = self.textField.center;
        self.rotateBeginTransform = self.textField.transform;
        self.rotateBeginAngle = atan2(self.moveBeginPoint.y- self.textField.center.y, self.moveBeginPoint.x - self.textField.center.x) ;
        self.moveRotateBeginCenter = self.rotateView.center;
        self.moveBeginFontSize = self.textField.font.pointSize;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint current = [recognizer locationInView:self];
        CGFloat scale = distance(current, self.moveBeginCenter) / distance(self.moveBeginPoint, self.moveBeginCenter);
        CGAffineTransform transform = self.rotateBeginTransform;
//        transform = CGAffineTransformScale(transform, scale, scale);
        self.textField.font = [UIFont fontWithName:@"Helvetica" size:self.moveBeginFontSize*scale];
        self.fontSize = self.textField.font.pointSize;
        [self.textField sizeToFit];
        CGRect bounds = self.textField.bounds;
        bounds.size.width = [self adaptWidthWithContent:self.textField.text];
        self.textField.bounds = bounds;
        NSLog(@"%@",NSStringFromCGPoint(self.textField.center));
        CGFloat angle = atan2(current.y - self.moveBeginCenter.y, current.x - self.moveBeginCenter.x);
        transform = CGAffineTransformRotate(transform, angle - self.rotateBeginAngle);
        self.textField.transform = transform;
//        self.frame = CGRectMake(self.frame.origin.x + self.textField.frame.origin.x, self.frame.origin.y + self.textField.frame.origin.y, self.textField.frame.size.width + self.rotateView.bounds.size.width/2, self.textField.frame.size.height+self.rotateView.bounds.size.height/2);
//        self.textField.frame = CGRectMake(0, 0, self.textField.frame.size.width, self.textField.frame.size.height);
        
//        CGPoint originVector = CGPointMake(self.moveRotateBeginCenter.x - self.moveBeginCenter.x, self.moveRotateBeginCenter.y - self.moveBeginCenter.y);
//        CGPoint rotateVector = CGPointMake(originVector.x*cos(angle - self.rotateBeginAngle) - originVector.y*sin(angle - self.rotateBeginAngle), originVector.x*sin(angle - self.rotateBeginAngle)+originVector.y*cos(angle - self.rotateBeginAngle));
//        CGPoint scaleVector= CGPointMake(rotateVector.x *scale, rotateVector.y*scale);
//        self.rotateView.center = CGPointMake(self.moveBeginCenter.x + scaleVector.x, self.moveBeginCenter.y + scaleVector.y);
        self.rotateView.center = [self rightBottom:self.textField];
    }
}
- (CGFloat)adaptWidthWithContent:(NSString *)str{
    if (!str || [str isEqualToString:@""])
        str = NSLocalizedString(@"输入水印内容", nil);
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:self.fontSize];
    self.textField.font = font;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : font}];
    CGRect rectSize = [attributedString boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rectSize.size.width;
}
- (void)resizeWithContent:(NSString*)str{
    if (!str || [str isEqualToString:@""])
        str = NSLocalizedString(@"输入水印内容", nil);
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:self.fontSize];
    self.textField.font = font;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : font}];
    CGRect rectSize = [attributedString boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.textField.bounds = CGRectMake(0, 0, rectSize.size.width, rectSize.size.height);
    self.rotateView.center = CGPointMake(self.textField.frame.size.width +self.textField.frame.origin.x, self.textField.frame.size.height+self.textField.frame.origin.y);
    
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    [self resizeWithContent:textField.text];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.rotateBeginTransform = self.textField.transform;
    self.moveBeginCenter = self.textField.center;
    self.rotateView.hidden = YES;
    CGFloat scale = sqrt(self.rotateBeginTransform.a*self.rotateBeginTransform.a+self.rotateBeginTransform.c*self.rotateBeginTransform.c);
    CGAffineTransform transform = CGAffineTransformMake(scale, 0, 0, scale, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        self.textField.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height /3);
        self.textField.transform = transform;
    }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        self.textField.center = self.moveBeginCenter;
        self.textField.transform = self.rotateBeginTransform;
    }completion:^(BOOL finished){
        self.rotateView.hidden = NO;
        self.rotateView.center = [self rightBottom:self.textField];
    }];
    return YES;
}
- (CGPoint)rightBottom:(UIView *)view{
    CGAffineTransform transform = view.transform;
    CGFloat scale = sqrt(transform.a*transform.a + transform.c*transform.c);//scaleX;
    CGFloat angle = atan2(transform.b, transform.a);
    CGPoint orignVector = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    CGPoint rotateVector = CGPointMake(orignVector.x*cos(angle) - orignVector.y*sin(angle), orignVector.x*sin(angle)+orignVector.y*cos(angle));
    CGPoint scaleVector = CGPointMake(rotateVector.x*scale, rotateVector.y*scale);
    return CGPointMake(view.center.x + scaleVector.x, view.center.y + scaleVector.y);
}
@end
