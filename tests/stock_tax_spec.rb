require 'rspec'
require '../stock_tax'
require_relative '../operation' 

RSpec.describe StockTax do
    describe '#calculate_taxes' do
      it 'calculates taxes for a set of transactions' do
        transactions = [
            [
              Operation.new({ "operation"=> "buy", "unit-cost"=> 10.0, "quantity"=> 1000 }, 0),
              Operation.new({ "operation"=> "sell", "unit-cost"=> 15.0, "quantity"=> 500 }, 0),
              Operation.new({ "operation"=> "buy", "unit-cost"=> 20.0, "quantity"=> 2000 }, 0),
              Operation.new({ "operation"=> "sell", "unit-cost"=> 25.0, "quantity"=> 1000 }, 0)
            ]
          ]

        
            stock_taxes = transactions.map { |transaction_list| StockTax.new(transaction_list) }
            stock_taxes.each { |stock_tax| stock_tax.calculate_taxes }
            tax =  stock_taxes.map(&:tax)
  
           expect(tax).to eq([[[{:tax=>0.0}, {:tax=>0.0}, {:tax=>0.0}, {:tax=>1400.0}]]])
      end
    end

    describe '#calculate_taxes when accumulated loss and minimum operation value ' do
    it 'handles accumulated loss and minimum operation value' do
      transactions = [
          [
            Operation.new({"operation" =>"buy", "unit_cost" => 30.0, "quantity" => 1000}, 0),
            Operation.new({"operation" =>"sell", "unit_cost" => 25.0, "quantity" => 500}, 0),
            Operation.new({"operation" =>"sell", "unit_cost" => 20.0, "quantity" => 200}, 0),
            Operation.new({"operation" =>"sell", "unit_cost" => 15.0, "quantity" => 100}, 0),
          ]
      ]

      stock_taxes = transactions.map { |transaction_list| StockTax.new(transaction_list) }
      stock_taxes.each { |stock_tax| stock_tax.calculate_taxes }
      tax =  stock_taxes.map(&:tax)
      p stock_taxes
      # You can assert the expected values based on your logic
      expect(tax).to eq([[[
        { tax: 0.0 },
        { tax: 0.0 },
        { tax: 0.0 },
        { tax: 0.0 }
      ]]])
    end
  end
  end