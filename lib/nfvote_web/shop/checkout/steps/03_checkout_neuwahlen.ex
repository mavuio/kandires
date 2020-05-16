defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutNeuwahlen do
  @moduledoc false
  @step "neuwahlen"
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
      pkt_02_01: :string,
      pkt_02_02: :string,
      pkt_02_03: :string,
      pkt_02_04: :string,
      pkt_02_05: :string,
      pkt_02_06: :string,
      pkt_02_07: :string,
      pkt_02_08: :string,
      pkt_02_09: :string,
      pkt_02_10: :string,
      pkt_02_11: :string,
      pkt_02_12: :string
    }

    {data, types}
    |> Ecto.Changeset.cast(values, Map.keys(types))
    |> Ecto.Changeset.validate_required(
      [
        :pkt_02_01,
        :pkt_02_02,
        :pkt_02_03,
        :pkt_02_04,
        :pkt_02_05,
        :pkt_02_06,
        :pkt_02_07,
        :pkt_02_08,
        :pkt_02_09,
        :pkt_02_10,
        :pkt_02_11,
        :pkt_02_12
      ],
      message: "Bitte wähle eine Option ➜ "
    )
  end
end
