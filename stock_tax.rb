class StockTax
  START_VALUE = 0.00
  MIN_OPERATION_VALUE = 20000.0
  TAX_PERCENT = 0.2

  attr_reader :transaction_history, :accumulated_loss, :tax

  def initialize(transaction_history)
    @transaction_history = transaction_history
    @accumulated_loss = START_VALUE
    @tax = []
  end

  def calculate_taxes
    @tax = []
    operation_taxes = []
    
    @transaction_history.each_with_index do |transaction, index|
      if transaction.operation == "buy"
        operation_taxes << {
          tax: format('%.2f', START_VALUE)
        }
      else
        gross_profit = transaction.quantity * (transaction.unit_cost - weighted_average_price(index))
  
        if gross_profit < START_VALUE
          @accumulated_loss += gross_profit
          operation_taxes << {
          tax: format('%.2f', START_VALUE)
        }
          next
        end
  
        total_operation_value = transaction.quantity * transaction.unit_cost

        if total_operation_value < MIN_OPERATION_VALUE 
          operation_taxes << {
            tax: format('%.2f', START_VALUE)
          }
        end

        net_profit = gross_profit - @accumulated_loss.abs

        # Update accumulated loss considering the deduction of the net profit
        @accumulated_loss = @accumulated_loss - (@accumulated_loss - net_profit)
    
        if net_profit > START_VALUE 
          @accumulated_loss = START_VALUE
          operation_taxes << { tax: format('%.2f',(net_profit * TAX_PERCENT)) } if total_operation_value > MIN_OPERATION_VALUE
        else
          operation_taxes << { tax: format('%.2f', START_VALUE) } 
        end
        
      end
     
    end

    @tax << operation_taxes
    @accumulated_loss = START_VALUE
  end

  private

  def weighted_average_price(index)
    weighted_average = START_VALUE
    total_shares = START_VALUE

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