defmodule Klepsidra.LocationsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Locations

  describe "feature_classes" do
    alias Klepsidra.Locations.FeatureClass

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{
      order: nil,
      description: nil,
      feature_code: nil,
      feature_class: nil,
      note: nil
    }

    test "list_feature_classes/0 returns all feature_classes" do
      feature_class = feature_class_fixture()
      assert Locations.list_feature_classes() == [feature_class]
    end

    test "get_feature_class!/1 returns the feature_class with given `feature_class`" do
      feature_class = feature_class_fixture()
      assert Locations.get_feature_class!(feature_class.feature_class) == feature_class
    end

    test "create_feature_class/1 with valid data creates a feature_class" do
      valid_attrs = %{
        order: 42,
        description: "some description",
        feature_code: "some feature_code",
        feature_class: "some feature_class",
        note: "some note"
      }

      assert {:ok, %FeatureClass{} = feature_class} = Locations.create_feature_class(valid_attrs)
      assert feature_class.order == 42
      assert feature_class.description == "some description"
      assert feature_class.feature_code == "some feature_code"
      assert feature_class.feature_class == "some feature_class"
      assert feature_class.note == "some note"
    end

    test "create_feature_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_feature_class(@invalid_attrs)
    end

    test "update_feature_class/2 with valid data updates the feature_class" do
      feature_class = feature_class_fixture()

      update_attrs = %{
        order: 43,
        description: "some updated description",
        feature_code: "some updated feature_code",
        feature_class: "some updated feature_class",
        note: "some updated note"
      }

      assert {:ok, %FeatureClass{} = feature_class} =
               Locations.update_feature_class(feature_class, update_attrs)

      assert feature_class.order == 43
      assert feature_class.description == "some updated description"
      assert feature_class.feature_code == "some updated feature_code"
      assert feature_class.feature_class == "some updated feature_class"
      assert feature_class.note == "some updated note"
    end

    test "update_feature_class/2 with invalid data returns error changeset" do
      feature_class = feature_class_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locations.update_feature_class(feature_class, @invalid_attrs)

      assert feature_class == Locations.get_feature_class!(feature_class.feature_class)
    end

    test "delete_feature_class/1 deletes the feature_class" do
      feature_class = feature_class_fixture()
      assert {:ok, %FeatureClass{}} = Locations.delete_feature_class(feature_class)

      assert_raise Ecto.NoResultsError, fn ->
        Locations.get_feature_class!(feature_class.feature_class)
      end
    end

    test "change_feature_class/1 returns a feature_class changeset" do
      feature_class = feature_class_fixture()
      assert %Ecto.Changeset{} = Locations.change_feature_class(feature_class)
    end
  end
end
