class Internship < ActiveRecord::Base
	belongs_to :user
	belongs_to :company
	include PgSearch
end
