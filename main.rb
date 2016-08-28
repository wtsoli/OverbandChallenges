require 'csv'
require_relative 'lib/spread_to_benchmark'
require_relative 'lib/bond_spread'

$data_file_challenge_1 = "data/raw_data_for_challenge_1.csv"
$data_file_challenge_2 = "data/raw_data_for_challenge_2.csv"

# candidate for looking for the spread to benchmark and to curve
$interested_corporate_id = "1" # This is the corporate C1


spread_to_benchmark = SpeadToBenchmark.new
spread_to_benchmark.read_data_from_file($data_file_challenge_1)
spread_to_best_candidate = spread_to_benchmark.compute_spread_to_benchmark($interested_corporate_id)

# Output section
puts "The best candidate(s) governments and the speak yield for Corporate with id #{$interested_corporate_id}"
puts "#{spread_to_best_candidate}"



spread_to_benchmark = SpeadToBenchmark.new
spread_to_benchmark.read_data_from_file($data_file_challenge_2)
spread_to_curve_1 = spread_to_benchmark.compute_spread_to_curve($interested_corporate_id)

puts "\n\n"
puts "The linear interpolation result for Corporate with id #{$interested_corporate_id}"
puts "#{spread_to_curve_1}"

$interested_corporate_id = "2" # This is the corporate C2
spread_to_benchmark = SpeadToBenchmark.new
spread_to_benchmark.read_data_from_file($data_file_challenge_2)
spread_to_curve_2 = spread_to_benchmark.compute_spread_to_curve($interested_corporate_id)

puts "\n\n"
puts "The linear interpolation result for Corporate with id #{$interested_corporate_id}"
puts "#{spread_to_curve_2}"















# process Challenge #2