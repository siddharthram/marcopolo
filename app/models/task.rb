class Task < ActiveRecord::Base
  attr_accessible :xim_id
  attr_accessible :output
  belongs_to :user

end
