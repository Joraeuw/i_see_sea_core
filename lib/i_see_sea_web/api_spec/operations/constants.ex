defmodule ISeeSeaWeb.ApiSpec.Operations.Constants do
  @moduledoc false

  alias ISeeSea.Constants

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema

      tags(["Constants"])

      operation(:picture_type,
        summary: "Picture Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 content_types: %Schema{
                   type: :string,
                   enum: Constants.PictureTypes.content_types()
                 },
                 suffixes: %Schema{type: :string, enum: Constants.PictureTypes.suffixes()}
               }
             }}
        ]
      )

      operation(:jellyfish_quantity,
        summary: "Jellyfish Quantity Ranges",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.JellyfishQuantityRange.values()}
               }
             }}
        ]
      )

      operation(:jellyfish_species,
        summary: "Jellyfish Species",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, example: "dont_know"}
               }
             }}
        ]
      )

      operation(:pollution_type,
        summary: "Pollution Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, example: "oil"}
               }
             }}
        ]
      )

      operation(:report_type,
        summary: "Report Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.ReportType.values()}
               }
             }}
        ]
      )

      operation(:fog_type,
        summary: "Fog Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.FogType.values()}
               }
             }}
        ]
      )

      operation(:sea_swell_type,
        summary: "Sea Swell Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.SeaSwellType.values()}
               }
             }}
        ]
      )

      operation(:wind_type,
        summary: "Wind Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.WindType.values()}
               }
             }}
        ]
      )

      operation(:storm_type,
        summary: "Storm Types",
        responses: [
          ok:
            {"Success", "application/json",
             %Schema{
               type: :object,
               properties: %{
                 values: %Schema{type: :string, enum: Constants.StormType.values()}
               }
             }}
        ]
      )
    end
  end
end
