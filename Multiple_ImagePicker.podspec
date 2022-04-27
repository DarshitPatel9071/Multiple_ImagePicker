Pod::Spec.new do |spec|

  spec.name         = "Multiple_ImagePicker"
  spec.version      = "1.0.0"
  spec.summary      = "Selete any image from gallery and capture image with camera"
  spec.description  = <<-DESC
                    This pod helps you in Select any image from gallery and capture image with camera
                   DESC
  spec.homepage     = "https://github.com/DarshitPatel9071/Multiple_ImagePicker"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Darshit Patel" => "" }
  spec.source       = { :git => "https://github.com/DarshitPatel9071/Multiple_ImagePicker.git", :tag => "#{spec.version}"}
  spec.source_files  = 'MultipleImagePicker/**/*.{swift}'
  spec.ios.deployment_target = '14.0'
  spec.swift_versions = "5.0"
  spec.dependency 'MBProgressHUD'
  spec.static_framework = true
end
