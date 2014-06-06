class Recipe
  attr_reader :id, :name, :description, :instructions

  def initialize(id, name, description, instructions)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
  end

  ############################
  ##### INSTANCE METHODS #####
  ############################

  def ingredients
    # if you call this method on a recipe, you should look at the recipe id,
    # go to the ingredients table, find all the ingredients, then put them into
    # and array of Ingredient instance
    query = "SELECT ingredients.name FROM ingredients
             JOIN recipes ON recipes.id = ingredients.recipe_id
             WHERE recipes.id = $1
             ORDER BY ingredients.name"

    self.class.recipesdb_conn do |conn|
      conn.exec_params(query,[id])
    end.to_a.map { |ingredient| Ingredient.new(ingredient['name'])}
  end


  #########################
  ##### CLASS METHODS #####
  #########################

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
    end.to_a.map { |recipe| Recipe.new(recipe['id'], recipe['name'], recipe['description'] || "This recipe doesn't have a description.", recipe['instructions'] || "This recipe doesn't have any instructions.") }
  end

  def self.find(id)
    query = "SELECT * FROM recipes WHERE id = $1"

    recipe_hash = recipesdb_conn do |conn|
      conn.exec_params(query,[id])
    end.to_a[0]
    Recipe.new(recipe_hash['id'], recipe_hash['name'], recipe_hash['description'] || "This recipe doesn't have a description.", recipe_hash['instructions'] || "This recipe doesn't have any instructions.")
  end
end

