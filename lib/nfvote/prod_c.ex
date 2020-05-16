defmodule Kandires.ProdC do
  @moduledoc false
  alias Kandires.Repo
  alias Kandires.Prod
  alias Kandires.ListType
  alias Kandires.UserC
  alias Kandires.CategoryC
  alias Kandires.VariantC
  alias Kandires.Variant

  import Ecto.Query
  import Kandis.KdHelpers
  @vat_rate "1.165"

  def get_record_query_for_controller(%{"dataview" => "list_all"} = _params) do
    Prod
    |> select([r], %{
      id: r.id,
      path: r.path,
      title: r.title,
      text: r.text,
      brand: r.brand,
      sku: r.sku,
      url: r.url,
      __img_urls: r.img_urls,
      cached_img_urls: "__generate_cached_img_urls",
      source_type: r.source_type,
      upload_id: r.upload_id,
      updated_at: r.updated_at,
      inserted_at: r.inserted_at
    })
    |> order_by([r], asc: r.title)
  end

  def get_product(record_or_id) do
    case record_or_id do
      %Prod{} = prod -> prod
      id -> Repo.get!(Prod, Kandis.KdHelpers.to_int(id))
    end
  end

  def cache_product_images(prod_or_id) do
    prod = get_product(prod_or_id)

    if present?(array_get(prod, :img_urls)) do
      prod[:img_urls]
      |> String.split(",")
      |> Enum.map(&cache_file_for_product(&1, prod))
    end
  end

  def cache_file_for_product(url, prod) do
    url = String.trim(url)

    # ext = Path.extname(url)

    cachefilename = get_cachefilename(url, prod)

    if not File.exists?(cachefilename) do
      case Download.from(url, path: cachefilename) do
        {:ok, path} -> {:file_cached, path}
        error -> error |> MwError.die(label: "ERROR while fetching image")
      end
    else
      {:file_already_cached, url}
    end
  end

  def get_cachefilename(url, prod) do
    hash = get_hash_for_string(url)
    extension = Path.extname(url)
    dir = get_prod_image_dir(prod)
    dir <> hash <> extension
  end

  def get_cachefile_url(url, prod) do
    hash = get_hash_for_string(url)
    extension = Path.extname(url)
    dir = "/prod_imgs/prod/#{prod.id}/"
    dir <> hash <> extension
  end

  def get_prod_image_dir(prod) do
    dir = Application.get_env(:kandires, :prod_imgs_directory) <> "/prod/#{prod.id}/"

    if not File.exists?(dir) do
      File.mkdir_p!(dir)
    end

    dir
  end

  def get_hash_for_string(str) do
    Base.encode16(:erlang.md5(str), case: :lower)
  end

  def generate_cached_img_urls(rec) do
    rec |> IO.inspect(label: "mwuits-debug 2020-02-27_18:28 ")

    if present?(array_get(rec, :img_urls)) do
      rec[:img_urls]
      |> String.split(",")
      |> Enum.map(&get_cachefile_url(&1, rec))
    end
  end

  def get_grouped_products(params) do
    get_products(params)
    |> Enum.chunk_by(& &1.id)
    |> Enum.map(fn items ->
      items
      |> Enum.at(0)
      |> Map.put(:variants, items)
    end)
  end

  def get_product_variant(v_id, params) do
    get_products(Map.put(params, "v_id", v_id))
    |> case do
      [p | []] -> p
      _ -> nil
    end
  end

  def get_products(params) do
    params = UserC.add_user_to_params_using_vid(params)

    get_product_query(params)
    |> Repo.all()
    |> pipe_when(
      params["run_cache"],
      Enum.map(fn a ->
        cache_product_images(a.id)
        a
      end)
    )
    |> Enum.map(fn a ->
      a =
        a
        |> Map.put(:cached_img_urls, generate_cached_img_urls(a) || [])
        |> Map.put(:price, generate_user_price(a, params) || nil)

      a
      |> Map.put(:price_incl, generate_incl_price(a, params) || nil)
      |> Map.drop([:source_price])
    end)
  end

  def generate_incl_price(rec, _) do
    case rec[:price] do
      nil -> nil
      val -> Decimal.mult(val, @vat_rate)
    end
  end

  def generate_user_price(rec, %{current_user: user}) do
    case user[:pricefield] do
      "price1" -> VariantC.generate_price(rec, :price1)
      "price2" -> VariantC.generate_price(rec, :price2)
      "price3" -> VariantC.generate_price(rec, :price3)
      "price4" -> VariantC.generate_price(rec, :price4)
      _ -> nil
    end
  end

  def generate_user_secondary_price(rec, %{current_user: user}) do
    case user[:pricefield] do
      "price1" -> VariantC.generate_price(rec, :price1)
      "price2" -> VariantC.generate_price(rec, :price2)
      "price3" -> VariantC.generate_price(rec, :price3)
      "price4" -> VariantC.generate_price(rec, :price4)
      _ -> nil
    end
  end

  def generate_user_price(_rec, _) do
    nil
  end

  def get_product_query(params) do
    cat = CategoryC.get_category(params["category_id"] |> to_int())

    catlike =
      if cat do
        CategoryC.get_path(cat) <> "%"
      else
        nil
      end

    v_id = params["v_id"] |> to_int()

    query =
      Variant
      |> join(:inner, [v], p in assoc(v, :prod))
      |> join(:left, [v, p], lt in ListType, on: v.source_type == lt.key)
      |> pipe_when(catlike, where([v, p, lt], like(p.path, ^catlike)))
      |> pipe_when(v_id, where([v, p, lt], v.id == ^v_id))
      |> select([v, p, lt], %{
        id: p.id,
        v_id: v.id,
        path: p.path,
        title: p.title,
        img_urls: p.img_urls,
        variant_title: v.variant_title,
        source_price: v.source_price,
        source_type: v.source_type,
        dealer_id: lt.dealer_id
      })
      |> order_by([v, p, lt], asc: v.variant_title)

    query
  end
end
