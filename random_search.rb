require_relative 'util'

class RandomSearch

  def search(domain, fitness, iterations)
    best_candidate = Util.random_solution domain
    best_fitness = fitness.(best_candidate)

    puts "initial fitness: #{best_fitness}"

    (0...iterations).each do |i|
      candidate = Util.random_solution domain
      f = fitness.(candidate)

      if f < best_fitness
        best_fitness = f
        best_candidate = candidate
        puts "new best fitness found: #{best_fitness}"
      end
    end unless best_fitness == 0.0

    best_candidate
    # returns [weight, ...]
  end

end
