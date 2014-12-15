class ActsController < ApplicationController
  def mb
    render :json => MusicBrainz::Artist.search(params[:act].gsub("?term=", ""))
  end

  def esuggest #echonest artist suggest
    artists = []

    artists = Act.order(:name).where("name LIKE ?", "%#{params[:act]}%").limit(5) # first see if artists already exists in the DB

    if artists.length <= 0
      artists = Echowrap.artist_suggest(:name => params[:act], results: 5)      
    end

    names = []

    artists.each do |a|
      # 3 cases
      # 1. found in db, has echonest ID = id is echonest id
      # 2. found in DB, has no echonest ID = id is "DB-act_id
      # 3. not found in DB = ID = "ECHO-echonest_id"
      echo = "DB-"

      if a.class.to_s == "Echowrap::Artist" # case for if found in echonest
        echo = "ECHO-" + a.id
      else
        if a.echonest_id
          echo = a.echonest_id
        else
          echo = echo + a.id.to_s
        end
      end
      names << {id: echo, value: a.name}
    end
    render :json => names
  end

  def eretrieve #echonest artist search with single response

    render :json => Act.echo_by_name(params[:act], params[:eid]) # TODO - get echonest data by ID, not name

  end

  def show
    @act = Act.find_by(id:params[:id])
  end
end