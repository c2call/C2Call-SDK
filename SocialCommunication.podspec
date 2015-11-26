#
# Be sure to run `pod lib lint C2Call-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SocialCommunication"
  s.version          = "1.2.5"
  s.summary          = "C2Call SocialCommunication SDK. VoIP, Video Call, Conferencing and Chat for your App"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
C2Call GmbH has been developing video chat, voice calling and messaging solutions for the computing cloud since 2008.
Our SDK is available for mobile app developers free of charge. By integrating C2Call's technology into their mobile apps, developers can now have their users communicate across multiple apps, on multiple platforms. App users can then use video chat, rich media messaging, group audio and video calls and share location info with other users.
                       DESC

  s.homepage         = "https://www.c2call.com"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Michael Knecht" => "Michael.Knecht@c2call.com" }
  s.source           = { :git => "https://github.com/c2call/C2Call-SDK.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'SocialCommunication' => ['Pod/Assets/*.{wav,aiff,aif,xcdatamodeld,storyboard,xcassets}']
  }

  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'UIKit', 'Security', 'MobileCoreServices', 'QuickLook', 'AssetsLibrary', 'CoreData', 'AdSupport', 'MediaPlayer', 'CoreTelePhony', 'CFNetwork', 'OpenGLES', 'CoreVideo', 'QuartzCore', 'StoreKit', 'MessageUI', 'MapKit', 'CoreLocation', 'iAd', 'SystemConfiguration', 'AddressBook', 'AddressBookUI', 'CoreAudio', 'AudioToolbox', 'AVFoundation', 'CoreFoundation', 'Accounts'
  s.dependency 'SBJson', '~> 4.0.2'
  s.dependency 'AWSCore'
  s.dependency 'AWSS3'
  s.dependency 'FBSDKCoreKit', '~> 4.6.0'
  s.dependency 'FBSDKLoginKit', '~> 4.6.0'
  s.dependency 'Flurry-iOS-SDK/FlurrySDK'
  s.dependency 'Flurry-iOS-SDK/FlurryAds'

  s.preserve_paths = 'Libraries/*.a'
  s.vendored_libraries = 'Libraries/libLibC2Call-SDK.a'
  s.libraries = 'xml2', 'z', 'sqlite3', 'stdc++'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "/usr/include/libxml2",
                 'OTHER_LDFLAGS' => '-read_only_relocs suppress'}
end
