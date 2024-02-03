class StockTax
  attr_reader :transaction_history, :accumulated_loss, :tax

  def initialize(transaction_history)
    @transaction_history = transaction_history
    @accumulated_loss = 0.0
    @accumulated_loss_positive = false
    @tax = []
  end

  # Calcula o imposto a ser pago sobre a venda de ações
  def calculate_taxes
    @tax = []
    operation_taxes = []
    
    @transaction_history.each_with_index do |transaction, index|
      if transaction.operation == "buy"
        operation_taxes << {
          tax: 0.0
        }
      else
        gross_profit = transaction.quantity * (transaction.unit_cost - weighted_average_price(index))
  
        if gross_profit < 0.0
          @accumulated_loss += gross_profit
          operation_taxes << {
          tax: 0.0
        }
          next
        end
  
        total_operation_value = transaction.quantity * transaction.unit_cost
        if total_operation_value < 20000.0 
          operation_taxes << {
            tax: 0.0
          }
        end

        # Calcula o lucro líquido
        net_profit = gross_profit - @accumulated_loss.abs

        @accumulated_loss = @accumulated_loss - (@accumulated_loss - net_profit)
    
        # Calcula os impostos da operação com base no lucro líquido
        if net_profit > 0.0 
          @accumulated_loss = 0.0
          operation_taxes << { tax: net_profit * 0.2 } if total_operation_value > 20000.0
        else
          operation_taxes << { tax: 0.0 }
        end
        
      end
     
    end

    @tax << operation_taxes
    @accumulated_loss = 0.0
  end

  private

  # Calcula o preço médio ponderado das ações
  def weighted_average_price(index)
    weighted_average = 0.0
    total_shares = 0.0

    @transaction_history.each_with_index do |transaction, transaction_index|
      next if transaction_index > index

      if transaction.operation == "buy"
        weighted_average = ((weighted_average * total_shares) + (transaction.unit_cost * transaction.quantity)) / (total_shares + transaction.quantity)
        total_shares += transaction.quantity
      end

      if transaction.operation == "sell"
        total_shares -= transaction.quantity
      end
    end

    weighted_average
  end
end