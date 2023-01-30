class Film
  attr_reader :title, :producer, :year

  def initialize(title, producer, year)
    @title = title
    @producer = producer
    @year = year
  end

  def to_s
    "#{@producer} - #{@title} (#{@year})."
  end
end
