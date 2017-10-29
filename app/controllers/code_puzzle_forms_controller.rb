class CodePuzzleFormsController < ApplicationController
  before_action :set_code_puzzle_form, only: [:show]

  def show
    @code_puzzle_form.update(
      access_count: @code_puzzle_form.access_count + 1,
      last_accessed_at: Time.new
    )
  end

  # POST /code_puzzle_formes
  # POST /code_puzzle_formes.json
  def create
    @code_puzzle_form = CodePuzzleForm.new(code_puzzle_form_params)

    begin
      customer = Stripe::Customer.create(
        :email => @code_puzzle_form.email,
        :source  => @code_puzzle_form.stripe_token
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => @code_puzzle_form.payment,
        :description => 'The Code Puzzle Pay-What-You-Want',
        :currency    => 'usd'
      )
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to cards_code_puzzle_classes_path
      return
    end

    @code_puzzle_form.stripe_customer_id = customer.id
    @code_puzzle_form.stripe_charge_id = charge.id

    respond_to do |format|
      if @code_puzzle_form.save
        format.html { redirect_to @code_puzzle_form, notice: 'Code puzzle form was successfully created.' }
        format.json { render :show, status: :created, location: @code_puzzle_form }
      else
        format.html { render :new }
        format.json { render json: @code_puzzle_form.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_code_puzzle_form
      @code_puzzle_form = CodePuzzleForm.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_puzzle_form_params
      params.require(:code_puzzle_form).permit(:name, :email, :source, :payment, :stripe_token)
    end
end
