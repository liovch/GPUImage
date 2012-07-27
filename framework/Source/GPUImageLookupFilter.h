#import "GPUImageTwoInputFilter.h"

@interface GPUImageLookupFilter : GPUImageTwoInputFilter

// How To Use:
// 1) Use your favourite photo editing application to apply a filter to lookup.png
// For this to work properly each pixel color must not depend on other pixels (e.g. blur will not work).
// If you need more complex filter you can create as many lookup tables as required.
// E.g. color_balance_lookup_1.png -> GPUImageGaussianBlurFilter -> color_balance_lookup_2.png
// 2) Use you new lookup.png file as a second input for GPUImageLookupFilter.

// Examples:
// TODO: These could be made into GPUImage effects.
//- (UIImage*)applyMissEtikateFilter:(UIImage*)image
//{
//    GPUImagePicture *stillImageSource = [[[GPUImagePicture alloc] initWithImage:image] autorelease];
//    GPUImagePicture *lookupImageSource = [[[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_etikate.png"]] autorelease];
//    
//    GPUImageLookupFilter *lookupFilter = [[[GPUImageLookupFilter alloc] init] autorelease];
//    [stillImageSource addTarget:lookupFilter];
//    [lookupImageSource addTarget:lookupFilter];
//    
//    [stillImageSource processImage];
//    [lookupImageSource processImage];
//    return [lookupFilter imageFromCurrentlyProcessedOutput];
//}

//- (UIImage*)applySoftEleganceFilter:(UIImage*)image
//{
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
//    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_elegance_1.png"]];
//    
//    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
//    [stillImageSource addTarget:lookupFilter];
//    [lookupImageSource addTarget:lookupFilter];
//    
//    GPUImageGaussianBlurFilter *gaussianBlur = [[GPUImageGaussianBlurFilter alloc] init];
//    gaussianBlur.blurSize = 9.7;
//    [lookupFilter addTarget:gaussianBlur];
//    
//    [stillImageSource processImage];
//    [lookupImageSource processImage];
//    
//    UIImage *processedImage = [lookupFilter imageFromCurrentlyProcessedOutput];
//    UIImage *blurredImage = [gaussianBlur imageFromCurrentlyProcessedOutput];
//    [processedImage retain];
//    [blurredImage retain];
//    
//    [gaussianBlur release];
//    [lookupFilter release];
//    [stillImageSource release];
//    [lookupImageSource release];
//    
//    GPUImagePicture *processedSource = [[[GPUImagePicture alloc] initWithImage:processedImage] autorelease];
//    GPUImagePicture *blurredSource = [[[GPUImagePicture alloc] initWithImage:blurredImage] autorelease];
//    [processedImage release];
//    [blurredImage release];
//    
//    GPUImageAlphaBlendFilter *alphaBlend = [[[GPUImageAlphaBlendFilter alloc] init] autorelease];
//    alphaBlend.mix = 0.14;
//    [processedSource addTarget:alphaBlend];
//    [blurredSource addTarget:alphaBlend];
//    
//    lookupImageSource = [[[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_elegance_2.png"]] autorelease];
//    
//    lookupFilter = [[[GPUImageLookupFilter alloc] init] autorelease];
//    [alphaBlend addTarget:lookupFilter];
//    [lookupImageSource addTarget:lookupFilter];
//    
//    [processedSource processImage];
//    [blurredSource processImage];
//    [lookupImageSource processImage];
//    return [lookupFilter imageFromCurrentlyProcessedOutput];
//}

// Additional Info:
// Lookup texture is organised as 8x8 quads of 64x64 pixels representing all possible RGB colors:
//for (int by = 0; by < 8; by++) {
//    for (int bx = 0; bx < 8; bx++) {
//        for (int g = 0; g < 64; g++) {
//            for (int r = 0; r < 64; r++) {
//                image.setPixel(r + bx * 64, g + by * 64, qRgb(3 + r * 4, 3 + g * 4, 3 + (bx + by * 8) * 4));
//            }
//        }
//    }
//}
// TODO: Might need to get rid of added +3 there.

@end
