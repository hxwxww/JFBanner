Pod::Spec.new do |s|

  s.name            = 'JFBanner'
  s.version         = '0.0.1'
  s.summary         = 'A simple way to use BannerView'

  s.homepage        = 'https://github.com/hxwxww/JFBanner'
  s.license         = 'MIT'

  s.author          = { 'hxwxww' => 'hxwxww@163.com' }
  s.platform        = :ios, '9.0'
  s.swift_version   = '5.0'

  s.source          = { :git => 'https://github.com/hxwxww/JFBanner.git', :tag => s.version }

  s.source_files    = 'JFBanner/JFBanner/*.swift'

  s.frameworks      = 'Foundation', 'UIKit'

end
