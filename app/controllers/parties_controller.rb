class PartiesController < ApplicationController
  caches_page :index
  caches_page :show unless Rails.application.config.topic_list_on_parties_show
  #
  # FIXME: need to look into how to cache the parties page when
  # the topic list is enabled.
  #
  # * sweeper
  # * ActiveRecord::Observer
  #
  # The party page must be expired on:
  #
  # * topic saved
  # * topic's vote_connection updated
  # * topic's vote_connection added
  # * topic's vote_connection removed
  #
  # Also need to find a way to test this.

  def index
    @parties = Party.order(:name).all

    respond_to do |format|
      format.html
      format.json { render json: @parties }
      format.xml  { render xml:  @parties }
    end
  end

  def show
    @party  = Party.includes(:representatives, :promises => :categories).find(params[:id])
    @topics = Topic.vote_ordered.limit(10)

    respond_to do |format|
      format.html
      format.json { render json: @party }
      format.xml  { render xml:  @party }
    end
  end

end
