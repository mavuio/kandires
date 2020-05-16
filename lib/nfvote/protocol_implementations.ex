require Protocol

# Protocol.derive(Jason.Encoder, Nfworker.Abonennt, except: [:__meta__, :event_history])

# Protocol.derive(
#   Jason.Encoder,
#   Nfworker.NewsletterMail,
#   except: [:__meta__, :delivery_statuses, :text_body, :html_body]
# )

Protocol.derive(Jason.Encoder, Ecto.Schema.Metadata, except: [:__meta__])

Protocol.derive(Jason.Encoder, Ecto.Association.NotLoaded, except: [:__meta__])

Protocol.derive(Jason.Encoder, Scrivener.Page, except: [:__meta__])
