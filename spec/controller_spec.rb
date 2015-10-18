require 'rails_helper'

RSpec.describe Syrah::Controller do
  let(:controller) { build_controller }
  let(:params) { Hash.new }
  subject { controller.new(params) }

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

    %w(resource resources resource_model resource_name parent_resource parent?).each do |helper|
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

      context 'with empty params hash' do
        it 'returns nil for missing corresponding params key' do
          expect(subject.send(:parent_resource_name)).to be_blank
        end
      end

      context 'with corresponding _id key in params hash' do
        let(:params) { { foo_bar_id: 42 }.with_indifferent_access }

        it 'returns the belongs_to reference' do
          expect(subject.send(:parent_resource_name)).to eql 'foo_bar'
        end
      end

    end

    context 'with more than one belongs_to statement' do
      let(:params) { { foo_bar_id: 42, hello_world_id: 'o hai' }.with_indifferent_access }

      let(:controller) do
        build_controller { belongs_to :hello_world, :foo_bar }
      end

      it 'returns the first matching corresponding params key' do
        expect(subject.send(:parent_resource_name)).to eql 'hello_world'
      end
    end

  end

  describe '#parent?' do
    subject { controller.new(params).view_context }

    context 'with no parents defined' do
      let(:controller) { build_controller }
      let(:params) { Hash.new }

      it { is_expected.not_to be_parent }
    end

    context 'with parent defined' do
      let(:controller) do
        build_controller { belongs_to :foobar }
      end

      context 'with corresponding *_id key missing in params hash' do
        let(:params) { Hash.new }
        it { is_expected.not_to be_parent }
      end

      context 'with corresponding *_id key present in params hash' do
        let(:params) { { 'foobar_id' => 42 } }
        it { is_expected.to be_parent }
      end
    end
  end

  describe '#parent_model' do
    subject { controller.new(params).send(:parent_model) }

    context 'without parents defined' do
      let(:controller) { build_controller }
      it { is_expected.to be_nil }
    end

    context 'with parents defined' do
      let(:controller) do
        build_controller { belongs_to :foobar }
      end

      context 'with parent *_id parameter missing in params' do
        it { is_expected.to be_nil }
      end

      context 'with parent *_id parameter present in params' do
        let(:params) { { 'foobar_id' => 42 } }

        context 'without the constant being defined' do
          it 'raises an error' do
            expect { subject }.to raise_error NameError
          end
        end

        context 'with the corresponding constant being defined' do
          before { stub_const 'Foobar', Class.new }
          it { is_expected.to eql Foobar }
        end
      end
    end
  end

  describe '#parent_resource' do
    let(:controller) do
      build_controller(name: 'FoobarsController') { belongs_to :foobar }
    end

    context 'without a parent' do
      it 'will outright fail' do
        expect { subject.send(:parent_resource) }.to raise_error NoMethodError
      end
    end

    context 'with a parent model' do
      let(:id) { 42 }
      let(:params) { { 'foobar_id' => id } }
      let(:parent_model) { double('Someone\'s Parent') }

      before do
        expect(subject).to receive(:parent_model).and_return parent_model
      end

      it 'finds by id parameter' do
        expect(parent_model).to receive(:find).with(id)
        subject.send :parent_resource
      end
    end
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
    subject { controller.new(params).view_context }
    let(:controller) { build_controller name: name }

    shared_examples 'returns "MyExample"' do |msg|
      it [msg, "returns 'MyExample'"].to_sentence do
        expect(subject.resource_name).to eql 'MyExample'
      end
    end

    context 'with a top-level controller' do
      let(:name) { 'MyExamplesController' }
      it_behaves_like 'returns "MyExample"'
    end

    context 'with a namespaced controller' do
      let(:name) { 'Foo::MyExamplesController' }
      it_behaves_like 'returns "MyExample"', 'removes the namespace'
    end

    context 'with nested namespaces' do
      let(:name) { 'Foo::Bar::MyExamplesController' }
      it_behaves_like 'returns "MyExample"', 'removes all namespaces'
    end
  end

  describe '#resource_model' do
    let(:controller) { build_controller(name: "MyExamplesController") }

    subject { controller.new.send(:resource_model) }

    context 'with an undefined constant' do
      it { expect { subject }.to raise_error NameError }
    end

    context 'with the model being defined' do
      let(:my_model) { Class.new }
      before { stub_const 'MyExample', my_model }

      it { expect(subject).to eql my_model }
    end
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

  describe '#object_parameters' do
    shared_examples_for 'delegates to a convention-based method' do |controller_name, spy_method:|
      let(:controller) { build_controller(name: controller_name) }

      before do
        controller.class_eval "def #{spy_method}; end"
        expect(subject).to receive(spy_method)
      end

      it 'delegates to a guessed *_params method' do
        subject.send :object_parameters
      end
    end

    it_behaves_like 'delegates to a convention-based method', 'FoobarsController',    spy_method: 'foobar'
    it_behaves_like 'delegates to a convention-based method', 'FooBarsController',    spy_method: 'foo_bar'
    it_behaves_like 'delegates to a convention-based method', 'F::BarsController',    spy_method: 'bar'
    it_behaves_like 'delegates to a convention-based method', 'F::B::FoosController', spy_method: 'foo'
  end

end
