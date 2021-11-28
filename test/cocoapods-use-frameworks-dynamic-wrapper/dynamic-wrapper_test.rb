require 'test/unit'
require 'cocoapods'
require 'cocoapods_plugin'

class TestTargetDefinition < Test::Unit::TestCase
  def setup
    @app = Pod::Podfile::TargetDefinition.new('MyApp', nil)
  end

  def test_dynamic_wrapper_only
    @app.use_frameworks! :dynamic_wrapper => true
    assert_equal(@app.dynamic_wrapper, true )
  end

  def test_dynamic_wrapper_linkage_static
    @app.use_frameworks! :linkage => :static, :dynamic_wrapper => true
    assert_nil(@app.dynamic_wrapper)
  end

  def test_dynamic_wrapper_linkage_dynamic
    @app.use_frameworks! :linkage => :dynamic, :dynamic_wrapper => true
    assert_equal(@app.dynamic_wrapper, true)
  end
end

class TestTargetValidator < Test::Unit::TestCase
  def setup
    app = Pod::Podfile::TargetDefinition.new('MyApp', nil)
    spec_a = Pod::Specification.new(nil, 'ModuleA')
    pod_target_a = Pod::PodTarget.new(nil, nil, {'Debug' => :debug}, nil, nil, [spec_a], [app])
    spec_b = Pod::Specification.new(nil, 'ModuleB')
    pod_target_b = Pod::PodTarget.new(nil, nil, {'Debug' => :debug}, nil, nil, [spec_b], [app])
    @pod_targets = [pod_target_a, pod_target_b]
    @target_validator = Pod::Installer::Xcode::TargetValidator.new(nil, nil, nil)
  end
  def test_dynamic_wrapper_flush
    @target_validator.dynamic_wrapper_flush(@pod_targets)
    @pod_targets.each do |pod_target|
      assert_equal(pod_target.should_build?, true)
      name = pod_target.root_spec.attributes_hash['name']
      module_name = pod_target.root_spec.attributes_hash['module_name']
      assert_equal(module_name, name + '_dynamic_wrapper_pod')
      pod_target.build_settings.each_value do |setting|
        assert_equal(setting.requires_objc_linker_flag?, true )
      end
    end
  end
end
