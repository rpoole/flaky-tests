require 'csv'

# basic flow here is
# 1. on retry, log the spec as a potential flake
# 2. if we see it fail after all the retries are done (example_failed is
#    called), then its a true failure and we should remove it from flake file
#    if we don't see it fail, leave it in there, since that means it passed on
#    retry and is likely a flake
class FlakyTestFormatter
  RSpec::Core::Formatters.register self, :example_failed

  FLAKED_CSV_FILENAME = 'flaked_specs.csv'.freeze

  def initialize(output)
    @output = output
    File.write(FLAKED_CSV_FILENAME, '')
  end

  def example_failed(notification)
    spec_id = self.class.build_spec_id_from_notification(notification.example)
    self.class.remove_spec_id_from_csv(spec_id)
  end

  # not an rspec default hook
  # this is called from a hook defined byrspec/retry
  def self.example_retried(example)
    spec_id = build_spec_id_from_notification(example)
    append_spec_id_to_csv(spec_id)
  end

  def self.remove_spec_id_from_csv(spec_id)
    csv_data = CSV.read(FLAKED_CSV_FILENAME)
    filtered_data = csv_data.reject { |row| row.first == spec_id }

    # if we didn't remove anything, no need to do anything
    return if csv_data.length == filtered_data.length

    CSV.open(FLAKED_CSV_FILENAME, 'w') { |csv| filtered_data.each { |row| csv << row } }
  end

  def self.append_spec_id_to_csv(spec_id)
    csv_data = CSV.read(FLAKED_CSV_FILENAME)
    return if csv_data.any? { |row| row.first == spec_id }

    CSV.open(FLAKED_CSV_FILENAME, 'a') do |csv|
      csv << [spec_id]
    end
  end

  def self.build_spec_id_from_notification(example)
    example.metadata[:location]
  end
end
