class CodePuzzleCardsController < ApplicationController
  before_action :set_code_puzzle_card, only: [:show, :edit, :update, :destroy]

  # GET /code_puzzle_cards
  # GET /code_puzzle_cards.json
  def index
    @code_puzzle_cards = CodePuzzleCard.all
  end

  # GET /code_puzzle_cards/1
  # GET /code_puzzle_cards/1.json
  def show
  end

  # GET /code_puzzle_cards/new
  def new
    @code_puzzle_card = CodePuzzleCard.new
  end

  # GET /code_puzzle_cards/1/edit
  def edit
  end

  # POST /code_puzzle_cards
  # POST /code_puzzle_cards.json
  def create
    @code_puzzle_card = CodePuzzleCard.new(code_puzzle_card_params)

    respond_to do |format|
      if @code_puzzle_card.save
        format.html { redirect_to @code_puzzle_card, notice: 'Code puzzle card was successfully created.' }
        format.json { render :show, status: :created, location: @code_puzzle_card }
      else
        format.html { render :new }
        format.json { render json: @code_puzzle_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_puzzle_cards/1
  # PATCH/PUT /code_puzzle_cards/1.json
  def update
    respond_to do |format|
      if @code_puzzle_card.update(code_puzzle_card_params)
        format.html { redirect_to @code_puzzle_card, notice: 'Code puzzle card was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_puzzle_card }
      else
        format.html { render :edit }
        format.json { render json: @code_puzzle_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_puzzle_cards/1
  # DELETE /code_puzzle_cards/1.json
  def destroy
    @code_puzzle_card.destroy
    respond_to do |format|
      format.html { redirect_to code_puzzle_cards_url, notice: 'Code puzzle card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_puzzle_card
      @code_puzzle_card = CodePuzzleCard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_puzzle_card_params
      params.require(:code_puzzle_card).permit(:photo_url, :code, :param, :position, :code_puzzle_group_id)
    end
end
