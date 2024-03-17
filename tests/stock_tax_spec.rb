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
            expect(tax).to eq([[[{:tax=>"0.00"}], [{:tax=>"0.00"}], [{:tax=>"0.00"}], [{:tax=>"1400.00"}]]])
      end

      it 'calculates taxes considering accumulated loss' do
        transactions = [
          [
            Operation.new({ "operation" => "buy", "unit-cost" => 10.0, "quantity" => 10000 }, 0),
            Operation.new({ "operation" => "sell", "unit-cost" => 5.0, "quantity" => 5000 }, 0) # Venda com prejuízo
          ]
        ]
        stock_taxes = transactions.map { |transaction_list| StockTax.new(transaction_list) }
        stock_taxes.each { |stock_tax| stock_tax.calculate_taxes }
        tax = stock_taxes.map(&:tax)
        expect(tax).to eq([[[{:tax=>"0.00"}], [{:tax=>"0.00"}]]])
      end
    end
  end