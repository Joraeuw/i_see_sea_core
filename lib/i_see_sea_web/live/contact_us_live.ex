defmodule ISeeSeaWeb.ContactUsLive do
  use ISeeSeaWeb, :live_view
  require Logger
  alias ISeeSea.Emails

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      if(socket.assigns.current_user) do
        to_form(%{
          email: socket.assigns.current_user.email,
          name: socket.assigns.current_user.first_name,
          phone: socket.assigns.current_user.phone_number
        })
      else
        to_form(%{})
      end

    {:ok, assign(socket, changeset: changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row gap-6 max-w-4xl p-2">
      <div class="bg-gray-50 rounded-lg shadow-lg p-6 w-full h-full lg:w-1/2">
        <.simple_form for={@changeset} phx-submit="send_message" class="space-y-1" method="post">
          <.input
            type="text"
            field={@changeset[:name]}
            label={translate(@locale, "contact_us.form.name")}
            required
            class="w-full mt-0"
          />
          <.input
            type="email"
            field={@changeset[:email]}
            label={translate(@locale, "contact_us.form.email")}
            required
            class="w-full mt-0"
          />
          <.input
            type="tel"
            field={@changeset[:phone]}
            label={translate(@locale, "contact_us.form.phone")}
            class="w-full mt-0"
          />
          <.input
            type="text"
            field={@changeset[:organization]}
            label={translate(@locale, "contact_us.form.organization")}
            class="w-full mt-0"
          />
          <.input
            type="textarea"
            field={@changeset[:message]}
            label="Message"
            required
            class="w-full mt-0 h-32"
          />
          <div class="flex justify-center mt-4">
            <button
              type="submit"
              class="btn bg-teal-500 text-white rounded w-full md:w-auto px-4 py-2"
            >
              <%= translate(@locale, "contact_us.submit") %>
            </button>
          </div>
        </.simple_form>
      </div>

      <div class="w-full lg:w-1/2 space-y-4 p-6">
        <h2 class="text-xl font-semibold"><%= translate(@locale, "contact_us.title") %></h2>
        <p>
          If you have a general query about the Iliad project, you can get in touch with the project team using the contact form.
        </p>
        <p>
          If your question is specific, please see our
          <a href="/partners" class="text-blue-600 underline">partners page</a>
          for individual contact details.
        </p>
        <p>
          This project has received funding from the European Commission’s Horizon 2020 Research and Innovation programme under grant agreement No 101037643. The information and views of this website lie entirely with the authors. The European Commission is not responsible for any use that may be made of the information it contains.
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_message", params, socket) do
    {flag, message} =
      case Emails.contact_us_email(params) do
        {:ok, _} ->
          {:info, translate(socket.assigns.locale, "contact_us.success")}

        {:error, reason} ->
          Logger.error(
            "[#{__MODULE__}] An error occurred when sending a message. Reason: #{reason}"
          )

          {:error, translate(socket.assigns.locale, "contact_us.failure")}
      end

    socket =
      socket
      |> assign(:changeset, to_form(%{}))
      |> put_flash(flag, message)

    {:noreply, socket}
  end
end
