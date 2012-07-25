#import "GPUImageFilter.h"

@interface GPUImageColorBalanceFilter : GPUImageFilter {
    GLint shadowsUniform;
    GLint midtonesUniform;
    GLint highlightsUniform;
    GLint preserveLuminosityUniform;
}

// Color balance ranges from -1.0 to 1.0, with 0.0 as the normal level

@property(readwrite, nonatomic) GPUVector3 shadows;
@property(readwrite, nonatomic) GPUVector3 midtones;
@property(readwrite, nonatomic) GPUVector3 highlights;
@property(readwrite, nonatomic) BOOL preserveLuminosity;

@end
