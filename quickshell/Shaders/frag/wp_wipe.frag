#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;  // Current wallpaper
layout(binding = 2) uniform sampler2D source2;  // Next wallpaper

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;      // Transition progress (0.0 to 1.0)
    float direction;     // 0=left, 1=right, 2=up, 3=down
    float smoothness;    // Edge smoothness (0.0 to 1.0, 0=sharp, 1=very smooth)
    
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
    
    float mappedSmoothness = mix(0.001, 0.5, ubuf.smoothness * ubuf.smoothness);
    
    float edge = 0.0;
    float factor = 0.0;
    
    float extendedProgress = ubuf.progress * (1.0 + 2.0 * mappedSmoothness) - mappedSmoothness;
    
    if (ubuf.direction < 0.5) {
        edge = 1.0 - extendedProgress;
        factor = smoothstep(edge - mappedSmoothness, edge + mappedSmoothness, uv.x);
        fragColor = mix(color1, color2, factor);
    } 
    else if (ubuf.direction < 1.5) {
        edge = extendedProgress;
        factor = smoothstep(edge - mappedSmoothness, edge + mappedSmoothness, uv.x);
        fragColor = mix(color2, color1, factor);
    }
    else if (ubuf.direction < 2.5) {
        edge = 1.0 - extendedProgress;
        factor = smoothstep(edge - mappedSmoothness, edge + mappedSmoothness, uv.y);
        fragColor = mix(color1, color2, factor);
    }
    else {
        edge = extendedProgress;
        factor = smoothstep(edge - mappedSmoothness, edge + mappedSmoothness, uv.y);
        fragColor = mix(color2, color1, factor);
    }
    
    fragColor *= ubuf.qt_Opacity;
}