require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :name, :primary_key, :other_class_name, :foreign_key
  
  def other_class
    other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @name = name
    @primary_key = params[:primary_key] || "id"
    @other_class_name = params[:other_class_name] || name.to_s.camelize
    @foreign_key = params[:foreign_key] || name.to_s + "_id"
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @name = name
    @primary_key = params[:primary_key] || "id"
    @other_class_name =
      params[:other_class_name] || name.to_s.singularize.camelize
    @foreign_key =
      params[:foreign_key] || self_class.name + "_id"
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    params = BelongsToAssocParams.new(name, params)
    assoc_params[name] = params
    
    define_method(name) do
      raw_results = DBConnection.execute(<<-SQL, send(params.foreign_key))
        SELECT
          *
        FROM
          #{params.other_table}
        WHERE
          #{params.primary_key} = ?
      SQL
      
      params.other_class.parse_all(raw_results).first
    end
  end

  def has_many(name, params = {})
    params = HasManyAssocParams.new(name, params, self)
    assoc_params[name] = params

    define_method(name) do
      raw_results = DBConnection.execute(<<-SQL, send(params.primary_key))
        SELECT
          *
        FROM
          #{params.other_table}
        WHERE
          #{params.foreign_key} = ?
      SQL
      
      params.other_class.parse_all(raw_results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      params1 = self.class.assoc_params[assoc1]
      params2 = (params1.other_class).assoc_params[assoc2]
      
      t1 = params1.other_table
      pk1 = params1.primary_key
      fk1 = params1.foreign_key
      
      t2 = params2.other_table
      pk2 = params2.primary_key
      fk2 = params2.foreign_key
      
      raw_results = DBConnection.execute(<<-SQL, send(fk1))
        SELECT
          #{t2}.*
        FROM
          #{t1}
        JOIN
          #{t2} ON #{t1}.#{fk2} = #{t2}.#{pk2}
        WHERE
          #{t1}.#{pk1} = ?
      SQL
      
      (params2.other_class).parse_all(raw_results).first
    end
  end
end
