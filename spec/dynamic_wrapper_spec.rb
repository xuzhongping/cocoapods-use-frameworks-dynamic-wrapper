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

end

