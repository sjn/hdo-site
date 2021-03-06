# encoding: utf-8
require 'spec_helper'

describe Topic do
  let(:blank_topic) { Topic.new }
  let(:valid_topic) { Topic.make! }

  it "is invalid without a title" do
    t = blank_topic

    t.should_not be_valid
    t.title = "foo"
    t.should be_valid
  end

  it "can associate categories" do
    a = Category.make!
    b = Category.make!

    t = valid_topic

    t.categories << a
    t.categories << b

    t.categories.map(&:name).should == [a.name, b.name]

    t.should be_valid
  end

  it "won't add the same category twice" do
    cat = Category.make!

    valid_topic.categories << cat
    valid_topic.categories << cat

    valid_topic.categories.size.should == 1
  end

  it "can associate promises" do
    valid_topic.promises << Promise.make!
    valid_topic.promises.first.body.should_not be_empty
  end

  it "won't add the same promise twice" do
    promise = Promise.make!

    valid_topic.promises << promise
    valid_topic.promises << promise

    valid_topic.promises.size.should == 1
  end

  it "can associate fields" do
    field = Field.make!

    valid_topic.fields << field
    valid_topic.fields.first.should == field
  end

  it "won't add the same field twice" do
    field = Field.make!

    valid_topic.fields << field
    valid_topic.fields << field

    valid_topic.fields.size.should == 1
  end

  it "can associate votes with a vote direction" do
    vote = Vote.make!
    topic = Topic.make!(:vote_connections => [])

    topic.vote_connections.create!(:vote => vote, :matches => true)
    topic.votes.should == [vote]

    topic.connection_for(vote).should_not be_nil
  end

  it 'destroys vote connections when destroyed' do
    topic = Topic.make!
    topic.vote_connections.size.should == VoteConnection.count

    topic.destroy
    VoteConnection.count.should == 0
  end

  it "has a unique title" do
    Topic.make!(:title => 'a')
    Topic.make(:title => 'a').should_not be_valid
  end

  it "has a stats object" do
    valid_topic.stats.should be_kind_of(Hdo::Stats::VoteScorer)
  end

  it 'caches the stats object' do
    Hdo::Stats::VoteScorer.should_receive(:new).once

    Topic.find(valid_topic.id).stats # 1 - not cached
    Topic.find(valid_topic.id).stats # 2 - cached
  end

  it 'deletes the cached stats on save' do
    Hdo::Stats::VoteScorer.should_receive(:new).twice

    Topic.find(valid_topic.id).stats # 1 - not cached
    Topic.find(valid_topic.id).stats # 2 - cached

    valid_topic.vote_connections.create! :vote => Vote.make!, :matches => true

    Topic.find(valid_topic.id).stats # 3 - no longer cached
  end

  it 'correctly downcases a title with non-ASCII characters' do
    Topic.make(:title => "Ærlig").downcased_title.should == "ærlig"
  end

  it 'finds the latest topics based on vote time' do
    t1 = Topic.make!
    t2 = Topic.make!
    t3 = Topic.make!

    t1.vote_connections.map { |e| e.vote.update_attributes!(:time => 3.days.ago) }
    t2.vote_connections.map { |e| e.vote.update_attributes!(:time => 2.days.ago) }
    t3.vote_connections.map { |e| e.vote.update_attributes!(:time => 1.day.ago) }

    Topic.vote_ordered.should == [t3, t2, t1]
  end
end
