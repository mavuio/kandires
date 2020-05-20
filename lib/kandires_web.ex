defmodule KandiresWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use KandiresWeb, :controller
      use KandiresWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: KandiresWeb
      import Plug.Conn
      import KandiresWeb.Gettext
      alias KandiresWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Controller

      def action(conn, _) do
        # merge assigns into params, assigns have atoms, params strings as keys
        args = [conn, Map.merge(conn.params, conn.assigns)]
        apply(__MODULE__, action_name(conn), args)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/kandires_web/templates",
        namespace: KandiresWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
      import Phoenix.LiveView.Helpers

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Surface

      import KandiresWeb.ErrorHelpers
      import KandiresWeb.Gettext
      alias KandiresWeb.Router.Helpers, as: Routes
      import KandiresWeb.InputHelpers
      import KandiresWeb.MdcInputHelpers
      import KandiresWeb.BulmaInputHelpers

      def render_shared(template, assigns \\ []) do
        render(KandiresWeb.SharedView, template, assigns)
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import KandiresWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
