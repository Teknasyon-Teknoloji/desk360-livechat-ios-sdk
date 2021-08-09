Pod::Spec.new do |s|
  s.name                      = "LiveChat"
  s.version                   = "1.0.0"
  s.summary                   = "LiveChat"
  s.homepage                  = "https://github.com/Teknasyon-Teknoloji/desk360-livechat-ios-sdk"
  s.license                   = { :type => "Commercial", :file => "LICENSE" }
  s.author                    = { "Teknasyon" => "http://www.teknasyon.com/" }
  s.source                    = { :git => "https://github.com/Teknasyon-Teknoloji/desk360-livechat-ios-sdk.git", :tag => s.version.to_s }
  s.swift_version             = "5.1"
  s.ios.deployment_target     = "11.0"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"

  s.dependency 'Alamofire', '~> 5.0'
  s.dependency 'PersistenceKit'
  s.dependency 'Firebase/Database'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'Kingfisher'

  s.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
  s.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }

  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
}

 s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
 s.static_framework = true
 s.requires_arc = true

 s.ios.resource_bundle = { "Desk360LiveChatAssets" => "Sources/Assets/Desk360LiveChatAssets.bundle/Images" }
 s.resources = "Sources/Assets/Desk360LiveChatAssets.bundle/*.{ttf}"

end
