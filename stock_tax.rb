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
  
    @transaction_history.each_with_index do |transaction, index|
      operation_taxes = calculate_taxes_for_transaction(transaction, index)
      @tax << operation_taxes
    end
  
    @accumulated_loss = START_VALUE
  end
  
  def calculate_taxes_for_transaction(transaction, index)
    operation_taxes = []
  
    if transaction.operation == "buy"
      operation_taxes << { tax: format_zero_tax }
    else
      gross_profit = calculate_gross_profit(transaction, index)
  
      if gross_profit < START_VALUE
        accumulate_loss(gross_profit)
        operation_taxes << { tax: format_zero_tax }
      else
        total_operation_value = transaction.quantity * transaction.unit_cost

        if total_operation_value < MIN_OPERATION_VALUE
          operation_taxes << { tax: format_zero_tax }
        else
          net_profit = calculate_net_profit(gross_profit)
          update_accumulated(net_profit)

          if net_profit > START_VALUE
            operation_taxes << { tax: format_tax(net_profit) }
            reset_accumulated_loss
          else
            operation_taxes << { tax: format_zero_tax }
          end
        end
      end
    end
  
    operation_taxes
  end
  
  def calculate_gross_profit(transaction, index)
    transaction.quantity * (transaction.unit_cost - weighted_average_price(index))
  end
  
  def calculate_net_profit(gross_profit)
    gross_profit - @accumulated_loss.abs
  end
  
  def accumulate_loss(loss)
    @accumulated_loss += loss
  end

  def update_accumulated(net_profit)
    @accumulated_loss = @accumulated_loss - (@accumulated_loss - net_profit)
  end 
  
  def reset_accumulated_loss
    @accumulated_loss = START_VALUE
  end
  
  def format_zero_tax
    format('%.2f', START_VALUE)
  end
  
  def format_tax(tax_amount)
    format('%.2f', tax_amount * TAX_PERCENT)
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