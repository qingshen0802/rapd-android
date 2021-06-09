class WalletType < BaseEntity

  attr_accessor :name, :withdrawable, :loadable, :conversionable, :currency_id, :currency, :description, :color

  def initialize(options = {})
    super options
    self.currency = Currency.new(options["currency"]) unless options["currency"].nil?
  end

end