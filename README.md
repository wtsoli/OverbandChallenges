About the solutions for web challenge from Overbond:

1. Environment setup:

   1.1 
       $ gem install bundler

   1.2 Specify your dependencies in a Gemfile in the project’s root:
       FYI: the Gemfile in the roor directory of this project

   1.3 
       $ bundle install --path .bundle

2. Prepare the data and running the main.rb consuming the data generated:
   2.1 
       $ ruby generate_data.rb
       to generate the csv data set in csv file under data, every time running this will overwrite the original csv file if existing, copy the original file if needed before running this script. now this random data is mainly used for RSpec unit tests

   2.2 
       $ ruby main.rb
       to generate the results for challenge 1 and 2, you do not need 2.1 for this
   2.3
       The results for the Challenge 1&2 can be found in rspec_and_main_running_result.jpg

3. All the test cases are written by RSpec

   3.1 $ bundle exec rspec   # to run the rspec test cases

4. About duplicated best candidates in Challenge 1 and duplicated left(right) point selection for performing linear interpolation in Challenge 2

   4.1 Ex., the data set is like this below and we are trying to find the best candidate:

   id, bond, type,        term,         yield
   1,  C1,   corporate,   10.3 years,   5.30%
   11, G1,   government,  9.4 years,    3.70%
   12, G2,   government,  12 years,     4.80%
   13, G3,   government,  9.4 years,    4.20%
   14, G4,   government,  9.4 years,    3.90%

   It is noticed that here we have G1, G3 and G4 all having the SAME nearest term value as C1, so in my solution, I chose the "arithmetic mea" of the 3 yield(s) 3.70% for G1, 4.20% for G3 and 3.90% for G4 to let the 3.93% (= (3.70%+4.20%+3.90%)/3 ) be the new referential government yield(best candidate) as GX, and hence the pread_to_benchmark for C1 is C1.yield - GX.yield = 1.37%


   4.2 Ex., the data set is like this below and we are performing the linear interpolation:

   id, bond, type,        term,         yield
   1,  C1,   corporate,   10.3 years,   5.30%
   2,  C2,   corporate,   15.2 years,   8.30%
   11, G1,   government,  9.4 years,    3.70%
   12, G2,   government,  12 years,     4.80%
   13, G3,   government,  16.3 years,   5.50%
   14, G4,   government,  9.4 years,    3.90%
   15, G5,   government,  12 years,     5.00%

   Here we have G1 and G4 as the left point for linear interpolation since G1 has the same term as G4 which is nearst from C1's term 10.3 from the left side, and the same situation happens with G2 and G5 from the right side. So we here create two new 'non-existing' government bond, G_Left with term 9.4 years, but yield as (3.70% + 3.90%)/2 = 3.80%, and G_Right with term 12 years, but yield as (4.80%+5.00%)/2 = 4.90%.

   with all this above we can use G_Left(9.4 years,  3.80%) as the new left point and G_Right(12 years,  4.90%) as the new right point to perform the linear interpolation. And it can be calculated as this fomula:

   gradient of the line: (4.90% - 3.80%) / (12 - 9.4) = Line_grad, so the "spread to curve" of C1 is:

   C1.yield - Line_grad * (10.3 - 9.4) + 3.8




   4.3 Notes:

   I put the duplicated examples like in 4.1 and 4.2 into the RSpec unit test, but the main.rb only care about the problem showed on the Challenge website.

   However when there are no duplicates like in 4.1 or 4.2, then the computation result would be the same as the results demonstrated on the Challenge website: https://gist.github.com/apotapov/3118c573df2a4ac7a93f00cf39ea620a