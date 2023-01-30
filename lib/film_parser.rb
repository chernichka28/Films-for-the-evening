require_relative "film_collection"
require_relative "film"

module FilmParser
  extend self

  SITES = [{title: "Kinopoisk", method: :from_kinopoisk}, {title: "IMDB", method: :from_imdb}].freeze
  KINOPOISK_URI = "https://www.kinopoisk.ru/lists/movies/top500".freeze
  IMDB_URI = "https://www.imdb.com/chart/top/".freeze

  def from_kinopoisk
    films_and_error = get_films(KINOPOISK_URI, "kinopoisk_top500.html", ".base-movie-main-info_link__YwtP1")
    all_films_from_html = films_and_error[:films]
    connection_error = films_and_error[:error]

    all_films = all_films_from_html.map do |film|
      description = film.css(".desktop-list-main-info_truncatedText__IMQRP").text
      title = film.css(".styles_mainTitle__IFQyZ").text
      year = film.css(".desktop-list-main-info_secondaryText__M_aus").text.split(", ")[-2]
      producer = description.scan(/[А-Я][а-я]+\s[А-Я][а-я]+/).first
      Film.new(title, producer, year)
    end
    {value: FilmCollection.new(all_films), error: connection_error}
  end

  def from_imdb
    films_and_error = get_films(IMDB_URI, "imdb_top_250.html", ".titleColumn")
    all_films_from_html = films_and_error[:films]
    connection_error = films_and_error[:error]

    all_films = all_films_from_html.map do |film|
      title = film.css("a").text
      year = film.css(".secondaryInfo").text.delete("()")
      description = film.css("a").map { |cont| cont["title"] }
      producer = description.first.scan(/[A-Z][a-z]+\s[A-Z][a-z]+/)
      Film.new(title, producer.first, year)
    end
    {value: FilmCollection.new(all_films), error: connection_error}
  end

  def from_site(site_id)
    method(SITES[site_id][:method]).call
  end

  def sites_list
    SITES.map.with_index(0) { |site, index|  "#{index}: #{site[:title]}" }
  end

  private

  def get_films(uri, file_name, film_class_flag)
    begin
      html = URI.open(uri) { |result| result.read }
    rescue SocketError => error
      connection_error = error.message
    end

    doc = Nokogiri::HTML(html)
    all_films_from_html = doc.css(film_class_flag)

    if all_films_from_html.empty?
      html = File.read(File.join(__dir__, "..", "data", file_name))
      doc = Nokogiri::HTML(html)
      all_films_from_html = doc.css(film_class_flag)
    else
      #если доступ к сайту есть, обновляем файл
      File.write(File.join(__dir__, "..", "data", file_name), html)
    end

    {films: all_films_from_html, error: connection_error}
  end
end
