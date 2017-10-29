class CodePuzzleClassesController < ApplicationController
  before_action :set_code_puzzle_class, only: [:show, :edit, :update, :destroy]

  def cards
    @code_puzzle_form = CodePuzzleForm.new(payment: 300)
  end

  # GET /code_puzzle_classes
  # GET /code_puzzle_classes.json
  def index
    @code_puzzle_classes = CodePuzzleClass.all
  end

  # GET /code_puzzle_classes/1
  # GET /code_puzzle_classes/1.json
  def show
    respond_to do |format|
      format.html { render }
      format.json { render :show, status: :created, location: @code_puzzle_class }
    end
  end

  # GET /code_puzzle_classes/new
  def new
    @code_puzzle_class = CodePuzzleClass.new
  end

  # GET /code_puzzle_classes/1/edit
  def edit
  end

  # POST /code_puzzle_classes
  # POST /code_puzzle_classes.json
  def create
    @code_puzzle_class = CodePuzzleClass.new(code_puzzle_class_params)

    respond_to do |format|
      if @code_puzzle_class.save
        format.html { redirect_to @code_puzzle_class, notice: 'Code puzzle class was successfully created.' }
        format.json { render :show, status: :created, location: @code_puzzle_class }
      else
        format.html { render :new }
        format.json { render json: @code_puzzle_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_puzzle_classes/1
  # PATCH/PUT /code_puzzle_classes/1.json
  def update
    respond_to do |format|
      if @code_puzzle_class.update(code_puzzle_class_params)
        format.html { redirect_to @code_puzzle_class, notice: 'Code puzzle class was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_puzzle_class }
      else
        format.html { render :edit }
        format.json { render json: @code_puzzle_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_puzzle_classes/1
  # DELETE /code_puzzle_classes/1.json
  def destroy
    @code_puzzle_class.destroy
    respond_to do |format|
      format.html { redirect_to code_puzzle_classes_url, notice: 'Code puzzle class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_puzzle_class
      @code_puzzle_class = CodePuzzleClass.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_puzzle_class_params
      params.require(:code_puzzle_class).permit(:name, :slug, :active)
    end
end
