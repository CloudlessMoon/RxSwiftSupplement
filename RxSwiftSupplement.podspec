Pod::Spec.new do |s|
    s.name                  = "RxSwiftSupplement"
    s.version               = "1.0.2"
    s.summary               = "RxSwift Supplement"
    s.homepage              = "https://github.com/jiasongs/RxSwiftSupplement"
    s.license               = "MIT"
    s.author                = { "ruanmei" => "jiasong@ruanmei.com" }
    s.source                = { :git => "https://github.com/jiasongs/RxSwiftSupplement.git", :tag => "#{s.version}" }
    s.platform              = :ios, "13.0"
    s.swift_versions        = ["5.1"]
    s.requires_arc          = true
    
    # Core dependency
    s.dependency "ThreadSafe", "~> 1.0"
    s.dependency "RxSwift",  "~> 6.0"
    s.dependency "RxRelay",  "~> 6.0"

    s.subspec "Core" do |ss|
        ss.source_files = "Sources/Core/**/*.{swift}"
    end

    s.subspec "PropertyWrapper" do |ss|
        ss.source_files = "Sources/PropertyWrapper/**/*.{swift}"
        ss.dependency "RxSwiftSupplement/Core"
    end

    s.subspec "DisposeBag" do |ss|
        ss.source_files = "Sources/DisposeBag/**/*.{swift}"
        ss.dependency "RxSwiftSupplement/Core"
    end
end