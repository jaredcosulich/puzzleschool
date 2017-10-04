class CodePuzzleGroupsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_code_puzzle_class
  before_action :set_code_puzzle_project
  before_action :set_code_puzzle_group, only: [:show, :edit, :update, :destroy]

  # GET /code_puzzle_groups
  # GET /code_puzzle_groups.json
  def index
    @code_puzzle_groups = CodePuzzleGroup.all
  end

  # GET /code_puzzle_groups/1
  # GET /code_puzzle_groups/1.json
  def show
  end

  # GET /code_puzzle_groups/new
  def new
    @code_puzzle_group = CodePuzzleGroup.new
  end

  # GET /code_puzzle_groups/1/edit
  def edit
  end

  # POST /code_puzzle_groups
  # POST /code_puzzle_groups.json
  def create
    @code_puzzle_group = @code_puzzle_project.code_puzzle_groups.new(code_puzzle_group_params)

    respond_to do |format|
      if @code_puzzle_group.save
        format.html { redirect_to @code_puzzle_group, notice: 'Code puzzle group was successfully created.' }
        format.json { render :show, status: :created, location: [@code_puzzle_class, @code_puzzle_project, @code_puzzle_group] }
      else
        format.html { render :new }
        format.json { render json: @code_puzzle_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_puzzle_groups/1
  # PATCH/PUT /code_puzzle_groups/1.json
  def update
    respond_to do |format|
      if @code_puzzle_group.update(code_puzzle_group_params)
        format.html { redirect_to @code_puzzle_group, notice: 'Code puzzle group was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_puzzle_group }
      else
        format.html { render :edit }
        format.json { render json: @code_puzzle_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_puzzle_groups/1
  # DELETE /code_puzzle_groups/1.json
  def destroy
    @code_puzzle_group.destroy
    respond_to do |format|
      format.html { redirect_to code_puzzle_groups_url, notice: 'Code puzzle group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_puzzle_group
      @code_puzzle_group = @code_puzzle_project.code_puzzle_groups.find(params[:id])
    end

    def set_code_puzzle_project
      @code_puzzle_project = @code_puzzle_class.code_puzzle_projects.find(params[:code_puzzle_project_id])
    end

    def set_code_puzzle_class
      @code_puzzle_class = CodePuzzleClass.friendly.find(params[:code_puzzle_class_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_puzzle_group_params
      params.require(:code_puzzle_group).permit(:photo_url, :position)
    end
end
