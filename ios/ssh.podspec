#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ssh2'
  s.version          = '2.1.0'
  s.summary          = 'SSH and SFTP client for Flutter.'
  s.description      = <<-DESC
SSH and SFTP client for Flutter. Wraps iOS library NMSSH and Android library Jsch.
                       DESC
  s.homepage         = 'https://github.com/jda258/flutter_ssh2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Qian Sha' => 'https://github.com/jda258' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'NMSSH'
  
  s.ios.deployment_target = '9.0'
end

