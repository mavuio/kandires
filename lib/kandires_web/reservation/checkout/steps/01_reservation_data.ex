defmodule KandiresWeb.Reservation.Steps.ReservationData do
  @moduledoc false
  @step "data"
  @pageview KandiresWeb.EmbedView

  use KandiresWeb.EmbedStep
  use Phoenix.LiveView, layout: {KandiresWeb.LayoutView, "embed.html"}

  @impl true
  def mount(_params, session, socket) do
    vid = session["vid"]
    checkout_record = Kandis.Checkout.get_checkout_record(vid)
    Kandis.LiveUpdates.subscribe_live_view(vid)

    {:ok,
     assign(socket,
       vid: vid,
       lang: session["lang"],
       pathname: session["pathname"],
       changeset: changeset_for_this_step(checkout_record, socket.assigns),
       checkout_record: checkout_record
     )}
  end

  @impl true
  def changeset_for_this_step(values, context) do
    _dummy = super(values, context)
    data = %{}
    types = %{pickup: :string, delivery_type: :string}

    {data, types}
    |> Ecto.Changeset.cast(values, Map.keys(types))
    |> Ecto.Changeset.validate_required([:pickup])
  end

  @impl true
  def handle_event("save", msg = %{"step_data" => %{"pickup" => "yes"}}, socket) do
    msg =
      put_in(msg["step_data"]["delivery_type"], "pickup")
      |> IO.inspect(label: "mwuits-debug 2020-04-13_17:51 ADDED delivery_type 'pickup'")

    super_handle_event("save", msg, socket)
  end
end
