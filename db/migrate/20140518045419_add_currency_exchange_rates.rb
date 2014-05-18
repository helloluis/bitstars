class AddCurrencyExchangeRates < ActiveRecord::Migration
  def change
    # exchange rate from PESO to X
    create_table :currency_exchange_rates do |t|
      t.string :currency, default: "USD"
      t.float  :rate, default: 1.0
      t.timestamps
    end
  end
end
