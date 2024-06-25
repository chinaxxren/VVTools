
Pod::Spec.new do |s|
  s.name         = "VVTools"
  s.version = "0.0.1"
  s.summary      = "一个应用调试工具箱"
  s.homepage     = "https://github.com/chinaxxren/VVTools"
  s.license      = "MIT"
  s.author       = { "" => "jiangmingz@qq.com" }
  s.platform     = :ios, "13.0"
  s.swift_version = "5.0"
  s.source       = { :git => "https://github.com/chinaxxren/VVTools", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.source_files  = "Sources", "VVTools/**/*"
  s.resource = 'VVTools/Resources/Resource.bundle'
  s.requires_arc = true
  #s.dependency 'BSBacktraceLogger'
end
