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

  context 'with helper methods exposed to its views' do
    subject { klass.new.view_context }

    %w(resource resources resource_model resource_name parent_resource).each do |helper|
      it { is_expected.to respond_to helper }
    end
  end

  describe '#resource_name' do
    let!(:controller) { build_controller('DummiesController').new }
    subject { controller.send(:resource_name) }

    context 'for a top-level controller' do
      it { is_expected.to eql 'Dummy' }
    end

    context 'for a namespaced controller' do
      let(:controller) { build_controller('My::Namespaces::DummiesController').new }
      it { is_expected.to eql 'Dummy' }
    end

    context 'for a singular resource controller' do
      let(:controller) { build_controller('DummyController').new }
      it { is_expected.to eql 'Dummy' }
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
