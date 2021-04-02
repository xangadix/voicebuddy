class Exercise
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :preset, type: Integer
  field :name, type: String
  field :description, type: String
  field :video, type: String
  field :thumb, type: String

  field :afgerond, type: Boolean
  field :num_afgerond, type: Integer
  field :num_totaal, type: Integer

end
