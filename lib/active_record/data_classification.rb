# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative "data_classification/version"
require_relative "data_classification/model_annotation"

module ActiveRecord
  module DataClassification
    class Error < StandardError; end
  end
end
