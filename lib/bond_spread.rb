module BondSpread
	class SpreadToBenchmark
		attr_accessor :bond_id
		attr_accessor :corporate_name
		attr_accessor :governments # in case more than one government have the same nearest term as the corporate
		attr_accessor :spread_to_benchmark

		def initialize
			@bond_id = nil
			@corporate_name = nil
			@governments = []
			@spread_to_benchmark = nil
		end

		def to_s
			return %Q{
			corporate id: #{@bond_id}
			corporate name: #{@corporate_name}
			best candidate(s): #{@governments}
			yield spread (return) between a corporate and best candidate: #{@spread_to_benchmark}
			}
		end
	end


	class SpreadToCurve
		attr_accessor :bond_id
		attr_accessor :corporate_name
		attr_accessor :left_governments
		attr_accessor :right_governments
		attr_accessor :spread_to_curve

		def initialize
			@bond_id = nil
			@corporate_name = nil
			@left_governments = []
			@right_governments = []
			@spread_to_curve = nil
		end

		def to_s
			return %Q{
			corporate id: #{@bond_id}
			corporate name: #{@corporate_name}
			left point for linear interpolation: #{@left_governments}
			right point for linear interpolation: #{@right_governments}
			yield spread to the government bond curve: #{@spread_to_curve}
			}
		end
	end
end