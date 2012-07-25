#import "GPUImageColorBalanceFilter.h"

NSString *const kGPUImageColorBalanceFragmentShaderString = SHADER_STRING
( 
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
    uniform lowp vec3 shadowsShift;
    uniform lowp vec3 midtonesShift;
    uniform lowp vec3 highlightsShift;
    uniform int preserveLuminosity;

    /* Color space conversion functions by:
    ** http://mouaif.wordpress.com/2009/01/05/photoshop-math-with-glsl-shaders/
    ** Photoshop & misc math
    ** Blending modes, RGB/HSL/Contrast/Desaturate, levels control
    **
    ** Romain Dura | Romz
    ** Blog: http://blog.mouaif.org
    ** Post: http://blog.mouaif.org/?p=94
    */
 
    lowp vec3 RGBToHSL(lowp vec3 color)
    {
        lowp vec3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)

        lowp float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
        lowp float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
        lowp float delta = fmax - fmin;             //Delta RGB value

        hsl.z = (fmax + fmin) / 2.0; // Luminance

        if (delta == 0.0)		//This is a gray, no chroma...
        {
            hsl.x = 0.0;	// Hue
            hsl.y = 0.0;	// Saturation
        }
        else                                    //Chromatic data...
        {
            if (hsl.z < 0.5)
                hsl.y = delta / (fmax + fmin); // Saturation
            else
                hsl.y = delta / (2.0 - fmax - fmin); // Saturation
            
            lowp float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
            lowp float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
            lowp float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
            
            if (color.r == fmax )
                hsl.x = deltaB - deltaG; // Hue
            else if (color.g == fmax)
                hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
            else if (color.b == fmax)
                hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue
            
            if (hsl.x < 0.0)
                hsl.x += 1.0; // Hue
            else if (hsl.x > 1.0)
                hsl.x -= 1.0; // Hue
        }

        return hsl;
    }

    lowp float HueToRGB(lowp float f1, lowp float f2, lowp float hue)
    {
        if (hue < 0.0)
            hue += 1.0;
        else if (hue > 1.0)
            hue -= 1.0;
        lowp float res;
        if ((6.0 * hue) < 1.0)
            res = f1 + (f2 - f1) * 6.0 * hue;
        else if ((2.0 * hue) < 1.0)
            res = f2;
        else if ((3.0 * hue) < 2.0)
            res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
        else
            res = f1;
        return res;
    }

    lowp vec3 HSLToRGB(lowp vec3 hsl)
    {
        lowp vec3 rgb;

        if (hsl.y == 0.0)
            rgb = vec3(hsl.z); // Luminance
        else
        {
            lowp float f2;
            
            if (hsl.z < 0.5)
                f2 = hsl.z * (1.0 + hsl.y);
            else
                f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
            
            lowp float f1 = 2.0 * hsl.z - f2;
            
            rgb.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
            rgb.g = HueToRGB(f1, f2, hsl.x);
            rgb.b= HueToRGB(f1, f2, hsl.x - (1.0/3.0));
        }

        return rgb;
    }
 
    lowp float RGBToL(lowp vec3 color)
    {
        lowp float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
        lowp float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB

        return (fmax + fmin) / 2.0; // Luminance
    }
 
    void main()
    {
        lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

        // Alternative way:
        //lowp vec3 lightness = RGBToL(textureColor.rgb);
        lowp vec3 lightness = textureColor.rgb;

        const lowp float a = 0.25;
        const lowp float b = 0.333;
        const lowp float scale = 0.7;

        lowp vec3 shadows = shadowsShift * (clamp((lightness - b) / -a + 0.5, 0.0, 1.0) * scale);
        lowp vec3 midtones = midtonesShift * (clamp((lightness - b) / a + 0.5, 0.0, 1.0) * 
                                              clamp((lightness + b - 1.0) / -a + 0.5, 0.0, 1.0) * scale);
        lowp vec3 highlights = highlightsShift * (clamp((lightness + b - 1.0) / a + 0.5, 0.0, 1.0) * scale);

        mediump vec3 newColor = textureColor.rgb + shadows + midtones + highlights;
        newColor = clamp(newColor, 0.0, 1.0);

        if (preserveLuminosity != 0) {
            lowp vec3 newHSL = RGBToHSL(newColor);
            lowp float oldLum = RGBToL(textureColor.rgb);
            textureColor.rgb = HSLToRGB(vec3(newHSL.x, newHSL.y, oldLum));
            gl_FragColor = textureColor;
        } else {
            gl_FragColor = vec4(newColor.rgb, textureColor.w);
        }
    }
);


@implementation GPUImageColorBalanceFilter

@synthesize shadows = _shadows;
@synthesize midtones = _midtones;
@synthesize highlights = _highlights;
@synthesize preserveLuminosity = _preserveLuminosity;

#pragma mark -
#pragma mark Initialization

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageColorBalanceFragmentShaderString]))
    {
		return nil;
    }
    
    shadowsUniform = [filterProgram uniformIndex:@"shadowsShift"];
    midtonesUniform = [filterProgram uniformIndex:@"midtonesShift"];
    highlightsUniform = [filterProgram uniformIndex:@"highlightsShift"];
    preserveLuminosityUniform = [filterProgram uniformIndex:@"preserveLuminosity"];
    self.shadows = (GPUVector3){ 0.0, 0.0, 0.0 };
    self.midtones = (GPUVector3){ 0.0, 0.0, 0.0 };
    self.highlights = (GPUVector3){ 0.0, 0.0, 0.0 };
    self.preserveLuminosity = YES;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setShadows:(GPUVector3)newValue
{
    _shadows = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform3fv(shadowsUniform, 1, (GLfloat *)&_shadows);
}

- (void)setMidtones:(GPUVector3)newValue
{
    _midtones = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform3fv(midtonesUniform, 1, (GLfloat *)&_midtones);
}

- (void)setHighlights:(GPUVector3)newValue
{
    _highlights = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform3fv(highlightsUniform, 1, (GLfloat *)&_highlights);
}

- (void)setPreserveLuminosity:(BOOL)newValue
{
    _preserveLuminosity = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1i(preserveLuminosityUniform, (GLint)_preserveLuminosity);
}

@end
