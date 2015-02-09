#Amauris Ferreira
#amfer17@brandeis.edu
#COSI 105B

load "movie_load.rb"
#MovieData will contain all of the information of the given data file, and predicts a user rating to a movie
class MovieData

  def initialize(params)
    params.each { |key, value| instance_variable_set "@#{key}", value}      #params value in the case that user omits a value or not
    @test_set = params[:test_set]|| nil                                     
    @more = MovieLoad.new()                                                #MovieLoad required for some methods(Similarity, load_data, etc)
    if @test_set == :u1                        
      @more.load_data("u1.base")
    else
      @more.load_data("u.data")
    end
    @viewers = @more.viewers                                                #Viewers of a movie (Hash of arrays)
    @ratings = @more.movie_with_ratings                                     #Ratings of a movie by a user (Hash of Hashes)
    @movies = @more.users                                                   #Movies watched by given user(Hash of arrays)
  end
  #rating returns rating a user gave to a movie they watched.
  def rating(user, movie)                                                   
    user_rating = @more.movie_with_ratings[user][movie]
    if user_rating == nil then return 0 end
      user_rating
  end
  #movies returns an array of the movies watched by a given user
  def movies(user)
    return movies_watched = @movies[user]
  end
  #viewers returns all of the viewers of a given movie
  def viewers(movie)
    return viewed_by = @viewers[movie]
  end
  #predict predicts the rating of a movie that a user would give if they had not watched that movie
  def predict(user, movie)
    if @viewers[movie].empty? then return 2.5 end                            #Prediction is based off of MovieLoad's similarity and
    similar_users = @more.most_similar(user)                                 #most_similar methods. Thus, because of how demanding the
    sim_rev = watched = 0                                                    #method is, it takes around 6 minutes if going through all
    similar_users.each do |others|                                           #20,000 lines of code in u1.test
      other_ratings =rating(others, movie)
      sim_rev += other_ratings
      if other_ratings >= 1 then watched += 1 end                             #If similar user did not watch the movie, then we do not
    end                                                                       #add that user to the watched variable
    if sim_rev == 0 then return @more.popularity(movie) - @viewers[movie].size end
    sim_rev /= watched.to_f
    return sim_rev.round(2)
  end
  #run_test will create an instance of the MovieTest class
  def run_test(limit)
    if @test_set == nil then return puts "No test data available for this file." end    #will only work if test file is given in addition
    test_set = MovieTest.new(limit, self)                                               #to base file
  end

end
#MovieTest contains information regarding to how accurate the prediction algorithm works
class MovieTest
  def initialize(limit, movie_data)
    @movie_data = movie_data
    @limit = limit
    @test_list = Array.new
    load_test()
  end
  #load_test will load the test file
  def load_test()
    ml_test = open("ml-100k/ml-100k/u1.test")
    count = 0
    (1..@limit).each do |data|
      data = ml_test.readline
      user_id,movie_id, rating, timestamp = data.split.map(&:to_i)
      prediction = @movie_data.predict(user_id,movie_id)
      @test_list.push([user_id, movie_id, rating, prediction])            #user info is added to an array of arrays, in addition to 
    end                                                                   #movie prediction. This will be the array for method to_a
  end
  #mean returns the percent error of the mean
  def mean()
    avg = 0
    @test_list.each do |user|
      actual_rating = user[2]
      avg += (user[3] - actual_rating).abs
    end
    avg /= @limit
    avg.round(2)
  end
  #stddev returns the Standard Deviation of the error
  def stddev()
    predict_avg = self.mean()                
    summ = summ_formula(predict_avg, 2)     #summ_formula calculates the summation
    stand_dev = Math.sqrt(summ).round(2)
  end
  #rms returns the root mean square of the error
  def rms
    sum = 0
    @test_list.each do |user|
      sum += ((user[2] - user[3]) ** 2)
    end
    sum /= @limit
    rms = Math.sqrt(sum)
  end
  #summ_formula returns the summation of the given values, depending on what algorithm it is
  def summ_formula(sec_val, exp)
    sum = 0
    @test_list.each do |user|
      sum += ((user[2] - sec_val) ** exp)
    end
    return sum /= @limit.to_f
  end
  #to_a returns the array of the predictions in the form [user, movie, rating, prediction]
  def to_a
    @test_list
  end
end

test = MovieData.new(:file => "ml-100k", :test_set => :u1)
try = test.run_test(1000)
puts "Mean of the prediction error is #{try.mean()}"
puts "Standard Deviation is #{try.stddev()}"
puts "Root mean square of the error is #{try.rms}"
