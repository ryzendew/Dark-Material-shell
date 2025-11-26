#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;  // Current wallpaper
layout(binding = 2) uniform sampler2D source2;  // Next wallpaper

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;      // Transition progress (0.0 to 1.0)
    float stripeCount;   // Number of stripes (default 12.0)
    float angle;         // Angle of stripes in degrees (default 30.0)
    float smoothness;    // Edge smoothness (0.0 to 1.0, 0=sharp, 1=very smooth)
    float aspectRatio;   // Width / Height of the screen
    
    float fillMode;      // 0=no(center), 1=crop(fill), 2=fit(contain), 3=stretch, 4=tile
    float imageWidth1;   // Width of source1 image
    float imageHeight1;  // Height of source1 image
    float imageWidth2;   // Width of source2 image
    float imageHeight2;  // Height of source2 image
    float screenWidth;   // Screen width
    float screenHeight;  // Screen height
    vec4 fillColor;      // Fill color for empty areas (default: black)
} ubuf;

vec2 calculateUV(vec2 uv, float imgWidth, float imgHeight) {
    float imageAspect = imgWidth / imgHeight;
    float screenAspect = ubuf.screenWidth / ubuf.screenHeight;
    vec2 transformedUV = uv;
    
    if (ubuf.fillMode < 0.5) {
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imageOffset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - vec2(imgWidth, imgHeight)) * 0.5;
        vec2 imagePixel = screenPixel - imageOffset;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    } 
    else if (ubuf.fillMode < 1.5) {
        float scale = max(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (scaledImageSize - vec2(ubuf.screenWidth, ubuf.screenHeight)) / scaledImageSize;
        transformedUV = uv * (vec2(1.0) - offset) + offset * 0.5;
    }
    else if (ubuf.fillMode < 2.5) {
        float scale = min(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - scaledImageSize) * 0.5;
        
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imagePixel = (screenPixel - offset) / scale;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    }
    else if (ubuf.fillMode < 3.5) {
        transformedUV = uv;
    }
    else if (ubuf.fillMode < 4.5) {
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        transformedUV = mod(screenPixel, vec2(imgWidth, imgHeight)) / vec2(imgWidth, imgHeight);
    }
    
    return transformedUV;
}

vec4 sampleWithFillMode(sampler2D tex, vec2 uv, float imgWidth, float imgHeight) {
    vec2 transformedUV = calculateUV(uv, imgWidth, imgHeight);
    
    if (ubuf.fillMode >= 4.5) {
        return texture(tex, transformedUV);
    }
    
    if (transformedUV.x < 0.0 || transformedUV.x > 1.0 || 
        transformedUV.y < 0.0 || transformedUV.y > 1.0) {
        return ubuf.fillColor;
    }
    
    return texture(tex, transformedUV);
}

void main() {
    vec2 uv = qt_TexCoord0;
    
    vec4 color1 = sampleWithFillMode(source1, uv, ubuf.imageWidth1, ubuf.imageHeight1);
    vec4 color2 = sampleWithFillMode(source2, uv, ubuf.imageWidth2, ubuf.imageHeight2);
    
    float mappedSmoothness = mix(0.001, 0.3, ubuf.smoothness * ubuf.smoothness);
    
    float stripes = (ubuf.stripeCount > 0.0) ? ubuf.stripeCount : 12.0;
    float angleRad = radians(ubuf.angle);
    float edgeSmooth = mappedSmoothness;
    
    
    float cosA = cos(angleRad);
    float sinA = sin(angleRad);
    
    float stripeCoord = uv.x * cosA + uv.y * sinA;
    
    float perpCoord = -uv.x * sinA + uv.y * cosA;
    
    float minPerp = min(min(0.0 * -sinA + 0.0 * cosA, 1.0 * -sinA + 0.0 * cosA),
                       min(0.0 * -sinA + 1.0 * cosA, 1.0 * -sinA + 1.0 * cosA));
    float maxPerp = max(max(0.0 * -sinA + 0.0 * cosA, 1.0 * -sinA + 0.0 * cosA),
                       max(0.0 * -sinA + 1.0 * cosA, 1.0 * -sinA + 1.0 * cosA));
    
    float stripePos = stripeCoord * stripes;
    int stripeIndex = int(floor(stripePos));
    
    bool isOddStripe = mod(float(stripeIndex), 2.0) != 0.0;
    
    float normalizedStripePos = clamp(stripePos / stripes, 0.0, 1.0);
    
    float maxDelay = 0.1;
    float stripeDelay = normalizedStripePos * maxDelay;
    
    float stripeProgress;
    if (ubuf.progress <= stripeDelay) {
        stripeProgress = 0.0;
    } else if (ubuf.progress >= (stripeDelay + (1.0 - maxDelay))) {
        stripeProgress = 1.0;
    } else {
        float activeStart = stripeDelay;
        float activeEnd = stripeDelay + (1.0 - maxDelay);
        stripeProgress = (ubuf.progress - activeStart) / (activeEnd - activeStart);
    }
    
    stripeProgress = stripeProgress * stripeProgress * (3.0 - 2.0 * stripeProgress);  // Smootherstep instead of smoothstep
    
    float yPos = perpCoord;
    
    float perpRange = maxPerp - minPerp;
    float margin = edgeSmooth * 2.0;  // Simplified margin calculation
    float edgePosition;
    if (isOddStripe) {
        edgePosition = maxPerp + margin - stripeProgress * (perpRange + margin * 2.0);
    } else {
        edgePosition = minPerp - margin + stripeProgress * (perpRange + margin * 2.0);
    }
    
    float mask;
    if (isOddStripe) {
        mask = smoothstep(edgePosition - edgeSmooth, edgePosition + edgeSmooth, yPos);
    } else {
        mask = 1.0 - smoothstep(edgePosition - edgeSmooth, edgePosition + edgeSmooth, yPos);
    }
    
    fragColor = mix(color1, color2, mask);
    
    if (ubuf.progress <= 0.0) {
        fragColor = color1;  // Only show old wallpaper at start
    } else if (ubuf.progress >= 1.0) {
        fragColor = color2;  // Only show new wallpaper at end
    } else {
        float edgeDist = abs(yPos - edgePosition);
        float shadowStrength = 1.0 - smoothstep(0.0, edgeSmooth * 2.5, edgeDist);
        shadowStrength *= 0.2 * (1.0 - abs(stripeProgress - 0.5) * 2.0);
        fragColor.rgb *= (1.0 - shadowStrength);
        
        float vignette = 1.0 - ubuf.progress * 0.1 * (1.0 - abs(stripeProgress - 0.5) * 2.0);
        fragColor.rgb *= vignette;
    }
    
    fragColor *= ubuf.qt_Opacity;
}