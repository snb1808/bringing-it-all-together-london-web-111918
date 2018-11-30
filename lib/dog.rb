require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, @name, @breed)

    @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]

    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?;
    SQL

    result = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(id: result[0][0], name: result[0][1], breed: result[0][2])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
      if !result.empty?
        dog = Dog.new(id: result[0][0], name: result[0][1], breed:[0][2])
      else
        dog = self.create(name: name, breed: breed)
      end
    end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?;
    SQL

    result = DB[:conn].execute(sql, name)
    Dog.new_from_db(result[0])
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?;
    SQL
    DB[:conn].execute(sql, @name, @breed)
  end

end
