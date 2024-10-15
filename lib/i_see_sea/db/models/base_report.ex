defmodule ISeeSea.DB.Models.BaseReport do
  @moduledoc false

  alias ISeeSea.DB.Models.OtherReport
  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.User

  alias ISeeSea.Constants.ReportType

  use ISeeSea.DB.DefaultModel,
    default_preloads: [
      :jellyfish_report,
      :meteorological_report,
      :atypical_activity_report,
      :other_report,
      :pictures,
      :user,
      pollution_report: :pollution_types
    ]

  @derive {Flop.Schema,
   filterable: [
     :name,
     :user_id,
     :quantity,
     :species,
     :pollution_types,
     :fog_type,
     :wind_type,
     :sea_swell_type,
     :wind_type,
     :deleted,
     :inserted_at
   ],
   sortable: [
     :id,
     :name,
     :report_date,
     :quantity,
     :species,
     :fog_type,
     :wind_type,
     :sea_swell_type,
     :inserted_at
   ],
   default_order: %{
     order_by: [:id],
     order_directions: [:desc]
   },
   adapter_opts: [
     join_fields: [
       #  Jellyfish fields
       quantity: [
         binding: :jellyfish_report,
         field: :quantity,
         ecto_type: :string
       ],
       species: [
         binding: :species,
         field: :name,
         ecto_type: :string,
         path: [:jellyfish_report, :species]
       ],
       # Pollution fields
       pollution_types: [
         binding: :pollution_types,
         field: :name,
         ecto_type: :string,
         path: [:pollution_report, :pollution_types]
       ],
       # Meteorological fields
       fog_type: [
         binding: :fog_type,
         field: :name,
         ecto_type: :string,
         path: [:meteorological_reports, :fog_type]
       ],
       wind_type: [
         binding: :wind_type,
         field: :name,
         ecto_type: :string,
         path: [:meteorological_reports, :wind_type]
       ],
       sea_swell_type: [
         binding: :sea_swell_type,
         field: :name,
         ecto_type: :string,
         path: [:meteorological_reports, :sea_swell_type]
       ],
       #  Atypical fields
       wind_type: [
         binding: :wind_type,
         field: :name,
         ecto_type: :string,
         path: [:atypical_activity_reports, :wind_type]
       ]
       #  Other fields
     ]
   ]}

  @required_attrs [:user_id, :name, :report_type, :report_date, :longitude, :latitude]
  @allowed_attrs [:comment, :deleted | @required_attrs]

  schema "base_reports" do
    field(:name, :string)
    field(:report_type, :string)
    field(:report_date, :utc_datetime)
    field(:longitude, :float)
    field(:latitude, :float)
    field(:comment, :string)
    field(:deleted, :boolean, default: false)

    belongs_to(:user, User)

    has_one(:jellyfish_report, JellyfishReport, foreign_key: :report_id)
    has_one(:pollution_report, PollutionReport, foreign_key: :report_id)
    has_one(:meteorological_report, MeteorologicalReport, foreign_key: :report_id)
    has_one(:atypical_activity_report, AtypicalActivityReport, foreign_key: :report_id)
    has_one(:other_report, OtherReport, foreign_key: :report_id)

    has_many(:pictures, Picture, foreign_key: :report_id)

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:report_type, ReportType.values())
  end

  def get_user_filtered_paginated_reports(report_type, params, pagination_params, user_id) do
    get_filtered_paginated_reports(
      report_type,
      params,
      pagination_params,
      from(br in __MODULE__, where: br.user_id == ^user_id)
    )
  end

  def get_filtered_paginated_reports(
        report_type,
        params,
        pagination_params,
        initial_from \\ __MODULE__
      )

  def get_filtered_paginated_reports("all", params, pagination_params, initial_from) do
    get_with_filter(params, @default_preloads, pagination_params, initial_from)
  end

  def get_filtered_paginated_reports(report_type, params, pagination_params, initial_from) do
    pagination = Map.merge(%{page: 1, page_size: 10}, pagination_params)
    {query, preloads} = determine_query(initial_from, report_type)

    query
    |> ISeeSea.Flop.validate_and_run(Map.merge(params, pagination), for: __MODULE__)
    |> case do
      {:ok, {entries, %Flop.Meta{total_count: total_count}}} ->
        {:ok, Repo.preload(entries, preloads ++ [:pictures, :user]),
         Map.put(pagination, :total_count, total_count)}

      {:error, %Flop.Meta{}} ->
        {:error, :bad_request}
    end
  rescue
    _ in Ecto.QueryError -> {:error, :bad_request}
  end

  def total_reports do
    from(br in __MODULE__,
      where: br.deleted == false,
      select: %{total_entries: count(br.id), beginning_of_time: min(br.report_date)}
    )
    |> Repo.one()
  end

  defp determine_query(initial_from, "jellyfish") do
    q =
      initial_from
      |> join(:inner, [br], jr in assoc(br, :jellyfish_report), as: :jellyfish_report)
      |> join(:left, [br, jr], s in assoc(jr, :species), as: :species)
      |> distinct(true)

    {q, [jellyfish_report: :species]}
  end

  defp determine_query(initial_from, "pollution") do
    q =
      initial_from
      |> join(:inner, [br], pr in assoc(br, :pollution_report), as: :pollution_report)
      |> join(:left, [br, pr], rt in assoc(pr, :pollution_types), as: :pollution_types)
      |> distinct(true)

    {q, [pollution_report: :pollution_types]}
  end

  defp determine_query(initial_from, "atypical_activity") do
    q =
      initial_from
      |> join(:inner, [br], aar in assoc(br, :atypical_activity_report),
        as: :atypical_activity_report
      )
      |> join(:inner, [br, aar], ft in assoc(aar, :storm_type), as: :storm_type)
      |> distinct(true)

    {q, [atypical_activity_report: :storm_type]}
  end

  defp determine_query(initial_from, "other") do
    q =
      initial_from
      |> join(:inner, [br], o in assoc(br, :other_report), as: :other_report)
      |> distinct(true)

    {q, [:other_report]}
  end

  defp determine_query(initial_from, "meteorological") do
    q =
      initial_from
      |> join(:inner, [br], mr in assoc(br, :meteorological_report), as: :meteorological_report)
      |> join(:inner, [br, mr], ft in assoc(mr, :fog_type), as: :fog_type)
      |> join(:inner, [br, mr], sst in assoc(mr, :sea_swell_type), as: :sea_swell_type)
      |> join(:inner, [br, mr], wt in assoc(mr, :wind_type), as: :wind_type)
      |> distinct(true)

    {q, [meteorological_report: [:fog_type, :sea_swell_type, :wind_type]]}
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(
          %{
            jellyfish_report: jr,
            pollution_report: pr,
            meteorological_report: mr,
            atypical_activity_report: aar,
            other_report: o,
            pictures: pictures,
            user: %User{email: email}
          } = base,
          %Lens{view: Lens.expanded()} = lens
        ) do
      lens = %Lens{lens | view: Lens.from_base()}

      base
      |> Map.from_struct()
      |> Map.take([
        :name,
        :report_type,
        :report_date,
        :longitude,
        :latitude,
        :comment,
        :inserted_at
      ])
      |> Map.merge(%{
        pictures: Enum.map(pictures, &Picture.get_uri!/1),
        user_email: email
      })
      |> Map.merge(override_nil(ISeeSeaWeb.Focus.view(jr, lens)))
      |> Map.merge(override_nil(ISeeSeaWeb.Focus.view(pr, lens)))
      |> Map.merge(override_nil(ISeeSeaWeb.Focus.view(mr, lens)))
      |> Map.merge(override_nil(ISeeSeaWeb.Focus.view(aar, lens)))
      |> Map.merge(override_nil(ISeeSeaWeb.Focus.view(o, lens)))
    end

    defp override_nil(nil), do: %{}
    defp override_nil(entity), do: entity
  end
end
