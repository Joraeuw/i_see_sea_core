defmodule ISeeSea.DB.Logic.ReportOperations do
  @moduledoc false

  alias ISeeSea.DB.Models.OtherReport
  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.BaseReport

  alias ISeeSea.Repo
  alias ISeeSeaWeb.Params.Report

  def create(user, validated_params, picture_upload_function_refs) do
    Repo.transaction(fn ->
      with {:ok, %BaseReport{id: id, report_type: report_type}} <-
             BaseReport.create(
               Map.merge(validated_params, %{user_id: user.id, report_date: DateTime.utc_now()})
             ),
           true <- Enum.all?(picture_upload_function_refs, fn ref -> ref.(id) end),
           {:ok, report} <-
             create_specific_report(id, report_type, validated_params) do
        report
      else
        error -> Repo.rollback(error)
      end
    end)
  end

  def get_total_pages(%{total_count: total_entries, page_size: page_size}) do
    div(total_entries, page_size) + if rem(total_entries, page_size) > 0, do: 1, else: 0
  end

  def retrieve_user_reports_with_live_view_filters(user, report_type, pagination, filters)
      when is_map(filters) do
    filters = Map.put(filters, "user_id", user.id)

    retrieve_reports_with_live_view_filters(
      report_type,
      pagination,
      Map.to_list(Map.drop(filters, ["report_type", "date_range_picker_display_value"])),
      []
    )
  end

  def retrieve_reports_with_live_view_filters(report_type, pagination, filters)
      when is_map(filters) do
    retrieve_reports_with_live_view_filters(
      report_type,
      pagination,
      Map.to_list(Map.drop(filters, ["report_type", "date_range_picker_display_value"])),
      []
    )
  end

  defp retrieve_reports_with_live_view_filters(
         report_type,
         pagination,
         [current_filter | rest],
         built_filter
       ) do
    retrieve_reports_with_live_view_filters(report_type, pagination, rest, [
      parse_live_view_filter(current_filter) | built_filter
    ])
  end

  defp retrieve_reports_with_live_view_filters(report_type, pagination, [], built_filter) do
    not_deleted_filter = %{"field" => "deleted", "value" => false}

    BaseReport.get_filtered_paginated_reports(
      report_type,
      %{filters: [not_deleted_filter | built_filter]},
      pagination
    )
  end

  defp parse_live_view_filter({"start_date", value}) do
    %{"field" => "inserted_at", "op" => ">=", "value" => value}
  end

  defp parse_live_view_filter({"end_date", value}) do
    %{"field" => "inserted_at", "op" => "<=", "value" => value}
  end

  defp parse_live_view_filter({"user_id", value}) do
    %{"field" => "user_id", "op" => "==", "value" => value}
  end

  defp create_specific_report(base_report_id, report_type, %{species: species} = validated_prams)
       when report_type == "jellyfish" do
    with {:ok, jellyfish_report} <-
           JellyfishReport.create(
             Map.merge(validated_prams, %{
               report_id: base_report_id,
               species_id: species
             })
           ) do
      {:ok, jellyfish_report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "meteorological" do
    with {:ok, %{fog_type: fog_type, sea_swell_type: sea_swell_type, wind_type: wind_type}} <-
           Report.validate(:create_meteorological_report, params),
         {:ok, report} <-
           MeteorologicalReport.create(%{
             report_id: base_report_id,
             fog_type_id: fog_type,
             sea_swell_type_id: sea_swell_type,
             wind_type_id: wind_type
           }) do
      {:ok, report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "pollution" do
    with {:ok, pollution_params} <-
           Report.validate(:create_pollution_report, params),
         {:ok, pollution_report} <- PollutionReport.create(%{report_id: base_report_id}),
         :ok <- attach_pollution_types(base_report_id, pollution_params) do
      {:ok,
       pollution_report
       |> Repo.reload!()
       |> Repo.preload([:pollution_types, base_report: [:pictures, :user]])}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "atypical_activity" do
    # create_atypical_activity_report validation Ensures that `comment` was attached to base report
    with {:ok, %{storm_type: storm_type}} <-
           Report.validate(:create_atypical_activity_report, params),
         {:ok, report} <-
           AtypicalActivityReport.create(%{
             report_id: base_report_id,
             storm_type_id: storm_type
           }) do
      {:ok, report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "other" do
    # create_other_report validation Ensures that `comment` was attached to base report
    with {:ok, _} <- Report.validate(:create_other_report, params),
         {:ok, report} <-
           OtherReport.create(%{
             report_id: base_report_id
           }) do
      {:ok, report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp attach_pollution_types(report_id, %{
         pollution_type_oil: pollution_type_oil,
         pollution_type_plastic: pollution_type_plastic,
         pollution_type_biological: pollution_type_biological
       }) do
    if pollution_type_oil do
      PollutionReportPollutionType.create(%{
        pollution_type_id: "oil",
        pollution_report_id: report_id
      })
    end

    if pollution_type_plastic do
      PollutionReportPollutionType.create(%{
        pollution_type_id: "plastic",
        pollution_report_id: report_id
      })
    end

    if pollution_type_biological do
      PollutionReportPollutionType.create(%{
        pollution_type_id: "biological",
        pollution_report_id: report_id
      })
    end

    :ok
  end

  def attach_picture_callback_function(report_id, shape, image_binary, content_type) do
    with {width, height, _} <- shape,
         {:ok, _} <-
           Picture.create(%{
             report_id: report_id,
             file_size: byte_size(image_binary),
             content_type: content_type,
             image_data: image_binary,
             width: width,
             height: height
           }) do
      true
    else
      _ -> false
    end
  end

  #! maybe store image async
  def retrieve_image_binary(path, content_type) do
    with {:ok, image} <- Image.open(path),
         shape <- Image.shape(image),
         {:ok, suffix} <- PictureTypes.get_suffix(content_type),
         {:ok, binary} <- Image.write(image, :memory, suffix: suffix) do
      {binary, shape}
    end
  end

  defp attach_pictures(_, _), do: :ok
end
