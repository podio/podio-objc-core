Pod::Spec.new do |s|
  s.name                = 'PodioKitCore'
  s.version             = '1.0'
  s.source              = { :git => 'https://github.com/podio/podio-objc-core.git', :tag => s.version.to_s }

  s.summary             = "PodioKit Core contains code shared between the Podio SDKs."
  s.homepage            = "https://github.com/podio/podio-objc-core"
  s.license             = 'MIT'
  s.authors             = { "Sebastian Rehnby" => "sebastian@podio.com",
                            "Romain Briche" => "briche@podio.com",
                            "Lauge Jepsen" => "lauge@podio.com"}

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc          = true

  s.default_subspec = 'Common'

  s.subspec 'Common' do |sp|
    sp.source_files = 'PodioKitCore/Common/**/*.{h,m}'
    sp.public_header_files = 'PodioKitCore/Common/**/*.h'
    
    sp.ios.source_files = 'PodioKitCore/UIKit/**/*.{h,m}'
    sp.ios.public_header_files = 'PodioKitCore/UIKit/*.h'
    sp.ios.frameworks = 'UIKit'
  end

  s.subspec 'Push' do |sp|
    sp.source_files = 'PodioKitCore/Push/**/*.{h,m}'
    sp.public_header_files = 'PodioKitCore/Push/**/*.h'

    sp.dependency 'PodioKitCore/Common'
    sp.dependency 'DDCometClient',  '~> 1.0'
    sp.dependency 'FXReachability', '~> 1.3'
  end
end
