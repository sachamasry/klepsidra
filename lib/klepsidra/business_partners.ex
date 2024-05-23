defmodule Klepsidra.BusinessPartners do
  @moduledoc """
  The BusinessPartners context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.BusinessPartners.BusinessPartner

  @doc """
  Returns the list of business_partners.

  ## Examples

      iex> list_business_partners()
      [%BusinessPartner{}, ...]

  """
  def list_business_partners do
    Repo.all(BusinessPartner)
  end

  @doc """
  Gets a single business_partner.

  Raises `Ecto.NoResultsError` if the Business partner does not exist.

  ## Examples

      iex> get_business_partner!(123)
      %BusinessPartner{}

      iex> get_business_partner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_business_partner!(id), do: Repo.get!(BusinessPartner, id)

  @doc """
  Creates a business_partner.

  ## Examples

      iex> create_business_partner(%{field: value})
      {:ok, %BusinessPartner{}}

      iex> create_business_partner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_business_partner(attrs \\ %{}) do
    %BusinessPartner{}
    |> BusinessPartner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a business_partner.

  ## Examples

      iex> update_business_partner(business_partner, %{field: new_value})
      {:ok, %BusinessPartner{}}

      iex> update_business_partner(business_partner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_business_partner(%BusinessPartner{} = business_partner, attrs) do
    business_partner
    |> BusinessPartner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a business_partner.

  ## Examples

      iex> delete_business_partner(business_partner)
      {:ok, %BusinessPartner{}}

      iex> delete_business_partner(business_partner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_business_partner(%BusinessPartner{} = business_partner) do
    Repo.delete(business_partner)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking business_partner changes.

  ## Examples

      iex> change_business_partner(business_partner)
      %Ecto.Changeset{data: %BusinessPartner{}}

  """
  def change_business_partner(%BusinessPartner{} = business_partner, attrs \\ %{}) do
    BusinessPartner.changeset(business_partner, attrs)
  end
end
