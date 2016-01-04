#
#  Be sure to run `pod spec lint PGParallaxView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name = 'PGParallaxView'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Parallax View written in Swift, inspired by Yahoo News '
  s.homepage = 'https://github.com/freesuraj/PGParallaxView'
  s.social_media_url = 'http://twitter.com/iosCook'
  s.authors = { 'Suraj Pathak' => 'freesuraj@gmail.com' }
  s.source = { :git => 'https://github.com/freesuraj/PGParallaxView.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Pod/Classes/*.swift'

  s.requires_arc = true
end
