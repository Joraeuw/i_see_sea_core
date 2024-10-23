defmodule ISeeSeaWeb.Live.CreateReportPanel do
  alias ISeeSea.Helpers.Broadcaster
  alias ISeeSea.DB.Logic.ReportOperations
  use ISeeSeaWeb, :live_component

  require ISeeSea.Constants.ReportType, as: ReportType

  alias ISeeSeaWeb.CoreComponents
  alias ISeeSea.Constants
  alias ISeeSea.Constants.StormType
  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.DB.Models.JellyfishSpecies
  alias ISeeSeaWeb.Params.Report

  @impl true
  def mount(socket) do
    socket =
      socket
      |> allow_upload(:pictures,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 3,
        max_file_size: 5_000_000
      )
      |> assign(
        form: to_form(%{}, as: "report_params"),
        report_type: ReportType.jellyfish(),
        check_errors: false,
        is_location_selected: false
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="create-report-panel"
      data-is-open={@create_report_toolbox_is_open}
      phx-hook="DetectClick"
      phx-target={@myself}
      class={[
        "z-50 bg-white self-center flex flex-col items-center space-y-3 space-x-5",
        "md:h-11/12 md:max-w-1/3 md:m-2 md:self-start p-3 rounded-md",
        if(not @create_report_toolbox_is_open, do: "hidden")
      ]}
    >
      <CoreComponents.simple_form
        for={@form}
        form_class="flex justify-center"
        id="create-report-form"
        phx-submit="create_report"
        phx-change="verify_create_report_params"
        phx-target={@myself}
        method="post"
        class="z-50 bg-white self-center flex flex-col items-center space-y-3
            md:h-11/12 md:max-w-1/3 md:m-2 md:self-start p-3 rounded-md"
      >
        <.error :if={!is_user_verified(@current_user)}>
          You cannot submit reports until you verify your account!<br />
          Please check <%= if is_user_logged(@current_user), do: @current_user.email %>.
        </.error>
        <.error :if={@check_errors}>
          You have not selected a location.
        </.error>

        <CoreComponents.input field={@form[:report_type]} value={@report_type} type="hidden" />
        <CoreComponents.input field={@form[:longitude]} type="hidden" required />
        <CoreComponents.input field={@form[:latitude]} type="hidden" required />
        <.create_report_window
          form={@form}
          report_type={@report_type}
          locale={@locale}
          is_user_verified={is_user_verified(@current_user)}
        />

        <CoreComponents.input
          type="textarea"
          field={@form[:comment]}
          class="textarea h-25 w-[260px] md:w-[320px] max-h-40"
          placeholder="Comment..."
          disabled={!is_user_verified(@current_user)}
        />

        <Phoenix.Component.live_file_input
          upload={@uploads.pictures}
          class="file-input w-full max-w-xs"
          disabled={!is_user_verified(@current_user)}
        />
        <:actions>
          <CoreComponents.button
            phx-disable-with="Creating a report..."
            class="btn w-[130px]"
            disabled={!is_user_verified(@current_user)}
          >
            Submit
          </CoreComponents.button>
          <div
            class={
              ["tooltip"] ++ [if(@is_location_selected, do: "tooltip-success", else: "tooltip-error")]
            }
            data-tip={
              if @is_location_selected,
                do: "You have already selected a location.",
                else: "You have not selected a location yet."
            }
          >
            <button
              type="button"
              id="select-location-button"
              phx-disable-with="Selecting a location..."
              phx-click="select_location"
              phx-hook="LeafletUserLocationHook"
              phx-target={@myself}
              disabled={!is_user_verified(@current_user)}
              class={
                ["btn_sucsess w-[130px] h-[48px]"] ++
                  [if(not @is_location_selected, do: "btn_delete w-[131px] h-[48px]")]
              }
            >
              Set Location
            </button>
          </div>
        </:actions>
        <div class="flex flex-row items-start space-x-4">
          <%= for entry <- @uploads.pictures.entries do %>
            <article class="upload-entry">
              <figure class="relative align-middle justify-center group">
                <.live_img_preview entry={entry} class="relative h-10 z-0" />
                <button
                  type="button"
                  class="absolute z-10 h-10 w-10 opacity-0 group-hover:opacity-100 transition-opacity duration-200 ease-in-out top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2"
                  phx-target={@myself}
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  <img class="w-full h-full" src="/images/create-report/remove_image_icon.svg" />
                </button>
              </figure>

              <%= for err <- upload_errors(@uploads.pictures, entry) do %>
                <p class="alert alert-danger"><%= error_to_string(err) %></p>
              <% end %>
            </article>
          <% end %>
        </div>
      </CoreComponents.simple_form>
    </div>
    """
  end

  attr :report_type, :string, required: true
  attr :form, :map, required: true
  attr :locale, :string, required: true
  attr :is_user_verified, :boolean, required: true

  def create_report_window(%{report_type: ReportType.jellyfish()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>

    <CoreComponents.input
      field={@form[:name]}
      type="text"
      placeholder="Report Name"
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:species]}
      prompt="Select Species"
      options={JellyfishSpecies.values()}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:quantity]}
      prompt="Select Range"
      options={JellyfishQuantityRange.values()}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.atypical_activity()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder="Report Name"
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:storm_type]}
      prompt="Storm Type"
      options={StormType.values()}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.meteorological()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder="Report Name"
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:fog_type]}
      prompt="Fog Type"
      options={Constants.FogType.values()}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:wind_type]}
      prompt="Wind Type"
      options={Constants.WindType.values()}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:sea_swell_type]}
      prompt="Sea Swell Type"
      options={Constants.SeaSwellType.values()}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.pollution()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder="Report Name"
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <div class="flex flex-row space-x-3">
      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_oil]}
        label="Oil"
        class="checkbox"
        disabled={!@is_user_verified}
      />

      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_plastic]}
        label="Plastic"
        class="checkbox"
        disabled={!@is_user_verified}
      />
      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_biological]}
        label="Biological"
        class="checkbox"
        disabled={!@is_user_verified}
      />
    </div>
    """
  end

  def create_report_window(%{report_type: ReportType.other()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder="Report Name"
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(assigns) do
    ~H"""
    """
  end

  @impl true
  def handle_event("create_report", %{"report_params" => params}, socket) do
    changeset_signature = String.to_atom("create_#{socket.assigns.report_type}_report")

    Report.changeset(changeset_signature, params)
    |> case do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:noreply,
         socket
         |> assign(
           form: to_form(Map.put(changeset, :action, :validate), as: "report_params"),
           check_errors: true
         )}

      %Ecto.Changeset{valid?: true} ->
        images =
          consume_uploaded_entries(socket, :pictures, fn %{path: path},
                                                         %{client_type: content_type} ->
            {img_binary, shape} = ReportOperations.retrieve_image_binary(path, content_type)

            upload_pictures_callback = fn report_id ->
              ReportOperations.attach_picture_callback_function(
                report_id,
                shape,
                img_binary,
                content_type
              )
            end

            {:ok, upload_pictures_callback}
          end)

        ReportOperations.create(
          socket.assigns.current_user,
          ExUtils.Map.atomize_keys(params, deep: true),
          images
        )
        |> case do
          {:ok, report} ->
            send(self(), {:update_flash, {:info, "Report created successfully!"}})

            socket =
              socket
              |> assign(form: to_form(%{}, as: "report_params"))
              |> push_event("report_created", %{})

            Broadcaster.broadcast!("reports:updates", "add_marker", report, translate: true)

            {:noreply, socket}

          _ ->
            send(
              self(),
              {:update_flash,
               {:error,
                "Something went wrong when creating your report. Please try again. If the error persist contact us."}}
            )

            {:noreply, assign(socket, form: to_form(%{}, as: "report_params"))}
        end
    end
  end

  def handle_event("verify_create_report_params", %{"report_params" => params}, socket) do
    changeset_signature = String.to_atom("create_#{socket.assigns.report_type}_report")

    changeset = Report.changeset(changeset_signature, params)
    socket = assign(socket, form: to_form(changeset, as: "report_params"))

    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :pictures, ref)}
  end

  def handle_event("select_location", _params, socket) do
    send(self(), :select_location)

    {:noreply, socket}
  end

  def handle_event("location_selected", %{"lat" => lat, "lng" => lng}, socket) do
    params =
      socket.assigns.form.params
      |> Map.put("latitude", lat)
      |> Map.put("longitude", lng)

    changeset_signature = String.to_atom("create_#{socket.assigns.report_type}_report")
    changeset = Report.changeset(changeset_signature, params)

    send(self(), :location_selected)

    socket =
      assign(socket,
        form: to_form(Map.put(changeset, :action, :validate), as: "report_params")
      )

    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
