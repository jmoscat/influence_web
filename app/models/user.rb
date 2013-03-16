class User < ActiveRecord::Base
	def self.create_with_omniauth(auth)
	  create! do |user|
	    user.provider = auth['provider']
	    user.uid = auth['uid']
	    if auth['info']
	      user.name = auth['info']['name'] || ""
	      user.email = auth['info']['email'] || ""
	      user.fb_token = auth['credentials']['token']
	    end
	  end
	end

	def calculate_influence
		graph = Koala::Facebook::API.new(self.fb_token)
		profile = graph.get_object("me")
		self.email = profile["email"]
	  self.name = profile["name"]
    location = profile["location"]
    if location.nil?
      self.location_name = ""
      self.location_id = ""
    else
      self.location_name = location["name"]
	    self.location_id = location["id"]
    end

    if profile["birthday"].nil?
      self.DOB = ""
    else
      self.DOB = Date.strptime(profile["birthday"], '%m/%d/%Y')
    end
    friends = graph.get_connections("me","friends",:fields =>"id").count
    self.friends_count = friends

    likes = User.getWeeklyLikes(graph)
    likes_per_day = likes/7.0
    friends = friends/100.0

    #Get tags
    tags = User.getWeeklyTags(graph)
    tags_per_day = tags/7.0

    weighted_likes = (1- Math.exp(-0.795*likes_per_day))
    weighted_friends = (1- Math.exp(-0.795*friends))
    weighted_tags = (1- Math.exp(-1.35*tags_per_day))

    self.influence = weighted_likes*0.4 + weighted_tags*0.3 + weighted_friends*0.3
   	self.week_likes = likes
   	self.weighted_friend = weighted_friends
   	self.weighted_likes = weighted_likes
   	self.week_tags = tags
   	self.weighted_tags = weighted_tags
    self.save
    
    return (influence*100).round(1)
	end

	def self.getWeeklyLikes(graph)
  	since = (Time.now - 7.days).to_i
  	total_likes = 0
  	feed = graph.fql_query("SELECT post_id ,likes FROM stream WHERE source_id=me() AND created_time >" + since.to_s)
  	feed.each do |x|
  		unless x["likes"]["count"].nil?
  			total_likes += x["likes"]["count"]
  		end
  	end
   	return total_likes
  end

  def self.getWeeklyTags(graph)
    since = (Time.now - 7.days).to_i 
    feed = graph.fql_query("SELECT post_id, actor_id, target_id, message FROM stream WHERE filter_key = 'others' AND source_id = me() AND created_time >" + since.to_s)
    return feed.count
  end








end
