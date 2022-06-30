Pod::Spec.new do |s|
  s.name                      = "Desk360LiveChat"
  s.version                   = "1.0.5"
  s.summary                   = "Desk360 Live Chat provides simplicity and usability in one place. With this feature, you can provide live support to your customers directly within your app just by writing a few lines of code."
  s.homepage                  = "https://github.com/Teknasyon-Teknoloji/desk360-livechat-ios-sdk"
  s.license                   = { :type => "Commercial", :file => "LICENSE" }
  s.author                    = { "Teknasyon" => "http://www.teknasyon.com/" }
  s.source                    = { :git => "https://github.com/Teknasyon-Teknoloji/desk360-livechat-ios-sdk.git", :tag => s.version.to_s }
  s.swift_version             = "5.1"
  s.ios.deployment_target     = "11.0"
  s.source_files              = "Sources/**/*.swift"
  s.frameworks                = "Foundation"

  s.dependency 'Alamofire', '~> 5.0'
  s.dependency 'PersistenceKit'
  s.dependency 'Firebase/Database'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'Kingfisher'

 s.ios.resource_bundle = { "Desk360LiveChatAssets" => "Sources/Assets/Desk360LiveChatAssets.bundle/Images" }
 s.resources = "Sources/Assets/Desk360LiveChatAssets.bundle/*.{ttf}"

end
