class CodePuzzleProjectsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_code_puzzle_class
  before_action :set_code_puzzle_project, only: [:show, :edit, :update, :destroy]

  # GET /code_puzzle_projects
  # GET /code_puzzle_projects.json
  def index
    @code_puzzle_projects = CodePuzzleProject.all
  end

  # GET /code_puzzle_projects/1
  # GET /code_puzzle_projects/1.json
  def show
  end

  # GET /code_puzzle_projects/new
  def new
    @code_puzzle_project = CodePuzzleProject.new
  end

  # GET /code_puzzle_projects/1/edit
  def edit
  end

  # POST /code_puzzle_projects
  # POST /code_puzzle_projects.json
  def create
    @code_puzzle_project = @code_puzzle_class.code_puzzle_projects.new(code_puzzle_project_params)

    respond_to do |format|
      if @code_puzzle_project.save
        format.html { redirect_to @code_puzzle_project, notice: 'Code puzzle project was successfully created.' }
        format.json { render :show, status: :created, location: [@code_puzzle_class, @code_puzzle_project] }
      else
        format.html { render :new }
        format.json { render json: @code_puzzle_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_puzzle_projects/1
  # PATCH/PUT /code_puzzle_projects/1.json
  def update
    respond_to do |format|
      if @code_puzzle_project.update(code_puzzle_project_params)
        format.html { redirect_to @code_puzzle_project, notice: 'Code puzzle project was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_puzzle_project }
      else
        format.html { render :edit }
        format.json { render json: @code_puzzle_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_puzzle_projects/1
  # DELETE /code_puzzle_projects/1.json
  def destroy
    @code_puzzle_project.destroy
    respond_to do |format|
      format.html { redirect_to code_puzzle_projects_url, notice: 'Code puzzle project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_puzzle_project
      @code_puzzle_project = code_puzzle_class.code_puzzle_projects.find(params[:id])
    end

    def set_code_puzzle_class
      @code_puzzle_class = CodePuzzleClass.friendly.find(params[:code_puzzle_class_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_puzzle_project_params
      params.require(:code_puzzle_project).permit(:title)
    end
end
