module Her
  module Model
    module Associations
      class AssociationProxy < ActiveSupport::BasicObject

        # @private
        def self.install_proxy_methods(on_module, target_name, *names)
          names.each do |name|
            on_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{name}(*args, &block)
                #{target_name}.#{name}(*args, &block)
              end
            RUBY
          end
        end

        install_proxy_methods self, :association,
          :build, :create, :where, :find, :all, :assign_nested_attributes

        # @private
        def initialize(association)
          @_her_association = association
        end

        def association
          @_her_association
        end

        # @private
        def method_missing(name, *args, &block)
          # avoid redefining object_id
          if :object_id == name
            return association.fetch.object_id
          end

          # create a proxy to the fetched object's method
          metaclass = (class << self; self; end)
          AssociationProxy.install_proxy_methods metaclass, 'association.fetch', name

          # resend to the message
          __send__(name, *args, &block)
        end

      end
    end
  end
end
