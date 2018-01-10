Pod::Spec.new do |spec|
  spec.name = "MaximoRESTClient"
  spec.version = "1.0.0"
  spec.summary = "Maximo REST Client API developed in Swift to be used for iOS development."
  spec.homepage = "https://github.ibm.com/silvv/maximo-swift-restclient"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Silvino Neto" => 'silvv@br.ibm.com' }

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.ibm.com/silvv/maximo-swift-restclient.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "MaximoRESTClient/**/*.{h,swift}"

  spec.dependency "Curry", "~> 4.0.0"
end
