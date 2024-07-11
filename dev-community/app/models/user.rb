class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  PROFILE_TITLE = [
    "Junior Ruby on Rails",
    "Mid Level Ruby on Rails",
    "Senior Ruby on Rails",
    "Software Engineer",
    "QA Engineer",
    "Platform Engineer",
    "Fullstack Ruby on Rails",
    "Frontend Engineer"
  ].freeze

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def self.ransackable_attributes(auth_object = nil)
    ["country", "city"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

end
