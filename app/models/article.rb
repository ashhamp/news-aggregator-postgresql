require_relative "../../server"
require "pg"
require "pry"

class Article

  attr_accessor :info, :errors

  def initialize(info = {})
    @info = info
    @errors = []
    @error = nil
  end

  def title
    @info["title"]
  end

  def url
    @info["url"]
  end

  def description
    @info["description"]
  end

  def valid?
    @error = nil

    if url.strip.empty?
      @errors << "Please completely fill out form"
      @error = true
      return false
    elsif !url.include?('http')
      @errors << "Invalid URL"
      @error = true
    end

    if title.strip.empty? || description.strip.empty?
      @errors << "Please completely fill out form"
      @error = true
    end




    all_articles = Article.all
    all_articles.each do |article|
      if article.url == url
        @errors << "Article with same url already submitted"
        @error = true
      end
    end

    if description.length < 20
      @errors << "Description must be at least 20 characters long"
      @error = true
    end

    if @error == true

      return false
    else
      return true
    end

  end


  def save
    if valid?
      db_connection do |conn|
        conn.exec_params('INSERT INTO articles (title, url, description)
        VALUES ($1,$2,$3)', [title, url, description]);
      end
      true
    else
      false
    end
  end



  def self.all
    @object_array = []
    articles = db_connection { |conn| conn.exec('SELECT * FROM articles') }
    articles.each do |article|
      @object_array << Article.new(article)
    end
    @object_array
  end
end
