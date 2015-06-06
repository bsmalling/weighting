#! /usr/bin/env ruby

require 'set'
require_relative 'util'
require_relative 'ga_search'
require_relative 'random_search'

class Main

  def main
    mode = :ga_search # :ga_search or :random_search or :rim_search
    ignored_columns = Set.new [0, 1]

    table = ARGF.readlines.map do |line|
      line.strip.split("\t") unless line =~ /^\s*$/ || line =~ /^#/
    end.compact

    # table = [ [column, ...], ... ]
    control = table.reject { |row| row[1] == '1' }              # [ [ [column, ...], 1 ], ... ]
    test    = table.reject { |row| row[1] != '1' }              # [ [ [column, ...], 1 ], ... ]

    fitness = fitness_closure control, test, ignored_columns    # lamda
    domain = Array.new test.length, Util.make_log_uniform(3.0)  # [lambda, ...]
    case mode
      when :ga_search
        best = GaSearch.new.search domain, fitness, 500         # [weight, ...]
      when :random_search
        best = RandomSearch.new.search domain, fitness, 500     # [weight, ...]
      when :rim_search
        raise 'RIM not yet implemented'
      else
        raise "Invalid mode: #{mode}"
    end

    a1 = make_aggregates control, ignored_columns               # { total: weight, 'col_n_m': weight, ... }
    a2 = make_aggregates test, ignored_columns, best            # { total: weight, 'col_n_m': weight, ... }

    puts 'control'
    a1.each { |k| puts "#{k}: #{a1[k]}" }

    puts 'test'
    a2.each { |k| puts "#{k}: #{a2[k]}" }

    puts
    test.zip(best).each { |i, w| puts "#{i[0]}\t#{w}" }
  end

  private

  def fitness_closure(t1, t2, ignores)
    a1 = make_aggregates t1, ignores
    n = t2.length

    ->(weights) {
      a2 = make_aggregates t2, ignores, weights
      root_mean_square_error a1, a2, n
    }
  end

  def make_aggregates(t, ignores, weights = nil)
    aggs = Hash.new # { |hash, key| hash[key] = 0.0 } ?Causes runtime error?
    weights = t.map { |_| 1 } unless weights

    aggs[:total] = 0.0
    t.zip(weights).each do |entry|
      row, weight = entry[0], entry[1]
      aggs[:total] += weight

      (0...row.length).map do |i|
        next if ignores.include? i

        key = "col_#{i}_#{row[i]}"
        aggs[key] = 0.0 unless aggs.has_key? key
        aggs[key] += weight
      end
    end

    aggs
    # returns { total: weight, 'col_n_m': weight, ... }
  end

  def mean_square_error(t1, t2, n)
    keys = Set.new t1.keys + t2.keys
    keys.inject(0.0) { |sum, k| sum += (t1[k] - t2[k]) ** 2 } / n
  end

  def root_mean_square_error(t1, t2, n)
    Math.sqrt mean_square_error(t1, t2, n)
  end

end

Main.new.main
