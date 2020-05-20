defmodule KandiresWeb.Reservation.MailEngine do
  @moduledoc false

  alias Kandires.Mailer
  alias Kandis.Cart
  alias Kandis.Checkout
  alias KandiresWeb.Reservation.Order
  alias Kandis.VisitorSession
  import Bamboo.Email

  require Kandis.KdPipeableLogger

  require Ecto.Query

  # import Kandis.KdHelpers

  def send_notification_mail(subject, text, recipient) do
    text = text <> "\nUTC-Time: " <> (DateTime.utc_now() |> DateTime.to_string())

    mail =
      Bamboo.Email.new_email()
      |> to([recipient])
      |> from({"EVA BLUT", "info@shop.evablut.com"})
      |> subject(subject)
      |> text_body(text)
      |> Mailer.deliver_now()

    recipient |> KdPipeableLogger.info("mail #{subject} sent to")

    {:ok, mail}
  end

  def send_confirmation_mail(recipient) do
    order = %{}

    session = %{"lang" => "de"}
    userid = "d30bbb9c-d244-4b0b-93c6-af500344f1b3"

    cart = Cart.get_augmented_cart_record(userid, session)
    checkout_record = VisitorSession.get_value(userid, "checkout", %{})

    ordercart = Checkout.create_ordercart(cart, session["lang"])

    orderinfo = Checkout.create_orderinfo(checkout_record)
    orderdata = Order.create_orderdata(ordercart, orderinfo)
    orderhtml = Order.create_orderhtml(orderdata, orderinfo)

    mail =
      KandiresWeb.Reservation.Email.confirmation_mail(order, orderhtml)
      |> to([recipient])
      |> Mailer.deliver_now()

    # recipient |> KdPipeableLogger.info("confi sent to")

    {:ok, mail}
  end
end
