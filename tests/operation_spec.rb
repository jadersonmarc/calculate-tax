require 'rspec'
require_relative '../operation'  

describe Operation do
  # Teste a inicialização com dados válidos
  context "when initialized with valid data" do
    let(:operation_data) { { "operation" => "buy", "unit-cost" => "10.50", "quantity" => 20 } }
    let(:list_index) { 1 }
    subject(:operation) { Operation.new(operation_data, list_index) }

    it "assigns the correct values to attributes" do
      expect(operation.operation).to eq("buy")
      expect(operation.unit_cost).to eq(10.50)
      expect(operation.quantity).to eq(20)
      expect(operation.list_index).to eq(1)
    end
  end

end