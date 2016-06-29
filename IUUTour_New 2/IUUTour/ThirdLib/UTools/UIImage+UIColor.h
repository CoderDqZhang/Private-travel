#import <UIKit/UIKit.h>

@interface UIImage (UIColor)
// 给透明区域上上色
- (UIImage *)changeImageColor:(UIColor *)theColor;

// 图片置灰
- (UIImage *)changeImageToGrayColor;

@end


// 通过颜色返回一个1*1大小的纯色图片
@interface UIColor (UIImage)

// 通过颜色返回一个1*1大小的纯色图片
- (UIImage *)image;

- (UIImage *)imagOfWidth:(unsigned int)width height:(unsigned int)height;

@end

@interface UIImage(Cutting)

- (UIImage *)cuttingWithEdge:(UIEdgeInsets)edge;


//- (UIImage *)centerImage;

@end

@interface UIImage(PureColor)

+(UIImage *) getImageFromURL:(NSString *)fileURL;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+(UIImage *) createImageWithColor: (UIColor *) color;

@end

@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

