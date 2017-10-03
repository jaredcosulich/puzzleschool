require 'test_helper'

class CodePuzzleCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_puzzle_card = code_puzzle_cards(:one)
  end

  test "should get index" do
    get code_puzzle_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_code_puzzle_card_url
    assert_response :success
  end

  test "should create code_puzzle_card" do
    assert_difference('CodePuzzleCard.count') do
      post code_puzzle_cards_url, params: { code_puzzle_card: { code: @code_puzzle_card.code, code_puzzle_group_id: @code_puzzle_card.code_puzzle_group_id, param: @code_puzzle_card.param, photo_url: @code_puzzle_card.photo_url, position: @code_puzzle_card.position } }
    end

    assert_redirected_to code_puzzle_card_url(CodePuzzleCard.last)
  end

  test "should show code_puzzle_card" do
    get code_puzzle_card_url(@code_puzzle_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_puzzle_card_url(@code_puzzle_card)
    assert_response :success
  end

  test "should update code_puzzle_card" do
    patch code_puzzle_card_url(@code_puzzle_card), params: { code_puzzle_card: { code: @code_puzzle_card.code, code_puzzle_group_id: @code_puzzle_card.code_puzzle_group_id, param: @code_puzzle_card.param, photo_url: @code_puzzle_card.photo_url, position: @code_puzzle_card.position } }
    assert_redirected_to code_puzzle_card_url(@code_puzzle_card)
  end

  test "should destroy code_puzzle_card" do
    assert_difference('CodePuzzleCard.count', -1) do
      delete code_puzzle_card_url(@code_puzzle_card)
    end

    assert_redirected_to code_puzzle_cards_url
  end
end
