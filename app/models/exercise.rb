class Exercise
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :preset, type: Integer
  field :name, type: String
  field :material, type: String
  # field :content, type: String
  # field :thumb, type: String
  # field :description, type: String
  # field :video, type: String

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

  field :frequency, type: Integer, default: 1             # per day
  field :target, type: Integer, default: 10
  #field :achieved, type: Integer, default: 0              # depricated for array
  field :achieved_array, type: Array, default: []         # replaces above
  #field :achieved_today, type: Integer, default: 0       # depricated for array
  field :achieved_array_today, type: Array, default: []   # achieved of frequency (today)
  field :completed_for_the_day, type: Boolean, default: false
  field :completed, type: Boolean, default: false

  field :last_progress_update, type: DateTime, default: DateTime.now

  field :claimed_award, type: Boolean, default: false
  field :score, type: Integer, default: 0 # 1000/score

  # use streak at all?
  # field :streak, type: Boolean, default: false

  # streak status
  # field :streak_expire, type: DateTime
  # field :streak_target, type: Integer, default: 0
  # field :achieved_in_streak, type: Integer, default: 0
  # field :complete_streak, type: Boolean, default: false

  # alert me?
  # field :reminder_ids


  def update_progress
    Rails.logger.debug "---"
    Rails.logger.debug "Update Progress ...."
    Rails.logger.debug "---"

    # failsave, should be checked earlier
    # if completed_for_the_day
    # return, no play

    # difference_in_days = (before - now).to_i

    # overall achievements
    self.achieved_array << 1
    self.completed if self.achieved_array.count >= self.target

    # daily achievements
    self.achieved_array_today << 1
    #self.completed_for_the_day = true if self.achieved_today >= self.frequency

    # store this date
    self.last_progress_update = DateTime.now # IMPORTANT: OR! DateTime.now().beginning_of_day

    # save
    self.save
  end

  # validates this exercises and the user-streak
  def validate

    # 1. check if the exercise is completed --> show claim reward
    #  1a. is completed true?
    #  1b. achieved_array >= target

    # 2. check if the exercise is completed for the day
    #  2a. completed_for_the_day true?
    #  2a. last update was the past 24 hours &&
    #  2b. achieved_array_today >= frequency

    # this would change at the strike of midnight
    days_ago = ( DateTime.now - self.last_progress_update.beginning_of_day ).to_i

    Rails.logger.debug "---"
    Rails.logger.debug "START VALIDATION #{self.id.to_s}"
    Rails.logger.debug days_ago
    Rails.logger.debug "---"

    if days_ago <= 0
      Rails.logger.debug "---"
      Rails.logger.debug "last update for this one is within limits #{self.last_progress_update} #{days_ago}"
      Rails.logger.debug "---"

    else
      Rails.logger.debug "---"
      Rails.logger.debug "Last update is older #{self.last_progress_update}  #{days_ago}, start invalidation"
      Rails.logger.debug "---"

      # add days 'missed' -- shoudlnt do anything when days_ago = 1 (0 days missed)
      unless completed_for_the_day || completed
        Array.new(days_ago*self.frequency*days_ago).each do |day|
          Rails.logger.debug "DAY!"
          self.achieved_array << 0
        end
      end

      # reset & invalidate any daily achievements
      self.achieved_array_today = []
      self.completed_for_the_day = false
    end

    # now check completed for the day
    if achieved_array_today.count >= frequency
      self.completed_for_the_day = true
      Rails.logger.debug "completed for the day!"
    end

    # ... and completed entirely
    if achieved_array.count >= target
      self.completed = true
      Rails.logger.debug "completed!"
    end

    # finally last_progress_update
    # validation counts as a progress update
    self.last_progress_update = DateTime.now()
    # IMPORTANT: OR! DateTime.now().beginning_of_day
    # IMPORTANT: progress is saved in CET timezone, might want do take off 2 hours
    self.save


    # this checks if the last streaks update was older
    # then 2 days, whichy would mean that the streak was broken
    # not sure if this should be here, as it will get called multiple times
    # if DateTime.now - current_user.last_streak_update > 2.day
    #  self.user.streak = 0
    # end

    #if DateTime.now.to_i - self.last_progress_update >  1.day
      # the user has not played
      # this counts the days not played and fills the
      # days not played TIMES the frequency to 0, ie.
      # these times will be not counted



    #  num_days_not_played = (DateTime.now - last_update).to_i  # num od days
    #  num_days_not_played = num_days_not_played * frequency    # num of exercises planned
    #  i = 0
    #  while i < num_days_not_played
    #    x << 0
    #    i = i + i
    #  end

    #  Rails.logger.debug num_days_not_played

    #else
      # the user has updated yesterday, but if frequency > 1, it could be
      # still short num_days_active * frequency = should_have_completed
      # if should_have_completed < completed_array
      # if


    #end

    # if last_progress_update < 1 day
    #  Execrsice was already updated

    # validate exercis
    # check ""

  end

  def status
    status = {
      "achieved": self.completed,
      "target": self.completed,
      "completed": self.completed,
      "completed_for_the_day": self.completed_for_the_day,
    }

    status
  end
end
