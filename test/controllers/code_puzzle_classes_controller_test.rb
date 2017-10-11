require 'test_helper'

class CodePuzzleClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_puzzle_class = code_puzzle_classes(:one)
  end

  test "should get index" do
    get code_puzzle_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_code_puzzle_class_url
    assert_response :success
  end

  test "should create code_puzzle_class" do
    assert_difference('CodePuzzleClass.count') do
      post code_puzzle_classes_url, params: { code_puzzle_class: { active: @code_puzzle_class.active, name: @code_puzzle_class.name, slug: @code_puzzle_class.slug } }
    end

    assert_redirected_to code_puzzle_class_url(CodePuzzleClass.last)
  end

  test "should show code_puzzle_class" do
    get code_puzzle_class_url(@code_puzzle_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_puzzle_class_url(@code_puzzle_class)
    assert_response :success
  end

  test "should update code_puzzle_class" do
    patch code_puzzle_class_url(@code_puzzle_class), params: { code_puzzle_class: { active: @code_puzzle_class.active, name: @code_puzzle_class.name, slug: @code_puzzle_class.slug } }
    assert_redirected_to code_puzzle_class_url(@code_puzzle_class)
  end

  test "should destroy code_puzzle_class" do
    assert_difference('CodePuzzleClass.count', -1) do
      delete code_puzzle_class_url(@code_puzzle_class)
    end

    assert_redirected_to code_puzzle_classes_url
  end
end
