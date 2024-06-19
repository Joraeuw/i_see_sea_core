defmodule ISeeSea.Events.UserEmailVerification do
  @moduledoc """
  Triggers if user hasn't verified account after 7 days.
  The unverified users are removed!
  """

  use Oban.Worker, queue: :user_email_verification

  import Ecto.Query, warn: false

  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.User

  def start_tracker(user_id, confirmation_token) do
    %{user_id: user_id, token: confirmation_token}
    |> __MODULE__.new(
      schedule_in: Timex.Duration.from_days(7) |> Timex.Duration.to_seconds(truncate: true)
    )
    |> Oban.insert()
  end

  def verify_email(token) do
    Repo.transaction(fn ->
      with {:ok, %{"user_id" => user_id}} <- get_scheduled(token),
           {:ok, _} <- User.update(user_id, %{verified: true}),
           {:ok, _} <- delete_job(user_id, token) do
        :ok
      else
        {:error, error} -> Repo.rollback(error)
        error -> Repo.rollback(error)
      end
    end)
    |> case do
      {:ok, :ok} ->
        :ok

      error ->
        error
    end
  end

  def get_scheduled(token) do
    query =
      from(j in Oban.Job,
        where: fragment("args->>'token'") == ^token,
        where: j.state in ~w[scheduled]
      )

    case Repo.one(query) do
      nil -> {:error, :not_found}
      %Oban.Job{args: args} -> {:ok, args}
    end
  end

  defp delete_job(user_id, token) do
    query =
      from(j in Oban.Job,
        where:
          fragment("args->>'user_id' = ?", ^Integer.to_string(user_id)) and
            fragment("args->>'token' = ?", ^token),
        where: j.state in ~w[scheduled]
      )

    case Repo.all(query) do
      [] ->
        {:error, :not_found, :user_confirmation_job}

      [job] ->
        Repo.delete!(job)
        {:ok, job}
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    case User.get(user_id) do
      {:ok, %User{} = u} ->
        User.delete(u)

      {:error, :not_found, _} ->
        :ok

      error ->
        {:error, error}
    end
  end
end
