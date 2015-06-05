require_relative 'util'

class GaSearch

  def search(domain, fitness, iterations, n = 500, mr = 0.005, elites = 1)
    population = make_random_population domain, fitness, n

    (0...iterations).each do |i|
      population = generation domain, population, fitness, mr, elites
      avg_fit = population.inject(0.0) { |sum, ind| sum += ind.first[1] } / population.length
      best_fit = population[0].first[1]

      puts "best,average fitness of generation #{i}: #{best_fit}, #{avg_fit}" if i % 10 == 0
      break if best_fit < 0.005
    end

    population[0].first[0]
    # returns [weight, ...]
  end

  private

  def make_random_population(domain, fitness, n)
    (0...n).map { |_| Util.random_solution domain }.
        map { |i| { i => fitness.(i) } }.
        sort { |a, b| a[1] <=> b[1] }
    # returns [ { [weight, ...], fitness }, ... ]
  end

  def generation(domain, population, fitness, mr, elites)
    n = population.length

    new_pop = population[0...elites]

    while new_pop.length < n do
      p1 = select population
      p2 = select population
      a, b = crossover p1, p2

      new_inds = [a,b].map { |i| mutate i, domain, mr }
      new_pop += new_inds.map { |i| { i => fitness.(i) } }
    end

    new_pop[0...n].sort { |a, b| a.first[1] <=> b.first[1] }
    # returns [ { [weight, ...], fitness }, ... ]
  end

  def select(population)
    sum_weights = population.inject(0.0) { |sum, ind| sum += 1.0 / ind.first[1] }

    pick = Random.rand sum_weights
    population.each do |ind|
      pick -= 1.0 / ind.first[1]
      return ind.first[0] if pick <= 0
      # returns [weight, ...]
    end
    raise 'Unexpected loop end: select(population)'
  end

  def crossover(a, b)
    n = Random.rand a.length
    return a[0...n] + b[n..-1], b[0...n] + a[n..-1]
    # returns [weight, ...], [weight, ...]
  end

  def mutate(ind, domain, mr)
    ind.zip(domain).map { |i, f| Random.rand > mr ? i : f.() }
    # returns [weight, ...]
  end

end
