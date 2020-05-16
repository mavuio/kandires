defmodule Kandires.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  import MwHelpers

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowInvitation, PowPersistentSession]

  import Ecto.Changeset, warn: false
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "users" do
    pow_user_fields()

    field(:pricefield, :string)
    field(:name, :string)
    field(:company, :string)
    field(:address, :string)
    field(:phone, :string)
    field(:tpin, :string)
    field(:vat_type, :string)

    timestamps()
  end

  use Accessible

  @impl true
  def changeset(struct, params \\ %{}) do
    is_not_backend_request =
      if params["is_backend_request"] == true do
        false
      else
        true
      end

    struct
    |> cast(
      params,
      [
        :pricefield,
        :name,
        :company,
        :address,
        :phone,
        :tpin,
        :email,
        :vat_type
      ]
    )
    |> pipe_when(is_not_backend_request, pow_changeset(params))
    |> pipe_when(is_not_backend_request, pow_extension_changeset(params))
  end
end
