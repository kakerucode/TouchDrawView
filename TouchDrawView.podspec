
Pod::Spec.new do |s|

  s.name         = "TouchDrawView"
  s.version      = “1.0.0”
  s.summary      = “A view with drawing functions. Include smooth path,rect,line,eraser and set drawing line alpha."
  s.homepage     = "https://github.com/kakerucode/TouchDrawView"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "Kakeru" => "kakerucode@gmail.com" }
  s.platform     = :ios, “8.0”
  s.source       = { :git => "https://github.com/kakerucode/TouchDrawView.git", :tag => "#{s.version}" }
  s.source_files  = "TouchDrawView/**/"
  s.exclude_files = "Classes/Exclude"
  s.frameworks = “UIKit”

end
