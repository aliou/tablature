module Tablature
  class Configuration
    # The Tablature database adapter instance to use when executing SQL.
    #
    # Defualts to an instance of {Adapters::Postgres}
    # @return Tablature adapter
    attr_accessor :database

    def initialize
      @database = Tablature::Adapters::Postgres.new
    end
  end

  # @return [Tablature::Configuration] Tablature's current configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Set Tablature's configuration
  #
  # @param config [Tablature::Configuration]
  def self.configuration=(config)
    @configuration = config
  end

  # Modify Tablature's current configuration
  #
  # @yieldparam [Tablature::Configuration] config current Tablature config
  # @example
  #   Tablature.configure do |config|
  #     config.database = Tablature::Adapters::Postgres.new
  #   end
  def self.configure
    yield configuration
  end
end
