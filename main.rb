require_relative "lib/film_collection"
require_relative "lib/film_parser"

puts "Программа «Фильм на вечер»"
puts "С какого сайта хотите взять список фильмов:"
puts FilmParser.sites_list
user_site_choice = $stdin.gets.to_i

until user_site_choice.between?(0, FilmParser.sites_list.size - 1) do
  puts "Некорректное значение"
  user_site_choice = $stdin.gets.to_i
end

collection_and_error = FilmParser.from_site(user_site_choice)
collection = collection_and_error[:value]
error = collection_and_error[:error]

unless error.nil?
  puts <<~WARNING
    Фильмы взяты из файла из-за ошибки соединения:
    #{error}
  WARNING
end

#Создадим массив уникальных режиссёров, выведем на экран
puts collection.producers_to_list

#Выведем случайный фильм режиссёра, заданного пользователем
puts "Фильм какого режиссера вы хотите сегодня посмотреть (введите число)?"

user_choice = $stdin.gets.to_i
until user_choice.between?(1, collection.all_producers.size) do
  puts "Wrong answer"
  user_choice = $stdin.gets.to_i
end

selected_producer_film = collection.selected_producer_film(user_choice)

puts <<~RESULT


  И сегодня вечером рекомендую посмотреть:
  #{selected_producer_film}
RESULT
