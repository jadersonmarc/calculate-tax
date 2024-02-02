class StockTax
    attr_reader :transaction_history, :accumulated_loss
  
    def initialize(transaction_history)
      @transaction_history = transaction_history
      @accumulated_loss = 0.0
      @tax = {}
    end
    p @transaction_history

    def call

    end
  
    # Calcula o imposto a ser pago sobre a venda de ações
    def calculate_tax(sell_transaction)
        total_taxes = 0.0
        @transaction_history.each_with_index do |sell_transaction, index|
          next if sell_transaction.operation == "buy"
    
          # Calcula o lucro bruto da operação
          gross_profit = sell_transaction.quantity * (sell_transaction.unit_cost - weighted_average_price(index))
    
          # Se o lucro bruto for negativo, há prejuízo
          if gross_profit < 0.0
            @accumulated_loss += gross_profit
            next
          end
    
          # Se o valor total da operação for menor que R$ 20.000,00, não há imposto
          total_operation_value = sell_transaction.quantity * sell_transaction.unit_cost
          next if total_operation_value <= 20000.0
    
          # Se o prejuízo acumulado for positivo, usa-o para reduzir o lucro
          net_profit = gross_profit - @accumulated_loss
    
          # Se o lucro líquido for positivo, calcula o imposto
          if net_profit > 0.0
            @accumulated_loss = 0.0
            total_taxes += net_profit * 0.2
          end
        end
        total_taxes
    end

    private

    # Calcula o preço médio ponderado das ações
    def weighted_average_price(index)
        # Começa com um preço médio ponderado inicial de 0
        weighted_average = @transaction_history[0].unit_cost
        total_shares = 0.0
    
        @transaction_history.each_with_index do |transaction, transaction_index|
          next if transaction_index > index
    
          # Se for uma operação de compra, atualiza o preço médio ponderado
          if transaction.operation == "buy"
            weighted_average = ((weighted_average * total_shares) + (transaction.unit_cost * transaction.quantity)) / (total_shares + transaction.quantity)
            total_shares += transaction.quantity
          end
    
          # Se for uma operação de venda, apenas atualiza o total de ações
          if transaction.operation == "sell"
            total_shares -= transaction.quantity
          end
        end
    
        weighted_average
      end