require 'bacon'
require 'cocoapods'
require 'cocoapods_plugin'

module CocoapodsUseFrameworksDynamicWrapper
  describe :TestTargetDefinition  do

    def generateApp
      Pod::Podfile::TargetDefinition.new('MyApp', nil)
    end

    it 'dynamic wrapper is true' do
      app = generateApp()
      app.use_frameworks! :dynamic_wrapper => true
      app.dynamic_wrapper.should.true?
    end

    it 'dynamic wrapper is true and linkage static' do
      app = generateApp()
      app.use_frameworks! :linkage => :static, :dynamic_wrapper => true
      app.dynamic_wrapper.should.nil?
    end

    it 'dynamic wrapper is true and linkage dynamic' do
      app = generateApp()
      app.use_frameworks! :linkage => :dynamic, :dynamic_wrapper => true
      app.dynamic_wrapper.should.true?
    end
  end

  describe :TestTargetValidator do
    def gen_pod_targets
      app = Pod::Podfile::TargetDefinition.new('MyApp', nil)
      spec_a = Pod::Specification.new(nil, 'ModuleA')
      pod_target_a = Pod::PodTarget.new(nil, nil, {'Debug' => :debug}, nil, nil, [spec_a], [app])
      spec_b = Pod::Specification.new(nil, 'ModuleB')
      pod_target_b = Pod::PodTarget.new(nil, nil, {'Debug' => :debug}, nil, nil, [spec_b], [app])
      [pod_target_a, pod_target_b]
    end

    def gen_target_validator
      Pod::Installer::Xcode::TargetValidator.new(nil, nil, nil)
    end

    it 'dynamic wrapper flush module name and link flag' do
      pod_targets = gen_pod_targets
      target_validator = gen_target_validator
      target_validator.dynamic_wrapper_flush(pod_targets)
      pod_targets.each do |pod_target|
        pod_target.should_build?.should.true?

        name = pod_target.root_spec.attributes_hash['name']
        module_name = pod_target.root_spec.attributes_hash['module_name']

        module_name.should == name + '_dynamic_wrapper_pod'

        pod_target.build_settings.each_value do |setting|
          setting.requires_objc_linker_flag?.should.true?
        end
      end
    end
  end
  
  describe :CocoapodsUseFrameworksDynamicWrapper do

    def simple_example_root
      Pathname.new(File.expand_path('../env/simpleExample', __FILE__))
    end

    def exec_pod_install
      is_success = false
      Dir.chdir(simple_example_root) do
        is_success = system('bundle exec pod install >/dev/null 2>&1')
      end
      is_success
    end

    def write_podfile(content)
      podfile = simple_example_root + 'Podfile'
      podfile.write(content)
    end

    before do
      write_podfile <<EOF
target 'simpleExample' do
  # Comment the next line if you don't want to use dynamic frameworks
  
  target 'simpleExampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'simpleExampleUITests' do
    # Pods for testing
  end
end
EOF
      exec_pod_install
    end

    it 'raise static framework transitive dependencies' do
      write_podfile <<EOF
target 'simpleExample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  project 'simpleExample.xcodeproj'
  
  pod 'AppleDY', :path => './Modules/AppleDY/AppleDY.podspec', :inhibit_warnings => true
  pod 'Apple', :path => './Modules/Apple/Apple.podspec'

  pod 'AFNetworking'
  # Pods for simpleExample

  target 'simpleExampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'simpleExampleUITests' do
    # Pods for testing
  end

end
EOF

      exec_pod_install.should.false?
    end

    it 'fix static framework transitive dependencies' do
      write_podfile <<EOF
plugin 'cocoapods-use-frameworks-dynamic-wrapper'

target 'simpleExample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :dynamic_wrapper => true

  project 'simpleExample.xcodeproj'

  pod 'AppleDY', :path => './Modules/AppleDY/AppleDY.podspec', :inhibit_warnings => true
  pod 'Apple', :path => './Modules/Apple/Apple.podspec'

  pod 'AFNetworking'
  # Pods for simpleExample

  target 'simpleExampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'simpleExampleUITests' do
    # Pods for testing
  end

end
EOF
      exec_pod_install.should.true?
    end
  end

end

