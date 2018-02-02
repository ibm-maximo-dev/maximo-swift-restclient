Pod::Spec.new do |spec|
  spec.name = "MaximoRESTSDK"
  spec.version = "1.0.0"
  spec.summary = "Maximo REST SDK API developed in Swift to be used for iOS development."
  spec.homepage = "https://github.ibm.com/maximo-ohio/maximo-swift-restclient"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Silvino Neto" => 'silvv@br.ibm.com' }

  spec.platform = :ios, "11.2"
  spec.ios.deployment_target = '11.2'
  spec.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  spec.frameworks = 'XCTest'
  spec.requires_arc = true
  spec.source = { git: "git@github.ibm.com:maximo-ohio/maximo-swift-restclient.git", tag: "#{spec.version}" }
  spec.source_files = "MaximoRESTSDK/MaximoRESTSDK/*.{h,swift}"

  spec.dependency "Curry", "~> 4.0.0"
  spec.dependency "Quick", "1.2.0"
  spec.dependency "Nimble", "7.0.3"
end
