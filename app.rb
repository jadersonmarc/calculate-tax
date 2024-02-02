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
    total_taxes = 0.0
    parsed_operations.each do |operation_list|
      stock_tax_calculator = StockTax.new
      operation_list.each do |operation|
        tax = stock_tax_calculator.calculate_tax(operation)
        total_taxes += tax
      end
    end
    total_taxes
  end

  def calculate_tax(operations_history)
    calculated_transactions = []
    operations_history.each do |operations|
      calculated_transactions << StockTax.new(operations)
    end
    calculated_transactions
  end  

  def process_transactions
    transactions = input_data
    parsed_operations = parse_data
    p calculate_tax(parsed_operations)
  end
 
end

TransactionProcessor.new.process_transactions


# Calcula o imposto para cada operação de venda
# imposto_acoes = ImpostoAcoes.new(historico_operacoes)

# historico_operacoes.each do |operacoes|
#   operacao_venda = operacoes.last

#   imposto = imposto_acoes.calcular_imposto(operacao_venda)

#   puts "Imposto para operação de venda: #{imposto}"
# end

