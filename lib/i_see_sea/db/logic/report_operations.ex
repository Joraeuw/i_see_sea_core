defmodule ISeeSea.DB.Logic.ReportOperations do
  @moduledoc false

  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.PollutionType

  alias ISeeSea.Repo
  alias ISeeSea.Helpers.With
  alias ISeeSeaWeb.Params.Report

  def create(user, %{pictures: pictures} = validated_base, params) do
    Repo.transaction(fn ->
      with {:ok, %BaseReport{id: id, report_type: report_type}} <-
             BaseReport.create(
               Map.merge(validated_base, %{user_id: user.id, report_date: DateTime.utc_now()})
             ),
           :ok <- attach_pictures(id, pictures),
           {:ok, report} <- create_specific_report(id, report_type, params) do
        report
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "jellyfish" do
    with {:ok, %{species: species} = validated_prams} <-
           Report.validate(:create_jellyfish_report, params),
         {:ok, jellyfish_report} <-
           JellyfishReport.create(
             Map.merge(validated_prams, %{report_id: base_report_id, species_id: species})
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
    with {:ok, %{pollution_types: pollution_types}} <-
           Report.validate(:create_pollution_report, params),
         {:ok, pollution_report} <- PollutionReport.create(%{report_id: base_report_id}),
         :ok <-
           With.check(
             attach_pollution_types(base_report_id, pollution_types),
             :failed_to_attach_pollution_type
           ) do
      {:ok,
       pollution_report
       |> Repo.reload!()
       |> Repo.preload([:pollution_types, base_report: :pictures])}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "atypical_activity" do
    # create_atypical_activity_report validation Ensures that `comment` was attached to base report
    with {:ok, _} <- Report.validate(:create_atypical_activity_report, params),
         {:ok, report} <-
           AtypicalActivityReport.create(%{
             report_id: base_report_id
           }) do
      {:ok, report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp attach_pollution_types(report_id, pollution_types) do
    Enum.all?(pollution_types, fn pollution_type_name ->
      with {:ok, %PollutionType{name: name}} <- PollutionType.get(pollution_type_name),
           {:ok, _} <-
             PollutionReportPollutionType.create(%{
               pollution_type_id: name,
               pollution_report_id: report_id
             }) do
        true
      else
        _ -> false
      end
    end)
  end

  defp attach_pictures(report_id, pictures) do
    Enum.all?(pictures, fn %Plug.Upload{content_type: content_type, path: path} ->
      with {:ok, image} <- Image.open(path),
           {width, height, _} <- Image.shape(image),
           {:ok, suffix} <- PictureTypes.get_suffix(content_type),
           {:ok, img_binary} <-
             Image.write(image, :memory, suffix: suffix, minimize_file_size: true),
           {:ok, _} <-
             Picture.create(%{
               report_id: report_id,
               file_size: byte_size(img_binary),
               content_type: content_type,
               image_data: img_binary,
               width: width,
               height: height
             }) do
        true
      else
        _ -> false
      end
    end)
    |> if do
      :ok
    else
      {:error, :image_not_uploaded}
    end
  end
end
