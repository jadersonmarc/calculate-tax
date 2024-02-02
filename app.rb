require 'readline'
require 'json'
require_relative 'operation' 
require_relative 'stock_tax'

class TransactionProcessor
  def initialize
    @transactions = []
  end

  def input_data
    while buf = Readline.readline("> ", true)
      break if buf.empty? || buf == "\n"
      @transactions << buf
    end

    sanatize_data
  end

  def sanatize_data
    transactions_string = @transactions.join(",")
    transactions_string.gsub!(",,", ",")
    @transactions = transactions_string.scan(/\[\{.*?\}\]/)
  end

  def parse_data
    parsed_operations = []
    @transactions.each do |transactions_list|
      parsed_operation_list = []
      JSON.parse(transactions_list).each do |transaction_data|
        parsed_operation_list << Operation.new(transaction_data)
      end
      parsed_operations << parsed_operation_list
    end
    parsed_operations
  end

  def calculate_taxes(parsed_operations)
    taxes_list = []
    parsed_operations.each do |operation_list|
      stock_tax_calculator = StockTax.new(operation_list)
      operation_taxes = []
      operation_list.each do |operation|
        operation_taxes << { "tax": stock_tax_calculator.calculate_taxes(operation) }
      end
      taxes_list << operation_taxes
    end
    taxes_list
  end


  def process_transactions
    transactions = input_data
    parsed_operations = parse_data
    p calculate_taxes(parsed_operations)
  end
 
end

TransactionProcessor.new.process_transactions
