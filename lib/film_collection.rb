require_relative "film"
require "nokogiri"
require "open-uri"

class FilmCollection
  attr_reader :all_films, :all_producers

  def self.from_folder(folder_path)
    file_names = Dir[File.join(folder_path, "*.txt")]

    #Зададим из файлов массив фильмов
    all_films =
      file_names.map do |file_name|
        file_content = File.readlines(file_name, chomp: true)
        Film.new(file_content[0], file_content[1], file_content[2])
      end

    new(all_films)
  end

  def initialize(array_of_films)
    @all_films = array_of_films
    @all_producers = all_films.map(&:producer).uniq
  end

  def producers_to_list
    all_producers.map.with_index(1) { |this_producer, index| "#{index}: #{this_producer}" }
  end

  def selected_producer_film(user_choice)
    selected_producer_films = all_films.select { |film| film.producer == all_producers[(user_choice).to_i - 1] }
    selected_producer_films.sample
  end
end
