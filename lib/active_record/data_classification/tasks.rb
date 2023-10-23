# frozen_string_literal: true

require 'rake'
require 'active_record/data_classification'

namespace :data_classification do
  #
  # Table, Field, Type, Security Profile
  #
  desc "Generate a report of all models"
  task report: :environment do
    filename = "../data_classification_report.csv"
    File.write(filename, ActiveRecord::DataClassification::Report.generate)
    puts "Report written to #{filename}"
  end
end
