
use_frameworks!
platform :ios, '11.0'
source 'https://github.com/CocoaPods/Specs.git'

project './Desk360LiveChat.xcodeproj'

def firebase 
    pod 'Firebase', '8.15.0'
end

target 'Desk360LiveChat' do
    firebase
    pod 'Alamofire', '5.0'
    pod 'PersistenceKit'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'NVActivityIndicatorView'
    pod 'Kingfisher'
    pod 'DiffableDataSources'
    pod 'DifferenceKit/UIKitExtension'
    
    target 'Example' do 
    end
end
