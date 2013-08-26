defrecord Ecto.Reflections.BelongsTo, [:field, :owner, :associated, :foreign_key]

defmodule Ecto.Associations.BelongsTo do
  @not_loaded :not_loaded

  # Needs to be defrecordp because we don't want pollute the module
  # with functions generated for the record
  defrecordp :assoc, __MODULE__, [:loaded, :target, :name]

  def new(params // [], assoc(target: target, name: name)) do
    refl = elem(target, 0).__ecto__(:association, name)
    fk = refl.foreign_key
    refl.associated.new([{ fk, target.primary_key }] ++ params)
  end

  def get(assoc(loaded: @not_loaded, target: target, name: name)) do
    refl = elem(target, 0).__ecto__(:association, name)
    raise Ecto.AssociationNotLoadedError,
      type: :has_one, owner: refl.owner, name: name
  end

  def get(assoc(loaded: loaded)) do
    loaded
  end

  Enum.each [:loaded, :target, :name], fn field ->
    def __ecto__(unquote(field), record) do
      assoc(record, unquote(field))
    end

    def __ecto__(unquote(field), value, record) do
      assoc(record, [{ unquote(field), value }])
    end
  end

  def __ecto__(:new, name) do
    assoc(name: name, loaded: @not_loaded)
  end
end