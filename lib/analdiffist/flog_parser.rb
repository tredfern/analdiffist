require 'flog'
module AnalDiffist
  class FlogParser
    def initialize paths, threshold = 10.0
      @paths = paths
      @flog_threshold = threshold
    end

    def problems
      f = Flog.new
      f.flog(@paths)
      problems = []
      f.each_by_score{|class_method, score, ignore_for_now| problems << FlogProblem.new(class_method, score)}
      problems.select {|p| p.score >= @flog_threshold}
    end
  end

  class FlogProblem
    attr_accessor :context, :score
    def initialize class_method, score
      @context = class_method || '(none)'
      @score = score
    end

    def type
      'flog score'
    end

    def diff other
      return self if other.nil?
      return nil if other.score >= score
      FlogDiff.new(@context, other.score, score)
    end

    def description
      "Flog score: #{score}"
    end
  end
  class FlogDiff
    attr_accessor :context, :score
    def initialize context, previous_score, current_score
      @context = context
      @current_score = current_score
      @previous_score = previous_score
    end

    def score
      (@current_score - @previous_score).round(1)
    end

    def description
      "Flog: #{@current_score.round(1)} (+#{(@current_score - @previous_score).round(1)})"
    end
  end
end