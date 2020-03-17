Pod::Spec.new do |s|
  s.name             = 'GooglePlacesAutoPopover'
  s.version          = '0.1.0'
  s.summary          = "Custom textfield with popover using GooglePlaces for address autocomplete and place details"
  s.description      = "iOS framework - custom textfield with popover using GooglePlaces for address autocomplete and place details"

  s.homepage         = 'https://github.com/syvertsj/GooglePlacesAutoPopover'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'James Syvertsen'
  s.source           = { :git => 'https://github.com/syvertsj/GooglePlacesAutoPopover.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files     = 'Source/**/*'
  s.frameworks       = 'UIKit', 'GooglePlaces', 'GoogleMapsBase'
  s.dependency 'GooglePlaces'
  s.static_framework = true
  s.swift_version    = '5.0'
  
end
