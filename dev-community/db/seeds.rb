# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all
ActiveRecord::Base.transaction do
  100.times do  |i|
    user = User.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      username: "#{Faker::Name.first_name}-#{i+5}",
      profile_title: User::PROFILE_TITLE.sample,
      email: Faker::Internet.email,
      password: "password",
      date_of_birth:(Date.today + rand(1..30).days) - rand(24..35).years,
      country: Faker::Address.country,
      state: Faker::Address.state,
      city: Faker::Address.city,
      contact_number: Faker::PhoneNumber.phone_number_with_country_code,
      about:"As a seasoned Full Stack Software Engineer, I bring a wealth of expertise in designing and implementing robust, scalable applications. Proficient in both front-end and back-end technologies, I excel in creating seamless user experiences and efficient server-side solutions. My skill set includes JavaScript, React, Ruby on Rails, Node.js, and database management with SQL and NoSQL. With a passion for continuous learning and staying abreast of industry trends, I thrive in collaborative environments and enjoy tackling complex problems. My commitment to code quality and best practices ensures the delivery of high-performing, maintainable software solutions."

    )
    puts "User #{i+1} created !"
  end
end
