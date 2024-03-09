defmodule Klepsidra.CategorisationTest do
  use Klepsidra.DataCase

  alias Klepsidra.Categorisation

  describe "tags" do
    alias Klepsidra.Categorisation.Tag

    import Klepsidra.CategorisationFixtures

    @invalid_attrs %{name: nil, tag: nil, description: nil, colour: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Categorisation.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Categorisation.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name", tag: "some tag", description: "some description", colour: "some colour"}

      assert {:ok, %Tag{} = tag} = Categorisation.create_tag(valid_attrs)
      assert tag.name == "some name"
      assert tag.tag == "some tag"
      assert tag.description == "some description"
      assert tag.colour == "some colour"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categorisation.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{name: "some updated name", tag: "some updated tag", description: "some updated description", colour: "some updated colour"}

      assert {:ok, %Tag{} = tag} = Categorisation.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
      assert tag.tag == "some updated tag"
      assert tag.description == "some updated description"
      assert tag.colour == "some updated colour"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Categorisation.update_tag(tag, @invalid_attrs)
      assert tag == Categorisation.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Categorisation.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Categorisation.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Categorisation.change_tag(tag)
    end
  end
end
