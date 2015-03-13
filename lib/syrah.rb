require "syrah/engine"

module Syrah

  module Controller

    extend ActiveSupport::Concern

    module ClassMethods
      attr_writer :parent_models

      def parent_models
        @parent_models ||= []
      end

      def belongs_to(*parents)
        self.parent_models = parents.map(&:to_sym)
      end
    end

  end
end
