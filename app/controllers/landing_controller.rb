class LandingController < ApplicationController

  def index
    @photos = Photo.today
    @with_position = true
    @photos_yesterday = Photo.yesterday(10)
  end

  protected

    def refresh_exchange_rates
      @rates = CurrencyExchangeRates.refresh!(false,true)
      @rates_updated = CurrencyExchangeRates.last.updated_at
    end

end