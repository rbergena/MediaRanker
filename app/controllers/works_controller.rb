class WorksController < ApplicationController
  before_action :find_work_by_params_id, only: [:show, :edit, :update, :destroy]

  def index
    @works = Work.all
  end

  def show ; end

  def edit ; end

  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)
    if save_and_flash(@work, "create")
      redirect_to work_path(@work.id)
    else
      render :new, status: :bad_request
    end
  end

  def update
    @work.update_attributes(work_params)
    if save_and_flash(@work, "update")
      redirect_to work_path(@work.id)
    else
      render :edit, status: :bad_request
    end
  end

  def destroy
    current_user = nil
    if session[:logged_in_user]
      current_user = User.find_by(id: session[:logged_in_user])
      @work = Work.find(params[:id])
      @work.destroy
      flash[:status] = :success
      flash[:message] = "Deleted #{@work.category} #{@work.title}"
      redirect_to works_path
    else
      flash[:status] = :failure
      flash[:message] = "You must be logged in to do that!"
      redirect_to works_path
      return
    end
  end

  def upvote
    user_id = session[:logged_in_user]
    @work = Work.find(params[:id])
    if !(session[:logged_in_user])
      flash[:status] = :failure
      flash[:message] = "You must be logged in to do that!"
      redirect_back fallback_location: { action: "index"}
    elsif session[:logged_in_user]
      vote = Vote.new(work_id: @work.id, user_id: user_id, date: Date.today)
      if vote.save
        flash[:status] = :success
        flash[:message] = "Successfuly upvoted #{@work.title}!"
        redirect_back fallback_location: { action: "index"}
      else
        flash[:status] = :failure
        flash[:message] = "Could not upvote. User has already voted for #{@work.title}"
        flash[:details] = vote.errors.messages
        redirect_back fallback_location: { action: "index"}
      end
    end

  end

  private

  def work_params
    return params.require(:work).permit(:category, :title, :creator, :publication_year, :description)
  end

  def find_work_by_params_id
    @work = Work.find_by(id: params[:id])
    unless @work
      head :not_found
    end
  end
end
