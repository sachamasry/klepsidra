defmodule Klepsidra.ProjectsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Projects

  describe "projects" do
    alias Klepsidra.Projects.Project

    import Klepsidra.ProjectsFixtures

    @invalid_attrs %{active: nil, name: nil, description: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{active: true, name: "some name", description: "some description"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.active == true
      assert project.name == "some name"
      assert project.description == "some description"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        active: false,
        name: "some updated name",
        description: "some updated description"
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.active == false
      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "project_notes" do
    alias Klepsidra.Projects.Note

    import Klepsidra.ProjectsFixtures

    @invalid_attrs %{note: nil, user_id: nil, project_id: nil}

    # test "list_project_notes/0 returns all project_notes" do
    #   note = note_fixture()
    #   assert Projects.list_project_notes() == [note]
    # end

    # test "get_note!/1 returns the note with given id" do
    #   note = note_fixture()
    #   assert Projects.get_note!(note.id) == note
    # end

    # test "create_note/1 with valid data creates a note" do
    #   valid_attrs = %{note: "some note", user_id: 42, project_id: 42}

    #   assert {:ok, %Note{} = note} = Projects.create_note(valid_attrs)
    #   assert note.note == "some note"
    #   assert note.user_id == 42
    #   assert note.project_id == 42
    # end

    # test "create_note/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Projects.create_note(@invalid_attrs)
    # end

    # test "update_note/2 with valid data updates the note" do
    #   note = note_fixture()
    #   update_attrs = %{note: "some updated note", user_id: 43, project_id: 43}

    #   assert {:ok, %Note{} = note} = Projects.update_note(note, update_attrs)
    #   assert note.note == "some updated note"
    #   assert note.user_id == 43
    #   assert note.project_id == 43
    # end

    # test "update_note/2 with invalid data returns error changeset" do
    #   note = note_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Projects.update_note(note, @invalid_attrs)
    #   assert note == Projects.get_note!(note.id)
    # end

    # test "delete_note/1 deletes the note" do
    #   note = note_fixture()
    #   assert {:ok, %Note{}} = Projects.delete_note(note)
    #   assert_raise Ecto.NoResultsError, fn -> Projects.get_note!(note.id) end
    # end

    # test "change_note/1 returns a note changeset" do
    #   note = note_fixture()
    #   assert %Ecto.Changeset{} = Projects.change_note(note)
    # end
  end
end
