#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ssh2'
  s.version          = '2.2.3'
  s.summary          = 'SSH and SFTP client for Flutter.'
  s.description      = <<-DESC
SSH and SFTP client for Flutter. Wraps iOS library NMSSH and Android library Jsch.
                       DESC
  s.homepage         = 'https://github.com/jda258/flutter_ssh2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Joshua Akers' => 'https://github.com/jda258' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GZ-NMSSH', '~> 4.1.5'
  
  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
end
