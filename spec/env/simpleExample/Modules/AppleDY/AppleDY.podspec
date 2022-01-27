Pod::Spec.new do |s|
    s.name         = 'AppleDY'
    s.version      = '0.2.0'
    s.summary      = 'xxx'
    s.homepage     = 'xxxt'
    s.license      = 'MIT'
    s.authors      = 'xxx'
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'xxx', :tag => s.version}
    
    s.source_files = 'AppleDY/AppleDY/**/*.{h,m}'
#    s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '-lObjC' }
    # s.vendored_frameworks = 'Apple.framework'
    s.dependency 'Apple'
end

