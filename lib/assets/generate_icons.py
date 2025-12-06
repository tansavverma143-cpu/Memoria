#!/usr/bin/env python3

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Create icon with brain wave and M logo
    size = 1024
    icon = Image.new('RGBA', (size, size), (31, 111, 235, 255))  # Royal Blue
    
    draw = ImageDraw.Draw(icon)
    
    # Draw brain wave pattern
    center = size // 2
    radius = size // 2 - 100
    
    points = []
    for angle in range(0, 360, 5):
        rad = angle * 3.14159 / 180
        x = center + radius * math.cos(rad)
        y = center + radius * math.sin(rad) + math.sin(rad * 3) * 50
        points.append((x, y))
    
    draw.line(points, fill=(212, 175, 55, 255), width=20)  # Deep Gold
    
    # Draw letter M
    try:
        font = ImageFont.truetype("Inter-Bold.ttf", 400)
        draw.text((center - 150, center - 200), "M", fill=(255, 255, 255, 255), font=font)
    except:
        # Fallback if font not found
        draw.text((center - 150, center - 200), "M", fill=(255, 255, 255, 255))
    
    # Save icon
    os.makedirs('assets/icons', exist_ok=True)
    icon.save('assets/icons/app_icon.png')
    
    # Generate different sizes for Android and iOS
    android_sizes = [(48, 48), (72, 72), (96, 96), (144, 144), (192, 192)]
    ios_sizes = [(20, 20), (29, 29), (40, 40), (58, 58), (60, 60), 
                 (76, 76), (80, 80), (87, 87), (120, 120), (152, 152),
                 (167, 167), (180, 180), (1024, 1024)]
    
    for width, height in android_sizes:
        resized = icon.resize((width, height), Image.Resampling.LANCZOS)
        os.makedirs(f'android/app/src/main/res/mipmap-hdpi', exist_ok=True)
        resized.save(f'android/app/src/main/res/mipmap-hdpi/ic_launcher.png')
    
    for width, height in ios_sizes:
        resized = icon.resize((width, height), Image.Resampling.LANCZOS)
        os.makedirs('ios/Runner/Assets.xcassets/AppIcon.appiconset', exist_ok=True)
        resized.save(f'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-{width}x{height}.png')

if __name__ == "__main__":
    import math
    create_app_icon()
    print("App icons generated successfully!")