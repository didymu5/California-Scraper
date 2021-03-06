require "rails_helper"

RSpec.describe CaliforniaLegislatureVoteTallier, :type => :model do
  let!(:legislator1) {Legislator.create(first_name: "Laura", last_name:"Cruz")}
  let!(:legislator2) {Legislator.create(first_name: "Laura", last_name:"Perry")}
  let!(:legislator3) {Legislator.create(first_name: "Bob", last_name:"Dole")}
  let!(:votingSession1) {VotingSession.new(ayes: ["Laura Cruz", "Dole"], location: "Sen. FLOOR",date: Date.parse('2001-02-03'))}
  let!(:votingSession2) {VotingSession.new(ayes: ["Dole"], noes: ["Laura Perry"], location: "Asm. FLOOR", date: Date.parse('2001-02-03'))}
  let!(:votingSession3) {VotingSession.new(ayes: ["Laura Norris", "Dole"], noes: [], location: "Asm. COMMITTEE")}
  let!(:bill) { Bill.create(billNumber:"1", billType:"AB", year:"2014", votingSessions: [votingSession1])}
  let!(:bill2) { Bill.create(billNumber:"1", billType:"SB", year:"2014", votingSessions: [votingSession2])}
  let!(:bill3) { Bill.create(billNumber:"22", billType:"AB", year:"2014", votingSessions: [votingSession3])}
  let!(:bill4) { Bill.create(billNumber:"22", billType:"AB", year:"2013", votingSessions: [votingSession1])}


  it "should assign votes based off legislator" do
    votes = CaliforniaLegislatureVoteTallier.getVotesFor(legislator1)
    expect(votes["yes"].length).to eq(1)
    expect(votes["no"].length).to eq(0)
    expect(votes["yes"][0].legislator).to eq(legislator1)
  end

  it "should assign multiple votes when legislator has been in commitee and senate" do
    votingSessionSenateFloor = VotingSession.new(ayes: ["Laura Cruz", "Dole"], location: "Sen. Committee")
    Bill.create(billNumber: bill.billNumber, year:"2014", billType: bill.billType, votingSessions: [votingSessionSenateFloor])
    votes = CaliforniaLegislatureVoteTallier.getVotesFor(legislator1)
    expect(votes["yes"].length).to eq(2)
  end

  it "should save votes to db " do
    CaliforniaLegislatureVoteTallier.saveVotesFor(legislator1)
    expect(VotingRecord.count).to eq(1)
    firstVotingRecord = VotingRecord.first
    expect(firstVotingRecord.legislator).to eq(legislator1)
    expect(firstVotingRecord.vote).to eq("ayes")
    expect(firstVotingRecord.bill_number).to eq("1")
    expect(firstVotingRecord.bill_type).to eq("AB")
    expect(firstVotingRecord.bill_identity).to eq("AB1")
    expect(firstVotingRecord.year).to eq("2014")
    expect(firstVotingRecord.voting_location).to eq("Sen. FLOOR")
    expect(firstVotingRecord.date).to eq(Date.parse('2001-02-03'))
  end
end
