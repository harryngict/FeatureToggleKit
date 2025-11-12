source 'https://cdn.cocoapods.org/'
platform :ios, '15.0'

use_frameworks!
project 'Example.project'
workspace 'Example'

def add_pods(pod_definitions)
  pod_definitions.each do |pod_name, path|
    pod pod_name, :path => path
  end
end

def add_test_pods(test_pod_definitions)
  test_pod_definitions.each do |pod_name, spec|
    pod pod_name, :path => spec[:path], :testspecs => spec[:testspecs]
  end
end

def create_pod_definitions(modules)
  pod_definitions = {}
  test_pod_definitions = {}

  modules.each do |module_name|
    base_podspec = "#{module_name}.podspec"
    imp_podspec = "#{module_name}Imp.podspec"
    mock_podspec = "#{module_name}Mock.podspec"

    pod_definitions[module_name] = base_podspec if File.exist?(base_podspec)
    pod_definitions["#{module_name}Imp"] = imp_podspec if File.exist?(imp_podspec)
    pod_definitions["#{module_name}Mock"] = mock_podspec if File.exist?(mock_podspec)
    
    if File.exist?(imp_podspec)
      test_pod_definitions["#{module_name}Imp"] = { path: imp_podspec, testspecs: ['UnitTests'] }
    end
  end

  [pod_definitions, test_pod_definitions]
end

modules = [ 
  'FeatureToggleKit',
]

pod_definitions, test_pod_definitions = create_pod_definitions(modules)

target 'Example' do
  add_pods(pod_definitions)
end

target 'ExampleTests' do
  inherit! :search_paths
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'

  # Mock pods
  mock_pods = pod_definitions.select { |k, _| k.include?('Mock') }
  add_pods(mock_pods)

  # Test pods
  add_test_pods(test_pod_definitions)
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) && target.product_type == 'com.apple.product-type.bundle'
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
