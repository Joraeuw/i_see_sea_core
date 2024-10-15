defmodule ISeeSeaWeb.Responses do
  @moduledoc """
  Handles everything that goes out of the API.
  """
  alias Plug.Conn
  alias Phoenix.Controller
  alias ISeeSeaWeb.Focus
  alias ISeeSeaWeb.Lens

  @default_fail_msg "The requested action has failed."

  def success(conn, payload, view \\ :expanded)

  def success(%Plug.Conn{assigns: assigns} = conn, payload, view) do
    conn
    |> Conn.put_status(200)
    |> Controller.json(Focus.view(payload, %Lens{view: view, user: assigns[:user]}))
  end

  def success_paginated(%Plug.Conn{assigns: assigns} = conn, data, pagination, view \\ :expanded)
      when is_list(data) do
    payload = %{
      entries: data,
      pagination: pagination
    }

    conn
    |> Conn.put_status(200)
    |> Controller.json(Focus.view(payload, %Lens{view: view, user: assigns[:user]}))
  end

  def success_create(%Plug.Conn{assigns: assigns} = conn, payload, view \\ :expanded) do
    conn
    |> Conn.put_status(201)
    |> Controller.json(Focus.view(payload, %Lens{view: view, user: assigns[:user]}))
  end

  def success_binary(conn, binary, content_type) do
    conn
    |> Conn.put_resp_content_type(content_type)
    |> Conn.resp(200, binary)
  end

  def success_empty(conn) do
    conn
    |> Conn.put_status(204)
    |> Controller.text("")
  end

  def error(conn, {:error, %Ecto.Changeset{errors: errors}}) do
    unprocessable_entity(conn, @default_fail_msg, errors)
  end

  def error(conn, {:error, :unprocessable_entity}) do
    unprocessable_entity(conn, @default_fail_msg)
  end

  def error(conn, {:error, :bad_request}) do
    bad_request(conn, @default_fail_msg)
  end

  def error(conn, {:error, :bad_request, reason}) do
    bad_request(conn, @default_fail_msg, reason)
  end

  def error(conn, {:error, :unauthorized}) do
    unauthorized(conn, @default_fail_msg)
  end

  def error(conn, {:error, :unauthorized, reason}) do
    unauthorized(conn, @default_fail_msg, reason)
  end

  def error(conn, {:error, :forbidden}) do
    forbidden(conn, @default_fail_msg)
  end

  def error(conn, {:error, :not_found}) do
    not_found(conn, @default_fail_msg)
  end

  def error(conn, {:error, :not_found, reason}) when is_atom(reason) do
    not_found(conn, @default_fail_msg, translate(@locale, "responses.entity_not_found"))
  end

  def error(conn, {:error, :not_found, reason}) do
    not_found(conn, @default_fail_msg, reason)
  end

  defp unauthorized(
         conn,
         message,
         reason \\ translate(@locale, "responses.missing_credentials")
       ) do
    conn
    |> Conn.put_status(401)
    |> error_response(message, reason)
  end

  defp forbidden(conn, message, reason \\ translate(@locale, "responses.no_access")) do
    conn
    |> Conn.put_status(403)
    |> error_response(message, reason)
  end

  defp bad_request(conn, message, reason \\ translate(@locale, "responses.wrong_syntax")) do
    conn
    |> Conn.put_status(400)
    |> error_response(message, reason)
  end

  defp unprocessable_entity(conn, message) do
    conn
    |> Conn.put_status(422)
    |> error_response(message, translate(@locale, "responses.sth_wrong"))
  end

  defp unprocessable_entity(conn, message, errors) do
    errors = Enum.sort(errors)

    reason =
      (Enum.map_join(errors, ", ", fn {k, {v, _}} -> Atom.to_string(k) <> " " <> v end) <> ".")
      |> String.capitalize()

    errors =
      for {k, {v, _}} <- errors do
        %{k => v}
      end

    conn
    |> Conn.put_status(422)
    |> error_response(message, reason, errors)
  end

  defp not_found(conn, message, reason \\ translate(@locale, "responses.no_resource")) do
    conn
    |> Conn.put_status(404)
    |> error_response(message, reason)
  end

  defp error_response(conn, message, reason) do
    error = %{
      message: String.replace(message, "_", " "),
      reason: reason
    }

    Controller.json(conn, error)
  end

  defp error_response(conn, message, reason, errors) do
    error = %{
      message: String.replace(message, "_", " "),
      reason: reason,
      errors: errors
    }

    Controller.json(conn, error)
  end
end
