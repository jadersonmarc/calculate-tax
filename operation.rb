class Operation
    attr_reader :operation, :unit_cost, :quantity, :list_index
  
    def initialize(operation_data, list_index)
      @operation = operation_data["operation"]
      @unit_cost = operation_data["unit-cost"].to_f.round(2)
      @quantity = operation_data["quantity"].to_i
      @list_index = list_index
    end
  end
  