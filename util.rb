class Util

  def self.make_uniform(lo, hi)
    -> () { lo + Random.rand(hi) }
  end

  def self.make_log_uniform(base)
    -> () { base ** (-1 + Random.rand(2.0)) }
  end

  def self.random_solution(domain)
    domain.map { |f| f.() }
  end

end
