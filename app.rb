require 'readline'
require 'json'
require_relative 'operation' 
require_relative 'stock_tax'

class TransactionProcessor
  attr_reader :transactions

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
    @transactions
    @transactions.each_with_index do |transactions_list, list_index|
      parsed_operation_list = []
      JSON.parse(transactions_list).each_with_index do |transaction_data, operation_index|
        parsed_operation_list << Operation.new(transaction_data, list_index)
      end
      parsed_operations << parsed_operation_list
    end
    parsed_operations
  end

  def calculate_taxes(parsed_operations)
    stock_taxes = parsed_operations.map { |transaction_list| StockTax.new(transaction_list) }
    stock_taxes.each { |stock_tax| stock_tax.calculate_taxes }
    stock_taxes.map(&:tax)
  end

  def format_response(list_taxes)
    taxed_lists_count = list_taxes.count { |list| list.any? { |element| element.first.key?(:tax) } }
    
    if taxed_lists_count == 1
      tax_values = list_taxes.flatten.map { |element| element[:tax] }
      json_response = tax_values.map { |tax| { "tax": tax } }
    else
      lists = list_taxes.map { |list| list }
      json_lists = lists.map do |list|
      list.map { |element| { "tax": element.first[:tax] } }
    end
    end

  end


  def process_transactions
    transactions = input_data
    parsed_operations = parse_data
    taxes = calculate_taxes(parsed_operations)
    p format_response(taxes)
  end
 
end

if __FILE__ == $PROGRAM_NAME
  TransactionProcessor.new.process_transactions
end
