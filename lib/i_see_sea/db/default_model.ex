defmodule ISeeSea.DB.DefaultModel do
  @moduledoc false

  defmacro __using__(opts) do
    default_preloads = Keyword.get(opts, :default_preloads, [])

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, warn: false
      alias ISeeSea.Repo

      @default_preloads unquote(default_preloads)

      def get(id, preloads \\ unquote(default_preloads)) do
        case Repo.get(__MODULE__, id) |> Repo.preload(preloads) do
          entry when not is_nil(entry) -> {:ok, entry}
          _ -> {:error, :not_found, __MODULE__}
        end
      end

      def create(attrs, preloads \\ unquote(default_preloads)) do
        struct(__MODULE__, %{})
        |> changeset(attrs)
        |> Repo.insert()
        |> case do
          {:ok, entry} ->
            {:ok, Repo.preload(entry, preloads)}

          {:error, error} ->
            {:error, error}
        end
      end

      def get_by(fields, preloads \\ unquote(default_preloads)) do
        where_clause = where_clause(fields)

        query =
          from(u in __MODULE__,
            where: ^where_clause,
            select: u
          )

        case Repo.one(query) |> Repo.preload(preloads) do
          entry when not is_nil(entry) -> {:ok, entry}
          _ -> {:error, :not_found, __MODULE__}
        end
      end

      def get_all_by(fields, preloads \\ unquote(default_preloads)) do
        where_clause = where_clause(fields)

        query =
          from(u in __MODULE__,
            where: ^where_clause,
            select: u
          )

        case Repo.all(query) |> Repo.preload(preloads) do
          entry when not is_nil(entry) -> {:ok, entry}
          _ -> {:error, :not_found, __MODULE__}
        end
      end

      def get_with_filter(
            params,
            bindings \\ unquote(default_preloads),
            pagination,
            initial_from \\ __MODULE__,
            preloads \\ unquote(default_preloads)
          ) do
        pagination = Map.merge(%{page: 1, page_size: 10}, pagination)

        bindings
        |> Enum.reduce(distinct(initial_from, true), &process_binding/2)
        |> ISeeSea.Flop.validate_and_run(Map.merge(params, pagination), for: __MODULE__)
        |> case do
          {:ok, {entries, %Flop.Meta{total_count: total_count}}} ->
            {:ok, Repo.preload(entries, preloads), Map.put(pagination, :total_count, total_count)}

          {:error, %Flop.Meta{}} ->
            {:error, :bad_request}
        end
      rescue
        _ in Ecto.QueryError -> {:error, :bad_request}
      end

      def where_clause(search_terms) do
        where_match_clause = fn {k, v}, conditions ->
          dynamic([q], field(q, ^k) == ^v and ^conditions)
        end

        Enum.reduce(search_terms, true, &where_match_clause.(&1, &2))
      end

      def all(preloads \\ unquote(default_preloads)) do
        {:ok, all!(preloads)}
      end

      def all!(preloads \\ unquote(default_preloads)) do
        __MODULE__
        |> Repo.all()
        |> Repo.preload(preloads)
      end

      def update(id, attrs, preloads \\ unquote(default_preloads)) do
        case Repo.get(__MODULE__, id) do
          nil ->
            {:error, :not_found, __MODULE__}

          entry ->
            changeset = changeset(entry, attrs)

            case Repo.update(changeset) do
              {:ok, entry} -> {:ok, entry |> Repo.preload(preloads)}
              {:error, changeset} -> {:error, changeset}
            end
        end
      end

      def delete(id) do
        case Repo.get(__MODULE__, id) do
          nil -> {:error, :not_found, __MODULE__}
          entry -> Repo.delete(entry)
        end
      end

      def soft_delete(id_str) when is_binary(id_str), do: soft_delete(String.to_integer(id_str))

      def soft_delete(id) when is_integer(id) do
        case Repo.get(__MODULE__, id) do
          nil ->
            {:error, :not_found, __MODULE__}

          entry ->
            changeset = changeset(entry, %{deleted: true})

            case Repo.update(changeset) do
              {:ok, entry} -> {:ok, entry}
              {:error, changeset} -> {:error, changeset}
            end
        end
      end

      def soft_delete(entry) do
        changeset = changeset(entry, %{deleted: true})

        case Repo.update(changeset) do
          {:ok, entry} -> {:ok, entry}
          {:error, changeset} -> {:error, changeset}
        end
      end

      defp process_binding({:pollution_report, :pollution_types}, q) do
        join(
          q,
          :left,
          [br],
          entity in assoc(br, :pollution_report),
          as: :pollution_report
        )
        |> join(:left, [pollution_report: pr], rt in assoc(pr, :pollution_types),
          as: :pollution_types
        )
      end

      defp process_binding(current_binding, q) do
        join(q, :left, [current_binding], entity in assoc(current_binding, ^current_binding),
          as: ^current_binding
        )
      end

      defoverridable(
        create: 2,
        create: 1,
        get: 2,
        get: 1
      )
    end
  end
end
