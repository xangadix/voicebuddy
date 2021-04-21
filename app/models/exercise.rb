class Exercise
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :preset, type: Integer
  field :name, type: String
  field :description, type: String
  field :video, type: String
  field :thumb, type: String

  # materiaal, type: String
  # tekst, type: String
  # audio, type: String
  # categorie, type: String
  # tags, type: Array
  # oefening, type: String
  # naam, type: String
  # frequentie, type: Number


  # winning much? (test 1)
  #field :afgerond, type: Boolean
  #field :num_afgerond, type: Integer
  #field :num_totaal, type: Integer

  # winning much (test 2)
  # target is set by logopedist
  # 2/days for 10 days (streak / no streak )
  # target = 10 days
  # frequency = 2 (frequency per day, may be floet)

  field :frequency, type: Float, default: 1.0
  field :target, type: Integer, default: 10
  field :achieved, type: Integer, default: 0  # achieved of target
  field :completed_for_the_day, type: Boolean, default: false
  field :completed, type: Boolean, default: false
  field :last_progress_update, type: DateTime

  # use streak at all?
  field :streak, type: Boolean, default: false

  # streak status
  field :streak_expire, type: DateTime
  field :streak_target, type: Integer, default: 0
  field :achieved_in_streak, type: Integer, default: 0
  field :complete_streak, type: Boolean, default: false

  # alert me?
  # field :reminder_ids

  def reset_streak
    # if streak is not met, ALL is reset
    self.achieved = 0 unless self.complete_streak

    # you got till the end of the day.
    self.streak_expire = DateTime.now.end_of_day
    self.achieved_in_streak = 0
    self.complete_streak = false

    # here needs to go some magic
    self.streak_target = self.frequency

    self.save
  end

  def validate_streak
    if self.streak_expire == nil || DateTime.now > self.streak_expire && self.streak
      reset_streak
    else
      # do nothing
    end
  end

  def update_progress
    logger.debug "do the update #{self.name} #{self.achieved}"

    # !completed_for_the_day
    self.achieved = self.achieved + 1
    # completed_for_the_day = true if ???

    # completed entirely?
    self.completed = true if self.achieved == self.target

    # streak
    if self.streak
      self.achieved_in_streak = self.achieved_in_streak + 1
      if self.achieved_in_streak == self.streak_target
        self.complete_streak = true
        self.streak_expire = DateTime.tomorrow.end_of_day
      end
    end

    # set status
    # self.streak_status

    logger.debug "do the update #{self.name} #{self.achieved}"
    self.save
  end

  def streak_status
    status = {
      "achieved": self.completed,
      "target": self.completed,
      "completed": self.completed,
      "completed_for_the_day": self.completed_for_the_day,
      "streak_complete":self.complete_streak,
      "achieved_in_streak":self.complete_streak,
      "streak_target":self.complete_streak,
      "streak_expire":self.complete_streak
    }

    status
  end
end
