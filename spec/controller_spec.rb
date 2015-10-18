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
      let!(:controller) { build_controller(name: constant).new }
      subject { controller.send(:resource_name) }

      context "extracting #{name.inspect} from #{constant.inspect}" do
        it { is_expected.to eql name }
      end
    end

    it_behaves_like 'extracts name from constant', 'DummiesController', 'Dummy'
    it_behaves_like 'extracts name from constant', 'My::Namepace::DummiesController', 'Dummy'
    it_behaves_like 'extracts name from constant', 'DummyController', 'Dummy'
  end

  describe '#parent_resource_name' do
    subject { controller.new }

    context 'without a belongs_to association set' do
      let(:controller) { build_controller }

      it 'returns nil' do
        expect(controller.new.send(:parent_resource_name)).to be_blank
      end
    end

    context 'with a single belongs_to statement' do
      let(:controller) do
        build_controller { belongs_to :foo_bar }
      end

      it 'returns nil for missing corresponding params key' do
        allow(subject).to receive(:params).and_return({})
        expect(subject.send(:parent_resource_name)).to be_blank
      end

      it 'returns foo for missing corresponding params key' do
        params = { foo_bar_id: 42 }.with_indifferent_access
        allow(subject).to receive(:params).and_return(params)
        expect(subject.send(:parent_resource_name)).to eql 'foo_bar'
      end

    end

    context 'with more than one belongs_to statement' do
      let(:controller) do
        build_controller { belongs_to :hello_world, :foo_bar }
      end

      it 'returns the first matching corresponding params key' do
        params = { foo_bar_id: 42, hello_world_id: 'o hai' }.with_indifferent_access
        allow(subject).to receive(:params).and_return(params)
        expect(subject.send(:parent_resource_name)).to eql 'hello_world'
      end
    end

  end

  describe '#parent?' do
    subject { build_controller.new }

    it 'returns false if parent_resource_name is blank' do
      skip
    end

    it 'returns true if parent_resource_name is present' do
      skip
    end
  end

  describe '#parent_model' do
    skip
  end

  describe '#parent_resource' do
    skip
  end

  describe '#resource_association_name' do
    skip
  end

  describe '#resource_association' do
    skip
  end

  describe '#resources' do
    skip

    # TODO or name it collection?
  end

  describe '#resource_name' do
    skip
  end

  describe '#resource_model' do
    skip
  end

  describe '#resource' do
    skip
  end

  describe '#resource_instance_variable' do
    skip
  end

  describe '#resource_instance_variable_get_or_default' do
    skip
  end

  describe '#build_resource' do
    skip
  end

  describe '#object_params' do
    context 'with strong parameters' do
      skip
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
