defmodule KandiresWeb.Reservation.Email do
  use Bamboo.Phoenix, view: KandiresWeb.Reservation.EmailView

  def confirmation_mail(order, orderhtml) do
    base_email()
    |> subject("Your Order")
    |> assign(:order, order)
    |> assign(:orderhtml, orderhtml)
    |> render(:confirmation_mail)
  end

  defp base_email do
    new_email()
    |> from("EVA BLUT<info@shop.evablut.com>")
    |> put_header("Reply-To", "shop@evablut.com")
    # This will use the "email.html.eex" file as a layout when rendering html emails.
    # Plain text emails will not use a layout unless you use `put_text_layout`
    |> put_html_layout({KandiresWeb.LayoutView, "email.html"})
  end
end
