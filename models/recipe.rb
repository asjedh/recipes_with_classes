class Recipe
  attr_reader :id, :name, :description, :instructions

  def initialize(id, name, description, instructions)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
  end




  def ingredients

  end

  def self.recipesdb_conn
    begin

      connection = PG.connect(dbname: 'recipes')
      yield(connection)

    ensure
      connection.close
    end
  end

  def self.all
    query = "SELECT * FROM recipes ORDER BY name"

    recipesdb_conn do |conn|
      conn.exec(query)
    end.to_a.map { |recipe| Recipe.new(recipe['id'], recipe['name'], recipe['description'], recipe['instructions']) }
  end

  def self.find(id)
    query = "SELECT * FROM recipes WHERE id = $1"

    recipe_hash = recipesdb_conn do |conn|
      conn.exec_params(query,[id])
    end.to_a[0]
    Recipe.new(recipe_hash['id'], recipe_hash['name'], recipe_hash['description'], recipe_hash['instructions'])
  end
end

