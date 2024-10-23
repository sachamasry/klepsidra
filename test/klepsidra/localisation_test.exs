defmodule Klepsidra.LocalisationTest do
  use Klepsidra.DataCase

  alias Klepsidra.Localisation

  describe "localisation_languages" do
    alias Klepsidra.Localisation.Language

    import Klepsidra.LocalisationFixtures

    @invalid_attrs %{
      "iso_639-3_language_code": nil,
      "iso_639-2_language_code": nil,
      "iso_639-1_language_code": nil,
      language_name: nil
    }

    test "list_localisation_languages/0 returns all localisation_languages" do
      language = language_fixture()
      assert Localisation.list_localisation_languages() == [language]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Localisation.get_language!(language."iso_639-3_language_code") == language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{
        "iso_639-3_language_code": "some iso_639-3",
        "iso_639-2_language_code": "some iso_639-2",
        "iso_639-1_language_code": "some iso_639-1",
        language_name: "some language_name"
      }

      assert {:ok, %Language{} = language} = Localisation.create_language(valid_attrs)
      assert language."iso_639-3_language_code" == "some iso_639-3"
      assert language."iso_639-2_language_code" == "some iso_639-2"
      assert language."iso_639-1_language_code" == "some iso_639-1"
      assert language.language_name == "some language_name"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Localisation.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()

      update_attrs = %{
        "iso_639-3_language_code": "some updated iso_639-3",
        "iso_639-2_language_code": "some updated iso_639-2",
        "iso_639-1_language_code": "some updated iso_639-1",
        language_name: "some updated language_name"
      }

      assert {:ok, %Language{} = language} = Localisation.update_language(language, update_attrs)
      assert language."iso_639-3_language_code" == "some updated iso_639-3"
      assert language."iso_639-2_language_code" == "some updated iso_639-2"
      assert language."iso_639-1_language_code" == "some updated iso_639-1"
      assert language.language_name == "some updated language_name"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Localisation.update_language(language, @invalid_attrs)
      assert language == Localisation.get_language!(language."iso_639-3_language_code")
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Localisation.delete_language(language)
      assert Localisation.get_language!(language."iso_639-3_language_code") == nil
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Localisation.change_language(language)
    end
  end
end
