# Credits belong to
# https://github.com/emaadmanzoor/python-ML-minimal/blob/master/logistic-regression.py

class Logit
  def initialize
    # calculate_additional_features
  end

  def predict(features, theta, y)
    m = features.length      # Number of training examples
    n = features[0].length   # Number of features

    features.each {|i| i.unshift(1) } # Append a column of 1's to features

    self.class.cost_logistic_regression(theta, features, y, m, n)
  end

  #
  # X = List of training example parameters, e.g. [[34.97,78.24]],[30.97,43.86]]
  # Y = List of training example results, e.g. [0,1,0]
  # learning_rate = 0.001
  # iterations    = 4000
  def train(features, y, learning_rate, iterations)
    m = features.length             # Number of training examples
    n = features[0].length          # Number of features
    initial_theta = [0.0] * (n + 1) # Initialize theta's

    features.each {|i| i.unshift(1) } # Append a column of 1's to features

    features = self.class.scale_features(features, m, n)

    # Run gradient descent to get our guessed theta
    self.class.gradient_descent_logistic(initial_theta, features, y, m, n, learning_rate, iterations)

    # Evaluate our hypothesis accuracy
    #puts "Final theta: #{final_theta}"
    #puts "Initial cost: #{self.class.cost_logistic_regression(initial_theta, features, y, m, n)}"
    #puts "Final cost: #{self.class.cost_logistic_regression(final_theta, features, y, m, n)}"
    #puts "Example: #{self.class.cost_logistic_regression([0,0,1], features, y, m, n)}"
  end

  private

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
          summation += (h_logistic_regression(theta, x[k], n) - y[k]) * x[k][j]
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
      summation += y[i] * Math.log(h_logistic_regression(theta, x[i], n)) + (1 - y[i]) * Math.log(1 - h_logistic_regression(theta, x[i], n))
    end
    -summation / m
  end
end
