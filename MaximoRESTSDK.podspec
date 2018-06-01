Pod::Spec.new do |spec|
  spec.name = "MaximoRESTSDK"
  spec.version = "1.0.3"
  spec.summary = "Maximo REST SDK API developed in Swift to be used for iOS development."
  spec.homepage = "https://github.ibm.com/maximo-ohio/maximo-swift-restclient"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Silvino Neto" => 'silvv@br.ibm.com' }

  spec.platform = :ios, "10.3"
  spec.ios.deployment_target = '10.3'
  spec.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  spec.requires_arc = true
  spec.source = { git: "git@github.ibm.com:maximo-ohio/maximo-swift-restclient.git", tag: "#{spec.version}" }
  spec.source_files = "MaximoRESTSDK/MaximoRESTSDK/*.{h,swift}"
end
