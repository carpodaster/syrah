require 'rails_helper'

RSpec.describe Syrah::Controller do

  describe '.parent_models' do
    it 'returns an empty list by default' do
      expect(klass.parent_models).to eql []
    end
  end

  describe '.belongs_to' do
    it 'accepts a list and sets parent_models' do
      klass.belongs_to :foo, :bar
      expect(klass.parent_models).to eql [:foo, :bar]
    end
  end

  class ::DummyModel
    attr_accessor :test1, :test2
    def initialize(attributes = {})
      attributes.each do |attr, value|
        self.send(:"#{attr}=", value)
      end
    end
  end

  def klass
    @klass ||= Class.new(ActionController::Base) { include Syrah::Controller }
  end

  class ::DummyParentModel < DummyModel; end

  class DummyModelsController < ActionController::Base
    include Syrah::Controller
  end

  module Nested
    class DummyModelsController < ActionController::Base
      include Syrah::Controller
    end
  end
end
