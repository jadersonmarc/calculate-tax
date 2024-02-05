require 'rspec'
require 'readline'
require 'json'
require '../app'
require 'rspec/mocks'


describe TransactionProcessor do
  let(:transactions_input) { %w[{"operation":"buy", "unit-cost":10.00, "quantity": 10000},{"operation":"sell", "unit-cost":20.00, "quantity": 6000}] }
  let(:sanatized_data) {["[{\"operation\":\"buy\", \"unit-cost\":10.00, \"quantity\": 10000},{\"operation\":\"sell\", \"unit-cost\":20.00, \"quantity\": 6000}]"]}
  subject(:processor) {  TransactionProcessor.new }

  describe '#input_data' do
  it 'reads transactions until an empty line is entered' do
    allow(Readline).to receive(:readline).and_return('{"operation":"buy", "unit-cost":10.00, "quantity":100}', "\n")
    processor.input_data
    expect(processor).to receive(:sanatize_data)
    processor.input_data
  end
  end


  describe "#sanatize_data" do
    it "removes extra commas and isolates transaction lists" do
      processor.instance_variable_set(:@transactions, transactions_input)
      expect(processor.transactions).to eq(transactions_input)
    end
  end

  describe "#parse_data" do
    it "parses JSON transactions and creates Operation objects" do
      processor.instance_variable_set(:@transactions, sanatized_data)
      parsed_operations = processor.parse_data
      expect(parsed_operations).to all(be_an(Array))
      expect(parsed_operations.flatten).to all(be_an(Operation))
    end
  end

  describe "#calculate_taxes" do
    it "calculates taxes for each parsed transaction list" do
        parsed_operations = [[Operation.new({ "operation": "buy", "unit-cost": 10.00, "quantity": 10000 }, 0),
                            Operation.new({ "operation": "sell", "unit-cost": 20.00, "quantity": 60000 }, 0)]]

        stock_tax_double = instance_double(StockTax, calculate_taxes: nil, tax: [[{ tax: 0.00 }, { tax: 12000.00 }]])
        allow(stock_tax_double).to receive(:calculate_taxes)
        allow(StockTax).to receive(:new).and_return(stock_tax_double)

        processor = TransactionProcessor.new
        taxes = processor.calculate_taxes(parsed_operations)

        expect(taxes).to eq([[[{ tax: 0.00 }, { tax: 12000.00 }]]])
    end
  end

  describe "#format_response" do
  it "formats response when only one list contains taxes" do
    list_taxes = [[[{ tax: "0.00" }]]]
    expect(processor.format_response(list_taxes)).to eq([{ "tax": "0.00" }])
  end

  it "formats response when more than one list contains taxes" do
    list_taxes = [[[{ tax: "0.00" }]], [[{ tax: "20000.00" }]]]
    expect(processor.format_response(list_taxes)).to eq([[{ "tax": "0.00" }], [{ "tax": "20000.00" }]])
  end
end  
end

