require 'yajl'
require 'open-uri'

class CurrencyExchangeRates < ActiveRecord::Base

  def self.refresh!(force=false,to_js=false)
  
    if force==true || self.all.empty? || self.first.updated_at < 1.hour.ago || self.first.rate.blank?
      @latest = self.get_latest! 
      App.currencies.each do |cur|
        currency = self.where(currency: cur.slug).first_or_create
        if currency.rate.blank? || currency.updated_at < 1.hour.ago || force==true
          new_rate = self.get_rate(@latest, "USD", cur.slug)
          currency.update_attributes(:rate => new_rate) 
        end
      end
      App.exchange_rates = CurrencyExchangeRates.all.entries
    end
    
    return to_js ? self.all_to_js : App.exchange_rates
  end

  def self.get_rates
    rates = {}
    (App.exchange_rates||self.all).each do |r|
      rates[r.currency] = r.rate
    end
    rates
  end

  def self.get_rate(rates, from="PHP", to="BTC")
    if from == to
      rate = 1
    elsif from == 'USD'
      rate = rates[to]
    elsif to == 'USD'
      rate = 1 / rates[from]
    else
      rate = rates[to].to_f * (1/rates[from].to_f)
    end
    rate.round(10)
  end

  def self.convert(amount, from="PHP", to="BTC")
    new_rate = self.get_rate(self.get_rates, from, to)
    amount*new_rate
  end

  def self.get_latest!
    App.exchange_rates = false
    hash = Yajl::Parser.parse(open("http://openexchangerates.org/latest.json?app_id=#{App.services.open_exchange.app_id}"))
    return hash['rates']
    rescue
      self.get_rates
  end

  def self.all_to_js
    js = {}
    (App.exchange_rates||self.all).each do |record|
      js[record.currency] = record.rate
    end
    js
  end
end