# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative "data_classification/version"

module ActiveRecord
  module DataClassification
    class Error < StandardError; end
    # Your code goes here...
  end
end
