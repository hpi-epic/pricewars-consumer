# Credits belong to
# http://mh-journal.blogspot.de/2016/01/a-ruby-program-on-logistic-regression.html

class Logit
  def initialize
    # calculate_additional_features
  end

  def predict(_features, _coefficients)
  end

  def train(x, y)
    # x = []  # List of training example parameters
    # y = []  # List of training example results
    x = [[34.62365962451697,78.0246928153624],
        [30.28671076822607,43.89499752400101],
        [35.84740876993872,72.90219802708364],
        [60.18259938620976,86.30855209546826],
        [79.0327360507101,75.3443764369103]]
    y = [0,0,0,1,1]
    m = x.length      # Number of training examples
    n = x[0].length   # Number of features

    # Append a column of 1's to x
    x.each {|i| i.unshift(1) }

    # Initialize theta's
    initial_theta = [0.0] * (n + 1)
    learning_rate = 0.001
    iterations   = 4000

    x = self.scale_features(x, m, n)

    # Run gradient descent to get our guessed hypothesis
    final_theta = self.gradient_descent_logistic(initial_theta, x, y, m, n, learning_rate, iterations)

    # Evaluate our hypothesis accuracy
    puts "final_theta: #{final_theta}"
    puts "Initial cost: #{cost_logistic_regression(final_theta, x, y, m, n)}"
    puts "Final cost: #{cost_logistic_regression(final_theta, x, y, m, n)}"
  end

  private

  # Credentials: http://mh-journal.blogspot.de/2016/01/a-ruby-program-on-logistic-regression.html

  def self.calculate_additional_features
  end

  def self.scale_features(data, m, n)
    mean = [0]
    1.upto n do |j|
      sum = 0.0
      0.upto m - 1 do |i|
        sum += data[i][j]
      end
      mean << sum / m
    end

    stddeviation = [0]
    1.upto n do |j|
      temp = 0.0
      0.upto m - 1 do |i|
        temp += (data[i][j] - mean[j])**2
      end
      stddeviation << Math.sqrt(temp / m)
    end

    1.upto n do |j|
      0.upto m - 1 do |i|
        data[i][j] = (data[i][j] - mean[j]) / stddeviation[j]
      end
    end

    data
  end

  def self.h_logistic_regression(theta, x, n)
    theta_t_x = 0
    0.upto n do |i|
      theta_t_x += theta[i] * x[i]
    end

    begin
      k = 1.0 / (1 + Math.exp(-theta_t_x))
  rescue
    if theta_t_x > 10**5
      k = 1.0 / (1 + Math.exp(-100))
    else
      k = 1.0 / (1 + Math.exp(100))
      end
    end

    if k == 1.0
      k = 0.99999
    end

    k
  end

  def self.gradient_descent_logistic(theta, x, y, m, n, alpha, iterations)
    0.upto iterations - 1 do |_i|
      thetatemp = theta.clone
      0.upto n do |j|
        summation = 0.0
        0.upto m - 1 do |k|
          summation += (self.h_logistic_regression(theta, x[k], n) - y[k]) * x[k][j]
        end
        thetatemp[j] = thetatemp[j] - alpha * summation / m
      end
      theta = thetatemp.clone
    end
    theta
  end

  def self.cost_logistic_regression(theta, x, y, m, n)
    summation = 0.0
    0.upto m - 1 do |i|
      summation += y[i] * Math.log(self.h_logistic_regression(theta, x[i], n)) + (1 - y[i]) * Math.log(1 - self.h_logistic_regression(theta, x[i], n))
    end
    -summation / m
  end
end
