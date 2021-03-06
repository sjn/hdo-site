class VoteConnection < ActiveRecord::Base
  WEIGHTS        = [0.0, 0.5, 1.0, 2.0, 4.0]
  DEFAULT_WEIGHT = 1.0

  belongs_to :vote
  belongs_to :topic

  attr_accessible :vote, :vote_id, :topic, :matches, :comment, :weight, :description

  validates_inclusion_of :weight, :in => WEIGHTS
  validates_presence_of  :vote,
                         :topic,
                         :weight


  def matches_text
    matches? ? I18n.t('app.yes') : I18n.t('app.no')
  end
end
