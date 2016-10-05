#
# Be sure to run `pod lib lint C2Call-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "C2Call-SDK"
  s.version          = "1.4.5"
  s.summary          = "C2Call SocialCommunication SDK. VoIP, Video Call, Conferencing and Chat for your App"
#s.module_name      = "C2CallSDK"
  s.header_dir       = "SocialCommunication"

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
  s.documentation_url = "http://sdkdocs.ios.c2call.com"
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = ['Pod/Classes/*', 'Pod/Classes/Categories/*']
  s.resources = 'Pod/Assets/*.{wav,aiff,aif,fsh,xml,vsh,xib,png,xcdatamodeld,storyboard,xcassets}'
#s.resource_bundles = {
#    'SocialCommunication' => ['Pod/Assets/*.{wav,aiff,aif,fsh, xml,vsh,png,xcdatamodeld,storyboard,xcassets}']
#  }

  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'UIKit', 'Security', 'MobileCoreServices', 'QuickLook', 'AssetsLibrary', 'CoreData', 'AdSupport', 'MediaPlayer', 'CoreTelePhony', 'CFNetwork', 'OpenGLES', 'CoreVideo', 'QuartzCore', 'StoreKit', 'MessageUI', 'MapKit', 'CoreLocation', 'iAd', 'SystemConfiguration', 'AddressBook', 'AddressBookUI', 'CoreAudio', 'AudioToolbox', 'AVFoundation', 'CoreFoundation', 'Accounts'
  s.dependency 'SBJson', '~> 4.0'
  s.dependency 'AWSCore', '~> 2.3.5'
  s.dependency 'AWSS3', '~> 2.3.5'
#s.dependency 'FBSDKCoreKit', '~> 4.6'
#s.dependency 'FBSDKLoginKit', '~> 4.6'
  s.dependency 'Flurry-iOS-SDK/FlurrySDK', '~> 7.3'
  s.dependency 'Flurry-iOS-SDK/FlurryAds', '~> 7.3'

  s.preserve_paths = 'Libraries/*.a'
  s.vendored_libraries = 'Libraries/*.a'
  s.libraries = 'xml2', 'z', 'sqlite3', 'stdc++'

  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "/usr/include/libxml2",
                 'OTHER_LDFLAGS' => '-ObjC',
                 'OTHER_LDFLAGS[arch=i386]' => '-read_only_relocs suppress $(OTHER_LDFLAGS)',
                 'OTHER_LDFLAGS[arch=x86_64]' => '-read_only_relocs suppress $(OTHER_LDFLAGS)'}
end
