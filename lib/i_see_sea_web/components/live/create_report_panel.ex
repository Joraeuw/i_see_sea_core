defmodule ISeeSeaWeb.Live.CreateReportPanel do
  alias ISeeSea.Helpers.Broadcaster
  alias ISeeSea.DB.Logic.ReportOperations
  use ISeeSeaWeb, :live_component

  require ISeeSea.Constants.ReportType, as: ReportType
  require Logger
  alias ISeeSeaWeb.CoreComponents
  alias ISeeSea.Constants
  alias ISeeSea.Constants.StormType
  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.DB.Models.JellyfishSpecies
  alias ISeeSeaWeb.Params.Report

  import ISeeSeaWeb.Trans

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
        is_location_selected: false,
        is_dragging_over: false
      )

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    form_params = Map.get(socket.assigns.form, :params, %{})

    updated_form_params =
      if assigns.user_selected_location do
        Map.merge(form_params, %{
          "latitude" => form_params["latitude"] || assigns.user_selected_location.lat,
          "longitude" => form_params["longitude"] || assigns.user_selected_location.lon
        })
      else
        form_params
      end

    report_type = assigns.report_type || socket.assigns.report_type
    changeset_signature = String.to_atom("create_#{report_type}_report")

    changeset = Report.changeset(changeset_signature, updated_form_params)

    new_socket =
      assign(socket,
        form: to_form(changeset, as: "report_params"),
        is_location_selected:
          if(socket.assigns.is_location_selected || assigns.user_selected_location,
            do: true,
            else: false
          ),
        create_report_toolbox_is_open: assigns.create_report_toolbox_is_open,
        current_user: assigns.current_user,
        locale: assigns.locale,
        report_type: report_type,
        is_selecting_location: assigns.is_selecting_location
      )

    {:ok, new_socket}
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
        "z-50 bg-white self-center flex flex-col items-center space-y-3 space-x-5 shadow-md",
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
          <%= translate(@locale, "create_report.no_verification_no_reports") %><br />
          <%= translate(@locale, "create_report.please_check") %> <%= if is_user_logged(
                                                                           @current_user
                                                                         ),
                                                                         do: @current_user.email %>.
        </.error>
        <.error :if={@check_errors}>
          <%= translate(@locale, "create_report.no_location") %>
        </.error>

        <CoreComponents.input field={@form[:report_type]} value={@report_type} type="hidden" />
        <CoreComponents.input field={@form[:longitude]} type="hidden" required />
        <CoreComponents.input field={@form[:latitude]} type="hidden" required />
        <h2 class="text-2xl font-semibold mb-4">
          <%= translate(@locale, "create_report.submit_a") %><%= translate(
            @locale,
            "base_report.report_type.#{@report_type}"
          ) %>
          <%= translate(
            @locale,
            "create_report.report"
          ) %>
        </h2>
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
          placeholder={translate(@locale, "create_report.comment")}
          disabled={!is_user_verified(@current_user)}
        />
        <div>
          <div class="relative flex flex-col w-[320px]">
            <div
              phx-drop-target={@uploads.pictures.ref}
              id="picture_drop_container"
              phx-hook="DragAndDropHook"
              class={[
                "flex flex-row items-center justify-center border-2 border-dashed border-gray-300 bg-white rounded-md p-4",
                if(@is_dragging_over, do: "!bg-blue-100")
              ]}
            >
              <div class="flex flex-col items-center">
                <label class="flex cursor-pointer size-6" for={@uploads.pictures.ref}>
                  <img src="/images/drag-drop.svg" />
                </label>
                <label class="flex cursor-pointer w-40" for={@uploads.pictures.ref}>
                  <span class="text-center text-base font-semibold text-gray-700 underline">
                    <%= translate(@locale, "home.drag_prompt") %>
                  </span>
                </label>
              </div>

              <div class="flex flex-col space-y-1 items-end h-32 overflow-y-auto">
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
            </div>
          </div>
          <div class="hidden">
            <Phoenix.Component.live_file_input
              upload={@uploads.pictures}
              class="file-input w-full max-w-xs"
              disabled={!is_user_verified(@current_user)}
            />
          </div>
        </div>
        <:actions>
          <div
            class={
              ["tooltip w-full"] ++
                [if(@is_location_selected, do: "tooltip-success", else: "tooltip-error")]
            }
            data-tip={
              if not @is_location_selected,
                do: translate(@locale, "create_report.no_location")
            }
          >
            <CoreComponents.button
              phx-disable-with={translate(@locale, "home.creating_report")}
              class="btn w-full"
              disabled={!is_user_verified(@current_user) || !@is_location_selected}
            >
              <%= translate(@locale, "create_report.submit") %>
            </CoreComponents.button>
          </div>
          <div
            class={
              ["tooltip"] ++
                [if(@is_location_selected, do: "tooltip-success", else: "tooltip-error")]
            }
            data-tip={
              if not @is_location_selected,
                do: translate(@locale, "create_report.no_location")
            }
          >
            <button
              type="button"
              id="select-location-button"
              phx-click="select_location"
              phx-target={@myself}
              phx-hook="LeafletUserLocationHook"
              disabled={!is_user_verified(@current_user)}
              class={[
                "flex items-center justify-center",
                "w-12 h-12",
                "rounded-full",
                if(@is_location_selected, do: "bg-success", else: "bg-error"),
                "hover:bg-opacity-80",
                "focus:outline-none",
                "transition duration-150 ease-in-out"
              ]}
            >
              <img
                src="/images/marker-icons/pin.svg"
                alt={translate(@locale, "create_report.set_location")}
                class="w-6 h-6"
              />
            </button>
          </div>
        </:actions>
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
    <CoreComponents.input
      field={@form[:name]}
      type="text"
      placeholder={translate(@locale, "create_report.report_name")}
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:species]}
      prompt={translate(@locale, "jellyfish_report.species.title")}
      options={jellyfish_species_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:quantity]}
      prompt={translate(@locale, "jellyfish_report.quantity.title")}
      options={jellyfish_quantities_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.atypical_activity()} = assigns) do
    ~H"""
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder={translate(@locale, "create_report.report_name")}
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:storm_type]}
      prompt={translate(@locale, "atypical_report.storm_type_id.title")}
      options={atypical_storm_type_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.meteorological()} = assigns) do
    ~H"""
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder={translate(@locale, "create_report.report_name")}
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:fog_type]}
      prompt={translate(@locale, "meteorological_report.fog_type_id.title")}
      options={fog_type_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:wind_type]}
      prompt={translate(@locale, "meteorological_report.wind_type_id.title")}
      options={wind_type_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    <CoreComponents.input
      type="select"
      class="select w-[260px] md:w-[320px] max-w-xs"
      field={@form[:sea_swell_type]}
      prompt={translate(@locale, "meteorological_report.sea_swell_type_id.title")}
      options={sea_swell_type_options(@locale)}
      disabled={!@is_user_verified}
      required
    />
    """
  end

  def create_report_window(%{report_type: ReportType.pollution()} = assigns) do
    ~H"""
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder={translate(@locale, "create_report.report_name")}
      class="input w-full max-w-xs"
      disabled={!@is_user_verified}
      required
    />
    <div class="flex flex-row space-x-3">
      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_oil]}
        label={translate(@locale, "pollution_report.options.oil")}
        class="checkbox"
        disabled={!@is_user_verified}
      />

      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_plastic]}
        label={translate(@locale, "pollution_report.options.plastic")}
        class="checkbox"
        disabled={!@is_user_verified}
      />
      <CoreComponents.input
        type="checkbox"
        field={@form[:pollution_type_biological]}
        label={translate(@locale, "pollution_report.options.bio")}
        class="checkbox"
        disabled={!@is_user_verified}
      />
    </div>
    """
  end

  def create_report_window(%{report_type: ReportType.other()} = assigns) do
    ~H"""
    <CoreComponents.input
      type="text"
      field={@form[:name]}
      placeholder={translate(@locale, "create_report.report_name")}
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

    IO.inspect(params, label: __MODULE__)

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
            Logger.info("""
            Report created successfully.
            User: #{socket.assigns.current_user.email}
            Report Type: #{socket.assigns.report_type}
            """)

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
        form: to_form(Map.put(changeset, :action, :validate), as: "report_params"),
        is_location_selected: true
      )

    {:noreply, socket}
  end

  def handle_event("file-dragging", %{"over" => over}, socket) do
    {:noreply, assign(socket, :is_dragging_over, over)}
  end

  defp jellyfish_species_options(locale) do
    JellyfishSpecies.values()
    |> Enum.map(&{translate(locale, "jellyfish_report.species.#{&1}"), &1})
  end

  defp jellyfish_quantities_options(locale) do
    JellyfishQuantityRange.values()
    |> Enum.map(&{translate(locale, "jellyfish_report.quantity.#{&1}"), &1})
  end

  defp atypical_storm_type_options(locale) do
    StormType.values()
    |> Enum.map(&{translate(locale, "atypical_report.storm_type_id.#{&1}"), &1})
  end

  defp fog_type_options(locale) do
    Constants.FogType.values()
    |> Enum.map(&{translate(locale, "meteorological_report.fog_type_id.#{&1}"), &1})
  end

  defp wind_type_options(locale) do
    Constants.WindType.values()
    |> Enum.map(&{translate(locale, "meteorological_report.wind_type_id.#{&1}"), &1})
  end

  defp sea_swell_type_options(locale) do
    Constants.SeaSwellType.values()
    |> Enum.map(&{translate(locale, "meteorological_report.sea_swell_type_id.#{&1}"), &1})
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
