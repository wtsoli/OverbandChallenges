require 'csv'
require_relative 'bond_spread'


class SpeadToBenchmark

	attr_accessor :gov_bonds_arr
	attr_accessor :corp_bonds_hash

	def initialize
		@gov_bonds_arr = []
		# to speed up because this one is only used later for search, so hash structure is better than array
		@corp_bonds_hash = {}
	end

	def read_data_from_file(file_path, file_type = "csv")
		if not File.exist?(file_path)
			return nil
		end

		# save the elements bonds_arr into gov_bonds_arr for being more programming friendly
		#gov_bonds_arr = []

		case file_type
		when "csv"
		  	# process Challenge #1
			bonds_arr = CSV.read(file_path)

			local_gov_bonds_arr = bonds_arr.select do |row|
				row[2].eql? "government"
			end

			local_corp_bonds_arr = bonds_arr.select do |row|
				row[2].eql? "corporate"
			end

			# after this loop gov_bonds_arr will be an array of hashes, every hash corresponds a government row 
			local_gov_bonds_arr.each do |row|
				# row here would be ["1", "C1", "corporate", "9.31 years", "2.14%"]
				# remove ' years' part from row[3] and the '%' from row[4] anc convert them into num type
				term = row[3].scan(/^\d*\.\d*|\d+/).first.to_f

				yield_ = row[4].scan(/^\d*\.\d*|\d+/).first.to_f

				# Here we just use hash instead of a user defined class is because I think hash in ruby is more efficient
				# than the user defined class, and the the row data here is just one dimension hence fittable to hash
				@gov_bonds_arr << { :id => row[0], :bond => row[1], :type => row[2], :term => term, :yield => yield_}
			end
			@gov_bonds_arr = @gov_bonds_arr.sort_by { |hsh| hsh[:term] }

			# after this loop gov_bonds_arr will be an array of hashes, every hash corresponds a government row 
			local_corp_bonds_arr.each do |row|
				# row here would be ["1", "C1", "corporate", "9.31 years", "2.14%"]
				# remove ' years' part from row[3] and the '%' from row[4] anc convert them into num type
				term = row[3].scan(/^\d*\.\d*|\d+/).first.to_f

				yield_ = row[4].scan(/^\d*\.\d*|\d+/).first.to_f

				# Here we just use hash instead of a user defined class is because I think hash in ruby is more efficient
				# than the user defined class, and the the row data here is just one dimension hence fittable to hash
				raise "there should not be any duplicates for corporates" if corp_bonds_hash.has_key?(row[0])
				@corp_bonds_hash[row[0]] = { :id => row[0], :bond => row[1], :type => row[2], :term => term, :yield => yield_}
			end
		else
		  raise "do not supporting file type: #{file_type} for #{file_path}"
		end

	end

	def compute_spread_to_benchmark(corporate_id)
		# fail fast
		return nil if corporate_id.nil? || corporate_id.strip.empty?

		# puts @gov_bonds_arr
		# puts @corp_bonds_hash

		raise "corporate id not found!" if not @corp_bonds_hash.has_key?(corporate_id)

		# fail fast
		return nil if @gov_bonds_arr.empty?

		# find the best candidate for a benchmark for corporate with id corporate_id
		gov = @gov_bonds_arr.min_by { |g| (g[:term] - @corp_bonds_hash[corporate_id][:term]).abs }

		# further process to if there are other goverments with the same term as the best candidates
		# in short could be more than one best candidate gov

		govs = @gov_bonds_arr.select do |g|
			near_enought?(g[:term], gov[:term])
		end

		return compute_spread_to_benchmark_(govs, corporate_id)

	end

	def compute_spread_to_curve(corporate_id)
		# fail fast
		return nil if corporate_id.nil? || corporate_id.strip.empty?

		# puts @gov_bonds_arr
		# puts @corp_bonds_hash

		raise "corporate id not found!" if not @corp_bonds_hash.has_key?(corporate_id)

		# fail fast
		return nil if @gov_bonds_arr.empty?

		corporate_term = @corp_bonds_hash[corporate_id][:term]
		unless corporate_term >= @gov_bonds_arr.first[:term] and corporate_term <= @gov_bonds_arr.last[:term]
			raise "we need #{corporate_term} value from corporate can be sandwiched by #{@gov_bonds_arr} "
		end

		# get all governments who have the same "term" as the corporate
		govs = @gov_bonds_arr.select do |g|
			near_enought?(g[:term], corporate_term)
		end

		# if found any government with exactly the same term as the corporate under consideration
		# then go with the way in Challenge 1 to deal with it, since linear interpolation
		# does NOT make sense here
		unless govs.empty?
			return compute_spread_to_benchmark_(govs, corporate_id)
		end

		# must be found here since "corporate_term" will be sandwiched by the array.
		# and first_index_greater_than_corporate_term can not be 0 by the sandwich rule
		first_index_greater_than_corporate_term = @gov_bonds_arr.index { |g| g[:term] > corporate_term }

		# since first_index_greater_than_corporate_term > 1, so
		# last_index_less_than_corporate_term >= 0
		last_index_less_than_corporate_term = first_index_greater_than_corporate_term - 1

		left_sentinel = last_index_less_than_corporate_term
		right_sentinel = first_index_greater_than_corporate_term

		# back tracking all the governments with the same "term" as the government
		# with the index last_index_less_than_corporate_term
		(0...last_index_less_than_corporate_term).reverse_each do |i|
			left_sentinel = i if near_enought?(gov_bonds_arr[last_index_less_than_corporate_term][:term], gov_bonds_arr[i][:term])
		end

		# forwward tracking all the governments with the same "term" as the government
		# with the index first_index_greater_than_corporate_term
		(first_index_greater_than_corporate_term+1 ... @gov_bonds_arr.size).each do |i|
			right_sentinel = i if near_enought?(gov_bonds_arr[first_index_greater_than_corporate_term][:term], gov_bonds_arr[i][:term])
		end

		govs_less = @gov_bonds_arr[left_sentinel .. last_index_less_than_corporate_term]
		govs_greater = @gov_bonds_arr[first_index_greater_than_corporate_term .. right_sentinel]

		return compute_spread_to_curve_(govs_less, govs_greater, corporate_id)


	end




	private

	# if govs contains more than one government(this actually exceed the requirements of the chanllenge)
	# But I still think this could be valid in real production, so we need to process it
	# if only one best candidate government, then it is the same scenario in the chanllenge 1 and will produce the same reult
	# if not, we choose the average 'yield' value among these governments for the G.yield
	# TODO: maybe average is not the most proper method, we could choose the max one or min one for G.yield or other 
	# more complicated methods to decide the G.yield when there are more than one best candicates
	def compute_spread_to_benchmark_(govs, corporate_id)
		gov_yields = (govs.map{ |g| g[:yield]})
		average = gov_yields.reduce(:+) / gov_yields.size

		bond_spread_to_benchmark = BondSpread::SpreadToBenchmark.new
		bond_spread_to_benchmark.bond_id = corporate_id
		bond_spread_to_benchmark.corporate_name = @corp_bonds_hash[corporate_id][:bond]

		# get back to normal for displaying for exporting
		bond_spread_to_benchmark.governments = govs.map { |gov|
			gov_ = gov.clone
			gov_[:term] = "%s years" % gov[:term]
			gov_[:yield] = "%s%" % gov[:yield]
			gov_
		}
		yield_ = (@corp_bonds_hash[corporate_id][:yield] - average).round(2)
		bond_spread_to_benchmark.spread_to_benchmark = "%0.02f%" % yield_
		return bond_spread_to_benchmark

	end


	# if any govs_less or govs_greater or both contain more than one government
	# (this actually exceed the requirements of the chanllenge)
	# But I still think this could be valid in real production, so we need to process it
	# if only one best candidate government, then it is the same scenario in the chanllenge 2 and will produce the same reult
	# if not, we choose the average 'yield' value among these governments(among govs_less or among govs_greater seperately)
	# for the G.yield
	# TODO: maybe average is not the most proper method, we could choose the max one or min one for G.yield or other 
	# more complicated methods to decide the G.yield when there are more than one best candicates
	def compute_spread_to_curve_(govs_less, govs_greater, corporate_id)

		gov_less_yields = (govs_less.map{ |g| g[:yield]})
		average_less = gov_less_yields.reduce(:+) / gov_less_yields.size

		gov_greater_yields = (govs_greater.map{ |g| g[:yield]})
		average_greater = gov_greater_yields.reduce(:+) / gov_greater_yields.size

		bond_spread_to_curve = BondSpread::SpreadToCurve.new
		bond_spread_to_curve.bond_id = corporate_id
		bond_spread_to_curve.corporate_name = @corp_bonds_hash[corporate_id][:bond]

		# gradient of the linear line linked by the nearst two points
		k = (average_greater - average_less) / (govs_greater[0][:term] - govs_less[0][:term])

		# calculate the value from linear interpolation
		gov_yield_ = k * (@corp_bonds_hash[corporate_id][:term] - govs_less[0][:term]) + average_less

		yield_ = (@corp_bonds_hash[corporate_id][:yield] - gov_yield_).round(2)

		bond_spread_to_curve.spread_to_curve =  "%0.02f%" % yield_

		# get back to normal for displaying for exporting
		bond_spread_to_curve.left_governments = govs_less.map { |gov|
			gov_ = gov.clone
			gov_[:term] = "%s years" % gov[:term]
			gov_[:yield] = "%s%" % gov[:yield]
			gov_
		}

		bond_spread_to_curve.right_governments = govs_greater.map { |gov|
			gov_ = gov.clone
			gov_[:term] = "%s years" % gov[:term]
			gov_[:yield] = "%s%" % gov[:yield]
			gov_
		}

		return bond_spread_to_curve

	end


	# safe way for equality between two Floats
	# can be tuned using parameter delta to control precision
	def near_enought?(float1, float2, delta= 0.001)
		return false if float1.nil? || float2.nil?

		return (float1 - float2).abs <= delta
	end


end