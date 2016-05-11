require 'rspec'
require_relative '../lib/visitor/numbering_visitor'


describe 'utility' do
  it 'should find right-most 1-bit' do
    bu = BitUtil.new
    (0..63).each do |n|
      expect(bu.rightBit(2**n)).to eq (n+1)
    end
    expect(bu.rightBit(65)).to eq (1)
    expect(bu.rightBit(66)).to eq (2)
  end

  it 'should find left-most 1-bit' do
    bu = BitUtil.new
    (0..63).each do |n|
      expect(bu.leftBit(2**n)).to eq (n+1)
    end
    expect(bu.leftBit(65)).to eq (7)
    expect(bu.leftBit(66)).to eq (7)
    expect(bu.leftBit(129)).to eq (8)
    expect(bu.leftBit(280)).to eq (9)
  end

  it 'finds bit common to two values greater than or equal to a given value' do
    bu = BitUtil.new
    expect(bu.bitGreaterThanOrEqualTo(1, 1, 1)).to eq 1
    expect(bu.bitGreaterThanOrEqualTo(1, 2, 2)).to eq 2
    expect(bu.bitGreaterThanOrEqualTo(1, 3, 3)).to eq 1
    expect(bu.bitGreaterThanOrEqualTo(1, 4, 4)).to eq 3
    expect(bu.bitGreaterThanOrEqualTo(1, 8, 8)).to eq 4
    expect(bu.bitGreaterThanOrEqualTo(1, 7, 6)).to eq 2
    expect(bu.bitGreaterThanOrEqualTo(2, 5, 6)).to eq 3
    expect(bu.bitGreaterThanOrEqualTo(10, 1024+2048, 2049)).to eq 12
  end

  it 'finds left most bit to right of a given bit' do
    bu = BitUtil.new
    expect(bu.leftMostBitToRightOf(2, 1)).to eq 1
    expect(bu.leftMostBitToRightOf(4, 1)).to eq 1
    expect(bu.leftMostBitToRightOf(8, 3)).to eq 2
    expect(bu.leftMostBitToRightOf(8, 15)).to eq 4
    expect(bu.leftMostBitToRightOf(8, 22)).to eq 5
    expect(bu.leftMostBitToRightOf(8, 33)).to eq 6
  end
end
