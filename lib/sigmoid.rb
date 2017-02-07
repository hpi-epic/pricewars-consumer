class RandomSigmoid
  def initialize(mean, price)
    @mean = mean
    @price = price
  end

  def rand
    # theta = 2 * Math::PI * Kernel.rand(@mean)
    # rho = Math.sqrt(-2 * Math.log(1 - Kernel.rand(@mean)))
    # scale = stddev * rho
    # rndm = Kernel.rand(@mean)

    # return self.class.negativeSigmoid(@price, @mean) # returns the probability
    re = self.class.negativeSigmoid(@price, @mean)
    puts "price #{@price} and mean #{@mean} and result #{re}"
    re
  end

  private

  def self.negativeSigmoid(x, mean)
    # y = 1/(1+exp(-x)) <==> x = ln(y/(1-y))
    sigmoid(-1 * x + mean)
  end

  def self.invertedSigmoid(x)
    sigmoid(x) * (-1)
  end

  def self.sigmoid(x)
    numerator / denominator(x)
  end

  def self.numerator
    numerator = 1
    numerator
  end

  def self.denominator(x)
    1 + Math.exp(-x)
  end
end
