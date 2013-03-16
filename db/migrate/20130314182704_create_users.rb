class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :fb_token
      t.string :location_name
      t.string :location_id
      t.string :DOB
      t.string :friends_count
      t.string :weighted_friend
      t.string :week_likes
      t.string :weighted_likes
      t.string :week_tags
      t.string :weighted_tags
      t.string :influence
      t.timestamps
    end
  end
end
