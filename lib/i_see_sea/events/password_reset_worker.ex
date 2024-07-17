defmodule ISeeSea.Events.PasswordResetWorker do
  @moduledoc """
  Triggers if user hasn't opened the password reset link in 24 hours.
  The password reset link is removed.
  """
  use Oban.Worker, queue: :password_reset_worker, max_attempts: 1

  import Ecto.Query, warn: false

  alias ISeeSea.DB.Models.User
  alias ISeeSea.Repo

  def start_tracker(user_id, confirmation_token) do
    %{user_id: user_id, token: confirmation_token}
    |> __MODULE__.new(
      schedule_in: Timex.Duration.from_days(1) |> Timex.Duration.to_seconds(truncate: true)
    )
    |> Oban.insert()
  end

  def reset_password(confirmation_token, new_password) do
    Repo.transaction(fn ->
      with {:ok, %{"user_id" => user_id}} <- get_scheduled(confirmation_token),
           {:ok, _} <- User.update(user_id, %{password: new_password}),
           {:ok, _} <- delete_job(user_id, confirmation_token) do
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
        {:error, :not_found, :password_reset_job}

      [job] ->
        Repo.delete!(job)
        {:ok, job}
    end
  end

  @impl Oban.Worker
  def perform(_), do: :ok
end
