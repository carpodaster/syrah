require 'rails_helper'

RSpec.describe Syrah::Controller do
  let(:controller) { build_controller }

  describe '.parent_models' do
    it 'returns an empty list by default' do
      expect(controller.parent_models).to eql []
    end
  end

  describe '.belongs_to' do
    it 'accepts a list and sets parent_models' do
      controller.belongs_to :foo, :bar
      expect(controller.parent_models).to eql [:foo, :bar]
    end
  end

  context 'with helper methods exposed to its views' do
    subject { controller.new.view_context }

    %w(resource resources resource_model resource_name parent_resource).each do |helper|
      it { is_expected.to respond_to helper }
    end
  end

  describe '#resource_name' do
    shared_examples_for 'extracts name from constant' do |constant, name|
      let!(:controller) { build_controller(constant).new }
      subject { controller.send(:resource_name) }

      context "extracting #{name.inspect} from #{constant.inspect}" do
        it { is_expected.to eql name }
      end
    end

    it_behaves_like 'extracts name from constant', 'DummiesController', 'Dummy'
    it_behaves_like 'extracts name from constant', 'My::Namepace::DummiesController', 'Dummy'
    it_behaves_like 'extracts name from constant', 'DummyController', 'Dummy'
  end

  class ::DummyModel
    attr_accessor :test1, :test2
    def initialize(attributes = {})
      attributes.each do |attr, value|
        self.send(:"#{attr}=", value)
      end
    end
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
