module Syrah
  module TestHelper

    module Factories

      def build_controller(name: nil, &body)
        body ||= ->() {}
        controller = Class.new(ActionController::Base) do
          attr_reader :params
          include Syrah::Controller

          def initialize(params = {})
            self.params = params
          end

          def params=(params, strong: true)
            @params = strong ? ActionController::Parameters.new(params) : params
          end
        end
        controller.class_exec(&body)
        stub_const name, controller if name
        controller
      end

    end

  end
end
