require "pry"
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(data, id=nil)
        @name = data[:name]
        @breed = data[:breed]
        @id = id
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(data)
        hash = {name: data[1], breed: data[2]}
        id = data[0]
        dog = self.new(hash, id)
        dog
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name= ?, breed= ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(data)
        dog = self.new(data)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id= ?
        SQL

        result = DB[:conn].execute(sql, id)

        if !result.empty?
            dog_info= result[0]
            id = dog_info[0]
            hash = {name: dog_info[1], breed: dog_info[2]}
            dog= self.new(hash, id)
            dog
        end
    end

    def self.find_or_create_by(data)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name= ? AND breed= ?
        SQL
        name= data[:name]
        breed = data[:breed]

        result = DB[:conn].execute(sql, name, breed)

        if !result.empty?
            dog_info= result[0]
            id = dog_info[0]
            hash = {name: dog_info[1], breed: dog_info[2]}
            dog= self.new(hash, id)
            dog
        else
            dog = self.create(data)
            dog
        end

    end

    def self.find_by_name(name)

        sql= <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL



        result = DB[:conn].execute(sql, name)[0]

        id= result[0]
        hash = {name: result[1], breed: result[2]}

        dog = self.new(hash, id)

        dog
    end
end