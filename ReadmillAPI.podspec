Pod::Spec.new do |s|
  s.name     = 'ReadmillAPI'
  s.version  = '1.0.1'
  s.license  = 'MIT'
  s.summary  = 'Readmill Framework'
  s.homepage = 'http://developers.readmill.com'
  s.authors  = { 'Readmill LTD' => 'api@readmill.com' }
  s.ios.deployment_target = '5.0'
  s.source   = { :git => 'https://github.com/nab0y4enko/ios-wrapper.git' }
  s.source_files = 'Classes/Framework/**/*.{h,m}', 'ReadmillAPI/*.{h,pch}'
  s.resources	 = 'Classes/Framework/**/*.xib'
  s.requires_arc = false
  s.dependency  'JSONKit', '~> 1.4'
  s.prefix_header_contents = <<-EOS 
#import "ReadmillAPI-Prefix.pch" 
EOS
end
