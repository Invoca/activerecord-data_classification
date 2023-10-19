# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveRecord::DataClassification::ModelAnnotation do
  subject(:model) { Class.new { include ActiveRecord::DataClassification::ModelAnnotation } }

  describe '.data_security' do
    subject { model.data_security(data_classification) }

    before { model.data_security(:Private) }

    context 'when no type is specified' do
      let(:data_classification) { nil }

      it { is_expected.to eq(:Private) }
      it { expect { subject }.to_not change(model, :_data_security_type) }
    end

    context 'when an invalid type is specified' do
      let(:data_classification) { :Invalid }

      it { expect { subject }.to raise_error(ArgumentError, "Unknown classification type #{data_classification}") }
    end

    context 'when a valid type is specified' do
      let(:data_classification) { :Confidential }

      it { is_expected.to eq(:Confidential) }
      it { expect { subject }.to change(model, :_data_security_type).from(:Private).to(:Confidential) }
    end
  end

  describe '.confidential?' do
    subject { model.confidential? }

    context 'when the data security type is not set' do
      it { is_expected.to be_falsey }
    end

    context 'when the data security type is :Confidential' do
      before { model.data_security(:Confidential) }

      it { is_expected.to be_truthy }
    end

    context 'when the data security type is not :Confidential' do
      before { model.data_security(:Private) }

      it { is_expected.to be_falsey }
    end
  end
end
