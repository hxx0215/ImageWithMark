//
//  ImageMarkView.m
//  ImageWithMark
//
//  Created by shadowPriest on 4/9/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

#import "ImageMarkView.h"
@interface ImageMarkView()
@property (nonatomic, retain)NSMutableArray *currentLinePoint;
@property (nonatomic, assign)CGMutablePathRef path;
@property(nonatomic, assign) CGPoint currentPoint;
@property(nonatomic, assign) CGPoint previousPoint1;
@property(nonatomic, assign) CGPoint previousPoint2;
@end
@implementation ImageMarkView
static CGPoint midPoint(CGPoint p1,CGPoint p2){
    return CGPointMake((p1.x + p2.x)*0.5, (p1.y+p2.y)*0.5);
}
- (instancetype)init{
    if (self=[super init]){
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _currentLinePoint = [NSMutableArray new];
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
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
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    self.currentPoint = [touch locationInView:self];
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    CGRect bounds = [self addPathPreviousWithSecondPoint:self.previousPoint2 FirstPoint:self.previousPoint1 CurrentPoint:self.currentPoint];
    CGRect drawBox = bounds;
    CGFloat lineWidth = 3.0;
    drawBox.origin.x -= lineWidth * 2.0;
    drawBox.origin.y -= lineWidth * 2.0;
    drawBox.size.width += lineWidth * 4.0;
    drawBox.size.height += lineWidth * 4.0;
    [self setNeedsDisplayInRect:drawBox];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPathRelease(self.path);
    self.path = nil;
}
@end
