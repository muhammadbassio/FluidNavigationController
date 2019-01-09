Pod::Spec.new do |s|
  s.name             = 'FluidNavigationController'
  s.version          = '1.0'
  s.summary          = 'A customizable nice looking NavigationController'
 
  s.description      = <<-DESC
A customizable nice looking NavigationController (written in swift).
                       DESC
 
  s.homepage         = 'https://github.com/muhammadbassio/FluidNavigationController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhammad Bassio' => 'muhammadbassio@gmail.com' }
  s.source           = { :git => 'https://github.com/muhammadbassio/FluidNavigationController.git', :tag => s.version.to_s }
 
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
  s.ios.deployment_target = '11.0'
  s.source_files = 'source/**/*.swift'
  s.resources = 'source/**/*.xcassets'
 
end