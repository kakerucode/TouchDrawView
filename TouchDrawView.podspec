
Pod::Spec.new do |s|

  s.name         = 'TouchDrawView'
  s.version      = '1.0.0'
  s.summary      = 'A view with drawing functions. Include smooth path,rect,line,eraser and set drawing line alpha.'
  s.homepage     = 'https://github.com/kakerucode/TouchDrawView'
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { 'Kakeru' => 'kakerucode@gmail.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/kakerucode/TouchDrawView.git', :tag => s.version }
  s.source_files  = 'TouchDrawView/**/'
  s.frameworks = 'UIKit'
  s.requires_arc     = true

end
