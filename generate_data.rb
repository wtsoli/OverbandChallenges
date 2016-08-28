require 'csv'

prng = Random.new

# should not be overflow, but in real env could be. Anyway, here we just need this for generating some dummy id(s)
$global_id_tracking = 1

$no_of_corporates = 10
$no_of_governments = 15

$term_range = (5.0..20.0)  # imagined by me :)
$yield_range = (0.0..9.6)  # imagined by me :)


corporates = []
governments = []

$data_file_challenge_1 = "raw_data_for_challenge_1.csv"
$data_file_challenge_2 = "raw_data_for_challenge_2.csv"

[$data_file_challenge_1, $data_file_challenge_2].each do |data_file|

	# generate $no_of_corporates corporates
	(1..$no_of_corporates).each_with_index do |n, i|
		id = $global_id_tracking
		bond = "C#{(i+1)}" # because 0 based array for ruby
		type = "corporate"
		term = "%s years" % prng.rand($term_range).round(2)
		yield_ = "%s%" % prng.rand($yield_range).round(2)

		corporates << { :id => id, :bond => bond, :type => type, :term => term, :yield => yield_}

		$global_id_tracking += 1
	end

	# generate $no_of_governments governments
	(1..$no_of_governments).each_with_index do |n, i|
		id = $global_id_tracking
		bond = "G#{(i+1)}" # because 0 based array for ruby
		type = "government"
		term = "%s years" % prng.rand($term_range).round(2)
		yield_ = "%s%" % prng.rand($yield_range).round(2)
		governments << { :id => id, :bond => bond, :type => type, :term => term, :yield => yield_}
		$global_id_tracking += 1
	end

	# csv file format:
	# id	bond	type	term	yield
	# 1		C1	corporate	10.3 years	5.30%
	# 2		G1	government	9.4 years	3.70%
	# 3		G2	government	12 years	4.80%
	CSV.open("data/#{data_file}", "wb") do |csv|

		# fill the corporates data
		corporates.each do |corp|
			csv << [corp[:id], corp[:bond], corp[:type], corp[:term], corp[:yield]]
		end

		# fill the governments data
		governments.each do |gov|
			csv << [gov[:id], gov[:bond], gov[:type], gov[:term], gov[:yield]]
		end

	end

	# EMPTY both lists
	corporates = []
	governments = []
	$global_id_tracking = 1 # reset the id tracking from 1 again

end

