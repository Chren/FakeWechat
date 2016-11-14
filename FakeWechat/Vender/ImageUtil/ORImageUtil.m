//
//  ORImageUtil.m
//  ORead
//
//  Created by chhren on 4/19/14.
//  Copyright (c) 2014 ORead. All rights reserved.
//

#import "ORImageUtil.h"
#import "ORColorUtil.h"

static NSMutableDictionary *colorImageDictionary = nil;

@implementation UIImage(Custom)

+ (UIImage *)imageFromColor:(UIColor *)aColor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorImageDictionary = [[NSMutableDictionary alloc] init];
    });
    
    NSString *colorString = [UIColor stringFromColor:aColor];
    UIImage *image = [colorImageDictionary objectForKey:colorString];
    if (image)
    {
        return image;
    }
    else
    {
        CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [aColor CGColor]);
        CGContextFillRect(context, rect);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [colorImageDictionary setObject:image forKey:colorString];
        return image;
    }
}

+ (UIImage *)imageFromView:(UIView *)aView scale:(CGFloat)aScale
{
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, aView.opaque, aScale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageFromView:(UIView *)aView
{
    UIImage *image = [self imageFromView:aView scale:0.0f];
    return image;
}

+ (UIImage *)noScaleImageFromView:(UIView *)aView
{
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, aView.opaque, 1.0);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageFromView:(UIView *)theView inRect:(CGRect)aRect
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, theView.opaque, NO);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = CGRectMake(aRect.origin.x*scale, aRect.origin.y*scale,
                             aRect.size.width*scale, aRect.size.height*scale);
    CGImageRef cgImg = CGImageCreateWithImageInRect([theImage CGImage], rect);
    UIImage* aImg = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return aImg;
}

+ (UIImage *)imageOfFixedOrientation:(UIImage *)aImage
{
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (UIImage *)scaledToSize:(CGSize)aSize opaque:(BOOL)aOpaque contentMode:(UIViewContentMode)aContentMode scale:(CGFloat)aScale
{
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0.0f, 0.0f, width, height);
    
    if (aContentMode == UIViewContentModeScaleAspectFit)
    {
        CGFloat ratio = width * aSize.height / (height * aSize.width);
        
        if (ratio < 1.0f) {
            bounds.size.width = aSize.width * ratio;
            bounds.size.height = aSize.height;
        } else {
            bounds.size.height = aSize.height / ratio;
            bounds.size.width = aSize.width;
        }
    }
    else if (aContentMode == UIViewContentModeScaleToFill)
    {
        bounds.size = aSize;
    }
    // UIViewContentModeScaleAspectFill
    else
    {
        CGFloat ratio = width * aSize.height / (height * aSize.width);
        
        if (ratio < 1.0f) {
            bounds.size.width = aSize.width;
            bounds.size.height = aSize.height / ratio;
        } else {
            bounds.size.height = aSize.height;
            bounds.size.width = aSize.width * ratio;
        }
    }
    //    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, aOpaque, aScale);
    [self drawInRect:bounds];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)scaledToSize:(CGSize)aSize
{
    UIImage *image = [self scaledToSize:aSize opaque:YES contentMode:UIViewContentModeScaleAspectFill scale:0.0f];
    return image;
}

- (UIImage *)scaledToUploadSize:(CGSize)aSize
{
    UIImage *image = [self scaledToSize:aSize opaque:YES contentMode:UIViewContentModeScaleAspectFit scale:1.0f];
    return image;
}


- (UIImage*) grayscaledImage
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint8_t gray = (uint8_t) ((30 * rgbaPixel[RED] + 59 * rgbaPixel[GREEN] + 11 * rgbaPixel[BLUE]) / 100);
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

+ (UIImage *)imageNamed:(NSString *)name inBundleName:(NSString *)aBundleName
{
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:aBundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    return image;
}
@end


@implementation LDImageUtil


@end
