require 'cocoapods-use-frameworks-dynamic-wrapper/gem_version'

module Pod
  class PodTarget < Target
    def real_should_build
      return @real_should_build if defined? @real_should_build
      accessors = file_accessors.select { |fa| fa.spec.library_specification? }
      source_files = accessors.flat_map(&:source_files)
      source_files -= accessors.flat_map(&:headers)
      @real_should_build = !source_files.empty?
    end

    def should_dynamic_wrapper?
      real_should_build == false && target_definitions.select(&:dynamic_wrapper).length > 0 && file_accessors.flat_map(&:vendored_static_artifacts).length > 0
    end
  end

  class Podfile
    class TargetDefinition
      attr_accessor :dynamic_wrapper
      alias_method :original_use_frameworks!, :use_frameworks!
      def use_frameworks!(option = true)
        case option
        when true, false
          original_use_frameworks! option
        when Hash
          @dynamic_wrapper = option.delete(:dynamic_wrapper) if option[:dynamic_wrapper] && option[:linkage] != :static
          original_use_frameworks!(option.empty? ? true : option)
        end
      end
    end

  end

  class Installer
    class Xcode
      class TargetValidator
        alias_method :original_verify_no_static_framework_transitive_dependencies, :verify_no_static_framework_transitive_dependencies
        def verify_no_static_framework_transitive_dependencies
          aggregate_targets.each do |aggregate_target|
            aggregate_target.user_build_configurations.each_key do |config|
              pod_targets = aggregate_target.pod_targets_for_build_configuration(config)
              built_targets, unbuilt_targets = pod_targets.partition(&:should_build?)
              dynamic_pod_targets = built_targets.select(&:build_as_dynamic?)
              dependencies = dynamic_pod_targets.flat_map(&:dependent_targets).uniq
              depended_upon_targets = unbuilt_targets & dependencies
              wrapper_targets = depended_upon_targets.select(&:should_dynamic_wrapper?)
              dynamic_wrapper_flush(wrapper_targets)
              original_verify_no_static_framework_transitive_dependencies
            end
          end
        end

        def dynamic_wrapper_flush(pod_targets)
          pod_targets.each do |pod_target|
            pod_target.instance_variable_set(:@should_build, true)
            module_name = pod_target.root_spec.attributes_hash['module_name'] || pod_target.root_spec.attributes_hash['name']
            pod_target.root_spec.attributes_hash['module_name'] = module_name + '_dynamic_wrapper_pod'
            pod_target.build_settings.each_value do |setting|
              def setting.requires_objc_linker_flag?; true; end
            end
          end
        end
      end

      class PodsProjectGenerator
        class PodTargetInstaller < TargetInstaller
          alias_method :original_initialize, :initialize
          def initialize(sandbox, project, target, umbrella_header_paths = nil)
            original_initialize(sandbox, project, target, umbrella_header_paths)
            dynamic_wrapper_flush(self ) if target.should_dynamic_wrapper?
          end

          def dynamic_wrapper_flush(pod_target_installer)
            def pod_target_installer.validate_targets_contain_sources(native_targets); end
          end
        end
      end
    end
  end

end
