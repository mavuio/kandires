defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutWelcome do
  @moduledoc false
  @step "welcome"
  @pageview KandiresWeb.PageView
  use Kandis.Checkout.LiveViewStep
  use Phoenix.LiveView

  @impl true
  def mount(_params, session, socket) do
    vid = session["vid"]
    checkout_record = Kandis.Checkout.get_checkout_record(vid)
    Kandis.LiveUpdates.subscribe_live_view(vid)

    {:ok,
     assign(socket,
       vid: vid,
       step: @step,
       changeset: changeset_for_this_step(checkout_record, socket.assigns),
       checkout_record: checkout_record
     )}
  end

  @impl true
  def changeset_for_this_step(values, context) do
    _dummy = super(values, context)
    data = %{}

    types = %{
      pkt_01_01: :string
    }

    {data, types}
    |> Ecto.Changeset.cast(values, Map.keys(types))
    |> Ecto.Changeset.validate_required([:pkt_01_01],
      message: "Bitte wähle eine Option"
    )
  end
end
