module Syrah
  module TestHelper

    module Factories

      def build_controller(name: nil, &body)
        body ||= ->() {}
        controller = Class.new(ActionController::Base) do
          include Syrah::Controller
        end
        controller.class_exec(&body)
        stub_const name, controller if name
        controller
      end

    end

  end
end
