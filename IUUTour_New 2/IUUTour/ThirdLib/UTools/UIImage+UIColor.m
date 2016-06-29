#import "UIImage+UIColor.h"
@import Accelerate;
#import <float.h>

@implementation UIImage (UIColor)
// 给透明区域上上色
- (UIImage *)changeImageColor:(UIColor *)theColor {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 图片置灰
- (UIImage *)changeImageToGrayColor {
    
    UIImage *baseImage = [self changeMaskColor:[UIColor whiteColor]];
    CGRect imageRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 baseImage.size.width,
                                                 baseImage.size.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [baseImage CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

// 给遮罩透明区域上上色
- (UIImage *)changeMaskColor:(UIColor *)theColor {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // To show the difference with an image mask, we take the above image and process it to extract
    // the alpha channel as a mask.
    // Allocate data
    NSMutableData *data = [NSMutableData dataWithLength:area.size.width * area.size.height * 1];
    // Create a bitmap context
    CGContextRef context = CGBitmapContextCreate([data mutableBytes], area.size.width, area.size.height, 8, area.size.width, NULL, kCGImageAlphaOnly);
    // Set the blend mode to copy to avoid any alteration of the source data
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    // Draw the image to extract the alpha channel
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, area.size.width, area.size.height), self.CGImage);
    // Now the alpha channel has been copied into our NSData object above, so discard the context and lets make an image mask.
    CGContextRelease(context);
    // Create a data provider for our data object (NSMutableData is tollfree bridged to CFMutableDataRef, which is compatible with CFDataRef)
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFMutableDataRef)data);
    // Create our new mask image with the same size as the original image
    CGImageRef maskImage = CGImageMaskCreate(area.size.width, area.size.height, 8, 8, area.size.height, dataProvider, NULL, YES);
    // And release the provider.
    CGDataProviderRelease(dataProvider);
    
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, maskImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Release mask Image
    CGImageRelease(maskImage);
    return newImage;
}

@end

#pragma mark - UIColor (UIImage)

@implementation UIColor (UIImage)

// 通过颜色返回一个1*1大小的纯色图片
- (UIImage *)image {
    
    CGRect imageRect = CGRectMake(0, 0, 1, 1);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, imageRect);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

- (UIImage *)imagOfWidth:(unsigned int)width height:(unsigned int)height{
    CGRect rect=CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end


@implementation UIImage(Cutting)

- (UIImage *)cuttingWithEdge:(UIEdgeInsets)edge
{
    if (!UIEdgeInsetsEqualToEdgeInsets(edge, UIEdgeInsetsZero))
    {
        CGRect afterCutRect = CGRectMake(edge.left, edge.top, self.size.width - edge.left - edge.right,self.size.height - edge.top - edge.bottom);
        CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage,afterCutRect);
        UIGraphicsBeginImageContext(self.size);
        UIImage *afterCutImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
        return afterCutImage;
    }
    return self;
}
@end

@implementation UIImage (PureColor)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+(UIImage *) getImageFromURL:(NSString *)fileURL
{
    
    NSLog(@"执行图片下载函数");
    
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
    
}

@end

@implementation UIImage (ImageEffects)


- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    unsigned long componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

//- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
//                   withRadius:(CGFloat)blurRadius {
//    if ((blurRadius <= 0.0f) || (blurRadius > 1.0f)) {
//        blurRadius = 0.5f;
//    }
//
//    int boxSize = (int)(blurRadius * 100);
//    boxSize -= (boxSize % 2) + 1;
//
//    CGImageRef rawImage = imageToBlur.CGImage;
//
//    vImage_Buffer inBuffer, outBuffer;
//    vImage_Error error;
//    void *pixelBuffer;
//
//    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//
//    inBuffer.width = CGImageGetWidth(rawImage);
//    inBuffer.height = CGImageGetHeight(rawImage);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
//    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
//
//    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
//
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(rawImage);
//    outBuffer.height = CGImageGetHeight(rawImage);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
//
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
//                                       0, 0, boxSize, boxSize, NULL,
//                                       kvImageEdgeExtend);
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
//                                             outBuffer.width,
//                                             outBuffer.height,
//                                             8,
//                                             outBuffer.rowBytes,
//                                             colorSpace,
//                                             CGImageGetBitmapInfo(imageToBlur.CGImage));
//
//    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
//    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//
//    //clean up
//    CGContextRelease(ctx);
//    CGColorSpaceRelease(colorSpace);
//
//    free(pixelBuffer);
//    CFRelease(inBitmapData);
//    CGImageRelease(imageRef);
//
//    return returnImage;
//}



@end

