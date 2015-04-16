//
//  ImageMarkView.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/9/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ImageMarkView.h"
@interface ImageMarkView()
@property (nonatomic, retain)NSMutableArray *historyPoints;
@property (nonatomic, retain)NSMutableArray *historyPath;
@property (nonatomic, retain)NSMutableArray *currentLinePoint;
@property (nonatomic, assign)CGMutablePathRef path;
@property(nonatomic, assign) CGPoint currentPoint;
@property(nonatomic, assign) CGPoint previousPoint1;
@property(nonatomic, assign) CGPoint previousPoint2;
@property (nonatomic, retain)UIImage *image;
@end
@implementation ImageMarkView
static CGPoint midPoint(CGPoint p1,CGPoint p2){
    return CGPointMake((p1.x + p2.x)*0.5, (p1.y+p2.y)*0.5);
}
static CGPoint pointApplytoScale(CGPoint p,CGSize s){
    return CGPointMake(p.x / s.width, p.y / s.height);
}
- (instancetype)init{
    if (self=[super init]){
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _currentLinePoint = [NSMutableArray new];
        _imageScale = CGSizeMake(1.0, 1.0);
    }
    return self;
}
- (CGRect)addPathPreviousWithSecondPoint:(CGPoint)p2Point FirstPoint:(CGPoint)p1Point CurrentPoint:(CGPoint)cpoint{
    CGPoint mid1 = midPoint(p1Point, p2Point);
    CGPoint mid2 = midPoint(cpoint, p1Point);
    CGMutablePathRef subPath = CGPathCreateMutable();
    CGPathMoveToPoint(subPath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subPath, NULL, p1Point.x, p1Point.y, mid2.x, mid2.y);
    [self.currentLinePoint addObject:[NSValue valueWithCGPoint:mid1]];
    [self.currentLinePoint addObject:[NSValue valueWithCGPoint:mid2]];
    [self.currentLinePoint addObject:[NSValue valueWithCGPoint:p1Point]];
    CGRect bounds = CGPathGetBoundingBox(subPath);
    CGPathAddPath(self.path, NULL, subPath);
    CGPathRelease(subPath);
    return bounds;
}
- (void)updateCacheImage:(BOOL)flag{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGFloat lineWidth = 3.0;
    UIColor *lineColor = [UIColor redColor];
    CGFloat lineOpacity = 1.0;
    if (flag) {
        
        self.image = nil;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, self.imageScale.width, self.imageScale.height);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGContextSetLineWidth(context, lineWidth);
        const CGFloat* component = CGColorGetComponents(lineColor.CGColor);
        if (component) {
            CGContextSetRGBStrokeColor(context, component[0], component[1], component[2], lineOpacity);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        }
        
        for (UIBezierPath *path in self.historyPath) {
            CGContextAddPath(context, path.CGPath);
        }
        CGContextStrokePath(context);
        
    } else {
        
        [self.image drawAtPoint:CGPointZero];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, self.imageScale.width, self.imageScale.height);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGContextSetLineWidth(context, lineWidth);
        const CGFloat* component = CGColorGetComponents(lineColor.CGColor);
        if (component) {
            CGContextSetRGBStrokeColor(context, component[0], component[1], component[2], lineOpacity);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        }
        
        CGContextAddPath(context, _path);
        CGContextStrokePath(context);
    }
    
    // store the image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.image drawInRect:self.bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, self.imageScale.width, self.imageScale.height);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 3.0);
    UIColor *color = [UIColor redColor];
    const CGFloat* component = CGColorGetComponents(color.CGColor);
    if (component) {
        CGContextSetRGBStrokeColor(context, component[0], component[1], component[2], 1.0);
    }
    else
    {
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    }
    
    CGContextAddPath(context, _path);
    CGContextStrokePath(context);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.path)
        self.path = CGPathCreateMutable();
    UITouch *touch = [touches anyObject];
    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    self.previousPoint1 = pointApplytoScale(self.previousPoint1, self.imageScale);
    self.currentPoint = pointApplytoScale(self.currentPoint, self.imageScale);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    self.currentPoint = [touch locationInView:self];
    self.currentPoint = pointApplytoScale(self.currentPoint, self.imageScale);
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    self.previousPoint1 = pointApplytoScale(self.previousPoint1, self.imageScale);
    CGRect bounds = [self addPathPreviousWithSecondPoint:self.previousPoint2 FirstPoint:self.previousPoint1 CurrentPoint:self.currentPoint];
    bounds.origin.x *= self.imageScale.width;
    bounds.origin.y *= self.imageScale.height;
    bounds.size.width *= self.imageScale.width;
    bounds.size.height *= self.imageScale.height;
    CGRect drawBox = bounds;
    CGFloat lineWidth = 3.0;
    drawBox.origin.x -= lineWidth * 2.0;
    drawBox.origin.y -= lineWidth * 2.0;
    drawBox.size.width += lineWidth * 4.0;
    drawBox.size.height += lineWidth * 4.0;
    [self setNeedsDisplayInRect:drawBox];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *temp = [[[NSMutableArray alloc] initWithArray:self.currentLinePoint copyItems:YES] autorelease];
    [self.historyPoints addObject:temp];
    [self.currentLinePoint removeAllObjects];
//    CGPathRef tPath = CGPathCreateCopy(self.path);
//    [self.historyPath addObject:[NSValue value:&tPath withObjCType:@encode(CGPathRef)]];
    UIBezierPath *bPath = [UIBezierPath bezierPathWithCGPath:self.path];
    [self.historyPath addObject:bPath];
    [self updateCacheImage:NO];
    CGPathRelease(self.path);
    self.path = nil;
}
@end
