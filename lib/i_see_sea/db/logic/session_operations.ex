defmodule ISeeSea.DB.Logic.SessionOperations do
  alias ISeeSeaWeb.Accounts
  alias ISeeSea.Repo
  alias ISeeSea.Events.UserEmailVerification
  alias ISeeSea.DB.Models.User

  def register(validated_params) do
    Repo.transaction(fn ->
      with {:ok, %User{id: user_id} = user} <- User.create(validated_params),
           uuid <- UUID.uuid4(:hex),
           {:ok, _} <- UserEmailVerification.start_tracker(user_id, uuid),
           {:ok, _} <- Accounts.deliver_user_confirmation_instructions(user) do
        user
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end
end
