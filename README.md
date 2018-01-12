# TouchDrawView
A view with drawing functions. Include smooth path,rect,line,eraser and set drawing line alpha.
![](https://raw.githubusercontent.com/kakerucode/DrawView/master/screenshot.png)

## Usage
Import the folder `TouchDrawView` to  your project or use CocoaPods.
Than you can create `TouchDrawView` from IB or programmatically init it in your code.

## CocoaPods

To install CocoaPods, run:

```bash
$ gem install cocoapods
```

Then create a `Podfile` with the following contents:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'YOUR_TARGET_NAME' do
pod 'TouchDrawView', '~> 1.0.0'
end
```

Finally, run the following command to install it:

```bash
$ pod install
```

## Freature
- Draw path, line, rectangle, ellipse on image
- Eraser
- Undo / Redo
- Multiple color
- Multiple width of lines
- Multiple alpha values
- Export the drawn image.

## Requirement
swift 3.2 or later  \  Xcode 9.0 or later

