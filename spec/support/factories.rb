module Syrah
  module TestHelper

    module Factories

      def build_controller(controller_name = nil, &body)
        body ||= ->() {}
        controller = Class.new(ActionController::Base) do
          include Syrah::Controller
        end
        controller.class_exec(&body)
        stub_const controller_name, controller if controller_name
        controller
      end

    end

  end
end
