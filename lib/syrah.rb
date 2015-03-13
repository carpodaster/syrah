require "syrah/engine"

module Syrah

  module Controller

    extend ActiveSupport::Concern

    included do
      helper_method :resource, :resources, :resource_model, :resource_name, :parent_resource
    end

    module ClassMethods
      attr_writer :parent_models

      def parent_models
        @parent_models ||= []
      end

      def belongs_to(*parents)
        self.parent_models = parents.map(&:to_sym)
      end
    end

    protected

    def resource_name
      @resource_name ||= self.class.to_s.split('::').last.gsub(/Controller\Z/, '').singularize
    end


  end
end
