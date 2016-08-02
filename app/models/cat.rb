require 'byebug'
# == Schema Information
#
# Table name: cats
#
#  id          :integer          not null, primary key
#  birth_date  :date             not null
#  color       :string           not null
#  name        :string           not null
#  sex         :string(1)        not null
#  description :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Cat < ActiveRecord::Base
  COLORS = ['black', 'brown', 'white', 'grey', 'orange']
  validates :birth_date, :color, :name, :sex, :description, presence: true
  validates_length_of :sex, is: 1
  validates_inclusion_of :color, in: COLORS
  validates_inclusion_of :sex, in: ['M','F']

  def age
    today = Date.today
    d = Date.new(today.year, self.birth_date.month, self.birth_date.day)
    age = d.year - self.birth_date.year - (d > today ? 1 : 0)
  end


end
