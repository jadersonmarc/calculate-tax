class Operation
    attr_reader :operation, :unit_cost, :quantity
  
    def initialize(operation_data)
      @operation = operation_data["operation"]
  
      @unit_cost = operation_data["unit-cost"].to_f
  
      @quantity = operation_data["quantity"].to_i
    end
  end