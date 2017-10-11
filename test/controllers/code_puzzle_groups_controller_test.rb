require 'test_helper'

class CodePuzzleGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_puzzle_group = code_puzzle_groups(:one)
  end

  test "should get index" do
    get code_puzzle_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_code_puzzle_group_url
    assert_response :success
  end

  test "should create code_puzzle_group" do
    assert_difference('CodePuzzleGroup.count') do
      post code_puzzle_groups_url, params: { code_puzzle_group: { code_puzzle_project_id: @code_puzzle_group.code_puzzle_project_id, photo_url: @code_puzzle_group.photo_url, position: @code_puzzle_group.position } }
    end

    assert_redirected_to code_puzzle_group_url(CodePuzzleGroup.last)
  end

  test "should show code_puzzle_group" do
    get code_puzzle_group_url(@code_puzzle_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_puzzle_group_url(@code_puzzle_group)
    assert_response :success
  end

  test "should update code_puzzle_group" do
    patch code_puzzle_group_url(@code_puzzle_group), params: { code_puzzle_group: { code_puzzle_project_id: @code_puzzle_group.code_puzzle_project_id, photo_url: @code_puzzle_group.photo_url, position: @code_puzzle_group.position } }
    assert_redirected_to code_puzzle_group_url(@code_puzzle_group)
  end

  test "should destroy code_puzzle_group" do
    assert_difference('CodePuzzleGroup.count', -1) do
      delete code_puzzle_group_url(@code_puzzle_group)
    end

    assert_redirected_to code_puzzle_groups_url
  end
end
