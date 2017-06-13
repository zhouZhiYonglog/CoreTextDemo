//
//  CoreTextV.m
//  CoreTextDemo
//
//  Created by Wicky on 16/4/22.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "CoreTextV.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "UIImage+DWImageUtils.h"

@interface CoreTextV ()
{
    CTFrameRef _frame;
    NSInteger _length;
    CGRect _imgFrm;
    NSMutableArray * arrText;
}
@end
@implementation CoreTextV
/*
 写在前面的总结
 coreText实现图文混排其实
 1.就是在富文本中 插入一个空白的 图片占位符的 富文本字符串
 2.通过代理设置相关的图片尺寸信息
 3.根据从富文本得到的frame计算图片绘制的frame再绘制图片这么一个过程。
 
 网上之所以每个demo都那么冗长，实际上是因为他们先写了富文本的其他用法。
 */

-(void)drawRect:(CGRect)rect
{
//    http://www.jianshu.com/p/6db3289fb05d
    [super drawRect:rect];
    //以下四句：coreText使用的是系统坐标，然而我们平时所接触的iOS的都是屏幕坐标，所以要将屏幕坐标系转换系统坐标系，这样才能与我们想想的坐标互相对应。事实上呢，这三句是翻转画布的固定写法，这三句你以后会经常看到的。
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形的变换矩阵为不做图形变换
    CGContextTranslateCTM(context, 0, self.bounds.size.height);//平移方法，将画布向上平移一个屏幕高
    CGContextScaleCTM(context, 1.0, -1.0);//缩放方法，x轴缩放系数为1，则不变，y轴缩放系数为-1，则相当于以x轴为轴旋转180度
    
    
    arrText = [NSMutableArray array];
    NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc] initWithString:@"123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributeStr.length)];
    CTRunDelegateCallbacks callBacks;//创建一个回调结构体，设置相关参数
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));//memset将已开辟内存空间 callbacks 的首 n 个字节的值设为值 0, 相当于对CTRunDelegateCallbacks内存空间初始化
    callBacks.version = kCTRunDelegateVersion1;//设置回调版本，默认这个
    callBacks.getAscent = ascentCallBacks;//设置图片顶部距离基线的距离
    callBacks.getDescent = descentCallBacks;//设置图片底部距离基线的距离
    callBacks.getWidth = widthCallBacks;//设置图片宽度
    
    NSDictionary * dicPic = @{@"height":@90,@"width":@160};//创建一个图片尺寸的字典，初始化代理对象需要
    CTRunDelegateRef delegate = CTRunDelegateCreate(& callBacks, (__bridge void *)dicPic);//创建代理
    
    unichar placeHolder = 0xFFFC;//创建空白字符
    NSString * placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];//以空白字符生成字符串
    NSMutableAttributedString * placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];//用字符串初始化占位符的富文本
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);//给字符串中的范围中字符串设置代理
    CFRelease(delegate);//释放（__bridge进行C与OC数据类型的转换，C为非ARC，需要手动管理）
    
    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:300];//将空白富文本插入
    
    NSDictionary * activeAttr = @{NSForegroundColorAttributeName:[UIColor redColor],@"click":NSStringFromSelector(@selector(click))};//生成一个富文本属性字典
    [attributeStr addAttributes:activeAttr range:NSMakeRange(100, 30)];
    [attributeStr addAttributes:activeAttr range:NSMakeRange(400, 100)];

//    绘制文本
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);//一个frame的工厂，负责生成frame
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath * cirP = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 100, 200)];
    [path appendPath:cirP];//路径裁剪.事实证明这里可以多次添加
    
    _length = attributeStr.length;
    _frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, _length), path.CGPath, NULL);//可以通过framesetter以及你想要绘制的富文本的范围获取该CTRun的frame。
    CTFrameDraw(_frame, context);//根据frame绘制文字
    
//    绘制图片
    
//     我们可以看到，我们是以path和frameSetter去生成我们绘制文本的frame的。
//     所以说，只要在这个地方我们传入的path中将 特殊区域排除 我们获得的frame就 不 包含 该区域，从而绘制的 文本也不会 在该区域中绘制。
//     ------环绕的
    CGContextDrawImage(context, cirP.bounds, [[UIImage imageNamed:@"1.jpg"] dw_ClipImageWithPath:cirP mode:(DWContentModeScaleAspectFill)].CGImage);
    
    //------非环绕的  根据frame返回图片绘制的区域
    UIImage * image = [UIImage imageNamed:@"1.jpg"];
    [self handleActiveRectWithFrame:_frame];//根据frame返回图片绘制的区域
    CGContextDrawImage(context,_imgFrm, image.CGImage);//
    
    CFRelease(_frame);
    CFRelease(frameSetter);

    
    //单独绘制 非环绕
    /*
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);//一个frame的工厂，负责生成frame
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.bounds];
    _length = attributeStr.length;
    _frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, _length), path.CGPath, NULL);//可以通过framesetter以及你想要绘制的富文本的范围获取该CTRun的frame。
    CTFrameDraw(_frame, context);//根据frame绘制文字
     
    UIImage * image = [UIImage imageNamed:@"1.jpg"];
    [self handleActiveRectWithFrame:_frame];//根据frame返回图片绘制的区域
    CGContextDrawImage(context,_imgFrm, image.CGImage);//
    
    CFRelease(_frame);
    CFRelease(frameSetter);
    */
    
    //单独绘制 环绕
    /*
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);//一个frame的工厂，负责生成frame
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath * cirP = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 100, 200)];
    [path appendPath:cirP];//路径裁剪.事实证明这里可以多次添加
    
    _length = attributeStr.length;
    _frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, _length), path.CGPath, NULL);//可以通过framesetter以及你想要绘制的富文本的范围获取该CTRun的frame。
    CTFrameDraw(_frame, context);//根据frame绘制文字
    
    CGContextDrawImage(context, cirP.bounds, [[UIImage imageNamed:@"1.jpg"] dw_ClipImageWithPath:cirP mode:(DWContentModeScaleAspectFill)].CGImage);
    
    CFRelease(_frame);
    CFRelease(frameSetter);
     */
}

#pragma mark ---CTRUN代理---

static CGFloat ascentCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"height"] floatValue];
}
static CGFloat descentCallBacks(void * ref)
{
    return 0;
}
static CGFloat widthCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"width"] floatValue];
}

#pragma mark ---根据frame返回图片绘制的区域---
-(void)handleActiveRectWithFrame:(CTFrameRef)frame
{
//http://www.jianshu.com/p/6db3289fb05d
//    http://www.jianshu.com/p/e154047b0f98
    NSArray * arrLines = (NSArray *)CTFrameGetLines(frame);//根据frame获取需要绘制的线的数组
    NSInteger count = [arrLines count];//获取线的数量
    CGPoint points[count];//建立起点的数组（cgpoint类型为结构体，故用C语言的数组）
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);//获取起点
    
    for (int i = 0; i < count; i ++) {//遍历线的数组
        CTLineRef line = (__bridge CTLineRef)arrLines[i];
        NSArray * arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);//获取GlyphRun数组（GlyphRun：高效的字符绘制方案）
        for (int j = 0; j < arrGlyphRun.count; j ++) {//遍历CTRun数组
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];//获取CTRun
            NSDictionary * attributes = (NSDictionary *)CTRunGetAttributes(run);//获取CTRun的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];//获取代理
            CGPoint point = points[i];//获取一个起点
            if (delegate == nil) {//判断是否图片，不是图片判断是否活跃文字
                NSString * string = attributes[@"click"];
                if (string) {
                    [arrText addObject:[NSValue valueWithCGRect:[self getLocWithFrame:frame CTLine:line CTRun:run origin:point]]];
                }
                continue;
            }
            NSDictionary * metaDic = CTRunDelegateGetRefCon(delegate);//判断代理字典
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            _imgFrm = [self getLocWithFrame:frame CTLine:line CTRun:run origin:point];//获取绘制区域;
        }
    }
}

-(CGRect)getLocWithFrame:(CTFrameRef)frame CTLine:(CTLineRef)line CTRun:(CTRunRef)run origin:(CGPoint)origin
{
    CGFloat ascent;//获取上距
    CGFloat descent;//获取下距
    CGRect boundsRun;//创建一个frame
    boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
    boundsRun.size.height = ascent + descent;
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);//获取x偏移量
    boundsRun.origin.x = origin.x + xOffset;//point是行起点位置，加上每个字的偏移量得到每个字的x
    boundsRun.origin.y = origin.y - descent;
    CGPathRef path = CTFrameGetPath(frame);//获取绘制区域
    CGRect colRect = CGPathGetBoundingBox(path);//获取剪裁区域边框
    CGRect deleteBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);//获取绘制区域
    return deleteBounds;
}

///将系统坐标转换为屏幕坐标
-(CGRect)convertRectFromLoc:(CGRect)rect
{
    return CGRectMake(rect.origin.x, self.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect imageFrmToScreen = [self convertRectFromLoc:_imgFrm];
    if (CGRectContainsPoint(imageFrmToScreen, location)) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"你点击了图片" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        return;
    }
    [arrText enumerateObjectsUsingBlock:^(NSValue * rectV, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect textFrmToScreen = [self convertRectFromLoc:[rectV CGRectValue]];
        if (CGRectContainsPoint(textFrmToScreen, location)) {
            [self click];
            *stop = YES;
        }
    }];
    
}

-(void)click
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"你点击了文字" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
    
}
@end
