defmodule Kandires.VariantC do
  @moduledoc false
  # alias Kandires.Repo
  alias Kandires.Variant
  alias Kandires.Repo
  alias Kandires.ListTypeC

  import Ecto.Query

  # import MwHelpers

  def get_record_query_for_controller(%{"dataview" => "list_all"} = _params) do
    Variant
    |> select([r], %{
      id: r.id,
      variant_title: r.variant_title,
      vendor_code: r.vendor_code,
      source_price: r.source_price,
      price1: "__generate_price1",
      price2: "__generate_price2",
      price3: "__generate_price3",
      price4: "__generate_price4",
      source_type: r.source_type,
      prod_id: r.prod_id,
      upload_id: r.upload_id,
      updated_at: r.updated_at,
      inserted_at: r.inserted_at
    })
    |> order_by([r], asc: r.variant_title)
  end

  def get_variant(record_or_id) do
    case record_or_id do
      %Variant{} = prod -> prod
      id -> Repo.get!(Variant, MwHelpers.to_int(id))
    end
  end

  def generate_price1(rec), do: generate_price(rec, :price1)
  def generate_price2(rec), do: generate_price(rec, :price2)
  def generate_price3(rec), do: generate_price(rec, :price3)
  def generate_price4(rec), do: generate_price(rec, :price4)

  def generate_price(rec, field) when is_atom(field) do
    factor = ListTypeC.get_factor_for_list(rec.source_type, field)

    case {factor, rec.source_price} do
      {_, nil} -> nil
      {nil, _} -> nil
      {f, p} -> Decimal.mult(p, f)
    end
    |> round_price()
  end

  def round_price(nil), do: nil
  def round_price(v) when is_binary(v), do: round_price(MwHelpers.str_to_dec(v))

  def round_price(%Decimal{} = v) do
    cond do
      :gt == Decimal.cmp(v, "10000") -> Decimal.round(v, -2)
      :gt == Decimal.cmp(v, "1000") -> Decimal.round(v, -1)
      true -> Decimal.round(v, 0)
    end
  end
end
