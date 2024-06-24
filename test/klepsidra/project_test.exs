defmodule Klepsidra.ProjectTest do
  use Klepsidra.DataCase

  alias Klepsidra.Project

  describe "notes" do
    alias Klepsidra.Project.Note

    import Klepsidra.ProjectFixtures

    @invalid_attrs %{note: nil, user_id: nil, project_id: nil}

    test "list_notes/0 returns all notes" do
      note = note_fixture()
      assert Project.list_notes() == [note]
    end

    test "get_note!/1 returns the note with given id" do
      note = note_fixture()
      assert Project.get_note!(note.id) == note
    end

    test "create_note/1 with valid data creates a note" do
      valid_attrs = %{note: "some note", user_id: 42, project_id: 42}

      assert {:ok, %Note{} = note} = Project.create_note(valid_attrs)
      assert note.note == "some note"
      assert note.user_id == 42
      assert note.project_id == 42
    end

    test "create_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Project.create_note(@invalid_attrs)
    end

    test "update_note/2 with valid data updates the note" do
      note = note_fixture()
      update_attrs = %{note: "some updated note", user_id: 43, project_id: 43}

      assert {:ok, %Note{} = note} = Project.update_note(note, update_attrs)
      assert note.note == "some updated note"
      assert note.user_id == 43
      assert note.project_id == 43
    end

    test "update_note/2 with invalid data returns error changeset" do
      note = note_fixture()
      assert {:error, %Ecto.Changeset{}} = Project.update_note(note, @invalid_attrs)
      assert note == Project.get_note!(note.id)
    end

    test "delete_note/1 deletes the note" do
      note = note_fixture()
      assert {:ok, %Note{}} = Project.delete_note(note)
      assert_raise Ecto.NoResultsError, fn -> Project.get_note!(note.id) end
    end

    test "change_note/1 returns a note changeset" do
      note = note_fixture()
      assert %Ecto.Changeset{} = Project.change_note(note)
    end
  end
end
