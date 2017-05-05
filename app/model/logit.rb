class Logit
  def self.info(message=nil)
    @logit ||= Logger.new("#{Rails.root}/log/logit.log")
    @logit.debug(message) unless message.nil?
  end
end
