require 'test_helper'

class CodePuzzleProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_puzzle_project = code_puzzle_projects(:one)
  end

  test "should get index" do
    get code_puzzle_projects_url
    assert_response :success
  end

  test "should get new" do
    get new_code_puzzle_project_url
    assert_response :success
  end

  test "should create code_puzzle_project" do
    assert_difference('CodePuzzleProject.count') do
      post code_puzzle_projects_url, params: { code_puzzle_project: { code_puzzle_class_id: @code_puzzle_project.code_puzzle_class_id, name: @code_puzzle_project.name } }
    end

    assert_redirected_to code_puzzle_project_url(CodePuzzleProject.last)
  end

  test "should show code_puzzle_project" do
    get code_puzzle_project_url(@code_puzzle_project)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_puzzle_project_url(@code_puzzle_project)
    assert_response :success
  end

  test "should update code_puzzle_project" do
    patch code_puzzle_project_url(@code_puzzle_project), params: { code_puzzle_project: { code_puzzle_class_id: @code_puzzle_project.code_puzzle_class_id, name: @code_puzzle_project.name } }
    assert_redirected_to code_puzzle_project_url(@code_puzzle_project)
  end

  test "should destroy code_puzzle_project" do
    assert_difference('CodePuzzleProject.count', -1) do
      delete code_puzzle_project_url(@code_puzzle_project)
    end

    assert_redirected_to code_puzzle_projects_url
  end
end
