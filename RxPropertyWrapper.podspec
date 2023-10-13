Pod::Spec.new do |s|
    s.name                  = "RxPropertyWrapper"
    s.version               = "0.0.9"
    s.summary               = "RxSwift PropertyWrapper"
    s.homepage              = "https://github.com/jiasongs/RxPropertyWrapper"
    s.license               = "MIT"
    s.author                = { "ruanmei" => "jiasong@ruanmei.com" }
    s.source                = { :git => "https://github.com/jiasongs/RxPropertyWrapper.git", :tag => "#{s.version}" }
    s.platform              = :ios, "13.0"
    s.cocoapods_version     = ">= 1.11.0"
    s.swift_versions        = ["5.0"]
    s.static_framework      = true
    s.requires_arc          = true
    s.source_files          = "Sources"
    
    # Core dependency
    s.dependency "RxSwift",  "~> 6.6.0"
    s.dependency "RxRelay",  "~> 6.6.0"
end