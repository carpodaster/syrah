require "syrah/engine"

module Syrah

  module Controller

    extend ActiveSupport::Concern

    included do
      helper_method :resource, :resources, :resource_model, :resource_name, :parent_resource, :parent?
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

    def parent_model
      @parent_model ||= parent_resource_name.camelize.constantize if parent?
    end

    def parent_resource_name
      @parent_resource_name ||= self.class.parent_models.detect{|model| params["#{model}_id"].present? }.to_s
    end

    def resource_name
      @resource_name ||= self.class.to_s.split('::').last.gsub(/Controller\Z/, '').singularize
    end

    def parent?
      parent_resource_name.present?
    end

  end
end
