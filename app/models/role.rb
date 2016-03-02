class Role < ActiveRecord::Base
  validates :name,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-zA-Z_]+\z/ }

  has_and_belongs_to_many :users
end
