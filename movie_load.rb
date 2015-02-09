#Amauris Ferreira
#amfer17@brandeis.edu
#COSI 105B

#MovieData will load and store given information, while also being able to give out values of similarity and popularity of users and movies
class MovieLoad
  #attr_reader used to avoid using direct instance variables
  attr_reader :users, :movies, :movie_with_ratings, :viewers

  def initialize
    #initialize instance variables
    @users = Hash.new {|hash,key| hash[key] = []}       #users holds user_id as key, and movies watched as values in array
    @movies = Hash.new {|hash,key| hash[key] = []}      #movies holds movie_id as key, and ratings of the movies as values in array
    @viewers = Hash.new {|hash,key| hash[key] = []}     #Hash to array of viewers who saw movie x
    @sim_cache = Hash.new {|hash,key| hash[key] = {}}   #Cache that saves aimilarity values that have already been calculated
    @movie_with_ratings = Hash.new {|h,k| h[k] = {}}    #Hash of hashes that holds every user with their rating for a movie
  end
    #load_data wll load the data of the given file name
  def load_data(file_name)
    #for each loop will read every line in file, and will push values in hashes
    ml_data = open("ml-100k/ml-100k/" + file_name)
    read_lines(ml_data)
  end
  #read_lines helps store the data of the file when reading each line
  def read_lines(file_data)
    file_data.each_line do |data|
      user_id,movie_id, rating, timestamp = data.split.map(&:to_i)
      movies[movie_id].push(rating)
      movie_with_ratings[user_id][movie_id] = rating
      users[user_id].push(movie_id)
      viewers[movie_id].push(user_id)
    end
  end
  #popularity will determine the popularity of a movie based on average user rating, and the total # of times it was watched
  def popularity(movie_id)
    final_rating = 0
    rating_num = movies[movie_id].size
    #for each loop will add all ratings of one given movie
    movies[movie_id].each do |ratings|
      final_rating += ratings
    end
    final_rating /= rating_num.round(2)
    return final_rating + rating_num #will return average rating for a movie to nearest hundredth
  end
  #popularity_list returns a list of all movies sorted by their popularity
  def popularity_list
    movie_ratings = Hash.new
    #for each loop will use algorithm to find the total true value of popularity,
    #putting into account the average rating, and the amount of times it was viewed
    movies.keys.each do |movie_id|
      movie_ratings[movie_id] = popularity(movie_id)
    end
    movie_ratings = Hash[(movie_ratings.sort_by {|hash,key| key}).reverse] #Hash is sorted by the values of popularity
    return movie_ratings
  end
  #similarity will find out how similar 2 users are in movie preference based on the movies they watched(value is out of 100% or 1)
  def similarity(user1, user2)
    if @sim_cache[user1][user2] != nil || @sim_cache[user2][user1] != nil     #method checks to see if value has already been calculated  
      return @sim_cache[user1][user2]                                         #in order to save time
    end
    same_movies = (users[user1] & users[user2]).size
    denom = users[user1].size + users[user2].size
    sim_value = (same_movies / denom.to_f) * 100  #returns the similarity between 2 users out of 100, aka percentage of similarity.
    @sim_cache[user1][user2] = sim_value          #values are added to both indexes of @sim_cache for future reference,  in order to
    @sim_cache[user2][user1] = sim_value          #speeden up the process of Movie_data-2's run_test method
    return sim_value
  end

  def most_similar(user)
    similar_users = Hash.new {|hash,key| hash[key] = []}
    #for each loop will go through every user, and compare them to user u using similarity function
    users.keys.each do |person|
        if user != person then similar_users[person].push(similarity(user, person)) end    #then user is considered in the most similar category
    end
    top_25_perc = (0.25 * similar_users.size).to_i
    similar_users = (similar_users.sort_by {|hash,key| key}).reverse    #top 25 percent of users similar_users list is considered most similar
    most_similar = Array.new
    (0..top_25_perc).each do |num|
      most_similar.push(similar_users[num][0])                          #top 25 percent is pushed into most_similar array
    end
      return most_similar  #returns the hash that contains the most similar users of user u - top 25%
  end
end
