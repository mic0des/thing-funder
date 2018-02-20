class ProjectsController < ApplicationController

	before_action :set_project, only: [:show, :edit, :update, :destroy, :finish]

	before_action :authorize_user, only: [:edit, :update, :destroy]	

	def index 
		if params[:search]
			@search = params[:search]
			redirect_to :action => 'results', :anchor => 'projects', search: @search
		elsif params[:sort] === "newest"
			@projects = Project.published.recent
		elsif params[:sort] === "popular"
			@projects = Project.joins(:comments).all
		elsif params[:sort] === "time_running_out"
			@projects = Project.time_running_out
		else
			@projects = Project.all
		end
	end

	def results 
		@projects = Project.search(params[:search])
		render 'index'
	end

	def show 
		@comment = Comment.new
		session[:return_to] ||= request.referer
	end

	def new 
		@project = Project.new
		@category = Category.new
	end

	def create 
	    @project = current_user.projects.create(project_params)

	    @project.add_categories(params["project"]["categories"]) 

	    if @project.errors.size == 0 
    		redirect_to project_finish_path(@project)
    	else
    		render 'new'
    	end
	end

	def edit 
	end

	def finish
		@project = Project.find(params[:project_id])
		3.times { @project.rewards.build(name: "") }
	end

	def update
		if @project.update_attributes(project_params)
			@project.add_categories(params["project"]["categories"]) 
			@project.update(published: true)
			redirect_to project_path(@project)
		else
			if @project.published? 
				render 'edit' 
			else 
				render 'finish' 
			end
		end
	end

	def destroy
		@project.destroy
		redirect_to root_path
	end

	def user_projects 
		@started_projects = current_user.projects
		@funded_projects = nil		
	end

	def filter 
		redirect_to :back
	end

	private 

	def set_project
		@project = Project.find(params[:project_id] || params[:id])
	end

	def authorize_user
		redirect_to '/', alert: "You're not allowed to do that!" unless current_user && current_user.admin? || current_user.try(:id) == @project.user_id
	end

	def project_params 
		params.require(:project).permit(
			:user_id,
			:name,
			:tagline,
			:about,
			:category_ids,
			:image,
			:faq,
			:goal,
			:risk_and_challenges,
			:deadline,
			rewards_attributes: [
      			:name,
      			:description,
      			:pledge_requirement
      		]
    	)
	end
end