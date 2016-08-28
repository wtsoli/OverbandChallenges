require_relative '../lib/spread_to_benchmark'

describe SpeadToBenchmark do
	describe "read data from existing csv file" do

	      	test_data_file_1 = "spec/test_data_file_1.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	gov_bonds_arr = spread_to_benchmark.gov_bonds_arr
	      	corp_bonds_hash = spread_to_benchmark.corp_bonds_hash

	      	
	      	describe gov_bonds_arr do
	      		it { should satisfy { |s|  s.size == 15 } }
	      	end

	      	describe corp_bonds_hash do
	      		it { should satisfy { |s|  s.size == 10 } }
	      	end
  end

  describe "read data from non existing csv file" do

	      	test_data_file_1 = "spec/test_data_file_x.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	gov_bonds_arr = spread_to_benchmark.gov_bonds_arr
	      	corp_bonds_hash = spread_to_benchmark.corp_bonds_hash

	      	
	      	describe gov_bonds_arr do
	      		it { should satisfy { |s|  s.empty? } }
	      	end

	      	describe corp_bonds_hash do
	      		it { should satisfy { |s|  s.empty? } }
	      	end
  end

  describe "compute spread to benchmark for challenge 1 data" do

	      	test_data_file_1 = "spec/raw_data_for_challenge_1.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_benchmark("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.governments.empty?)
	      			conds << (s.governments.size == 1)
	      			conds << (s.governments[0][:term] == "9.4 years")
	      			conds << (s.spread_to_benchmark == "1.60%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end

  describe "compute spread to benchmark for challenge 1 data with duplicated best government candidates" do

	      	test_data_file_1 = "spec/raw_data_for_challenge_1_with_duplicates.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_benchmark("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.governments.empty?)
	      			conds << (s.governments.size == 3)
	      			conds << (s.governments[0][:term] == "9.4 years")
	      			conds << (s.governments[1][:term] == "9.4 years")
	      			conds << (s.governments[2][:term] == "9.4 years")
	      			conds << (s.spread_to_benchmark == "1.37%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end

  describe "compute spread to curve for challenge 2 data" do

	      	test_data_file_1 = "spec/raw_data_for_challenge_2.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_curve("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.left_governments.empty?)
	      			conds << (s.left_governments.size == 1)
	      			conds << (s.left_governments[0][:term] == "9.4 years")
	      			conds << (not s.right_governments.empty?)
	      			conds << (s.right_governments.size == 1)
	      			conds << (s.right_governments[0][:term] == "12.0 years")
	      			conds << (s.spread_to_curve == "1.22%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end

  describe "compute spread to curve for challenge 2 data with duplicated left(right) point for linear interpolation" do

	      	test_data_file_1 = "spec/raw_data_for_challenge_2_with_duplicates.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_curve("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.left_governments.empty?)
	      			conds << (s.left_governments.size == 2)
	      			conds << (s.left_governments[0][:term] == "9.4 years")
	      			conds << (s.left_governments[1][:term] == "9.4 years")
	      			conds << (not s.right_governments.empty?)
	      			conds << (s.right_governments.size == 2)
	      			conds << (s.right_governments[0][:term] == "12.0 years")
	      			conds << (s.right_governments[1][:term] == "12.0 years")
	      			conds << (s.spread_to_curve == "1.12%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end

  describe "compute spread to benchmark for my own random generated file" do

	      	test_data_file_1 = "spec/test_data_file_1.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_benchmark("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.governments.empty?)
	      			conds << (s.governments.size == 1)
	      			conds << (s.governments[0][:term] == "9.11 years")
	      			conds << (s.spread_to_benchmark == "-3.90%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end

  describe "compute spread to curve for my own random generated file" do

	      	test_data_file_1 = "spec/test_data_file_1.csv"
	      	spread_to_benchmark = SpeadToBenchmark.new
	      	spread_to_benchmark.read_data_from_file(test_data_file_1)


	      	spread_to_best_candidate = spread_to_benchmark.compute_spread_to_curve("1")

	      	describe spread_to_best_candidate do
	      		it { should satisfy { |s|
	      			conds = []
	      			conds << (s.bond_id == "1")
	      			conds << (s.corporate_name == "C1")
	      			conds << (not s.left_governments.empty?)
	      			conds << (s.left_governments.size == 1)
	      			conds << (s.left_governments[0][:term] == "9.11 years")
	      			conds << (not s.right_governments.empty?)
	      			conds << (s.right_governments.size == 1)
	      			conds << (s.right_governments[0][:term] == "11.27 years")
	      			conds << (s.spread_to_curve == "-4.21%")
	      			conds.all? { |c| c } 
	      			} }
	      	end
  end
end