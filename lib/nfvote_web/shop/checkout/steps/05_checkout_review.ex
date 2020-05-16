defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutReview do
  @moduledoc false
  @step "review"
  @pageview KandiresWeb.PageView
  use Kandis.Checkout.LiveViewStep
  use Phoenix.LiveView

  @impl true
  def mount(_params, session, socket) do
    vid = session["vid"]
    Kandis.LiveUpdates.subscribe_live_view(vid)

    checkout_record = Kandis.Checkout.get_checkout_record(vid)

    {orderdata, orderinfo, orderhtml} = Kandis.Checkout.preview_order(vid, _context = session)

    form_values = checkout_record

    {:ok,
     assign(socket,
       vid: vid,
       step: @step,
       changeset: changeset_for_this_step(form_values, socket.assigns),
       checkout_record: checkout_record,
       orderhtml: orderhtml,
       orderinfo: orderinfo,
       orderdata: orderdata
     )}
  end
end
