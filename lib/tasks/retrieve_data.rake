namespace :retrieve_data do
  desc "retrieves info"
  task :start_new_database_for_2014 => [:get_bill_headers, :add_senate_bill_headers, :get_bill_voting_sessions, :get_california_assembly_members_current_year, :get_california_senators,:calculate_voting_relationships_and_store, :add_district_data] do
  end
  task get_bill_headers: :environment do
    AssemblyBillHeader.where(:year => "2014").destroy
    CaliforniaWebCrawler.refreshAvailableBillsForYear("2014", "assembly")
  end

  task :get_bill_headers_for_year, [:year] => :environment do |t, args|
    year = args[:year] || "2014"
    AssemblyBillHeader.where(:year => "2014").destroy
    CaliforniaWebCrawler.refreshAvailableBillsForYear("2015", "assembly")
    CaliforniaWebCrawler.refreshAvailableBillsForYear("2015", "senate")
  end

  task :get_bill_voting_sessions_for_year, [:year] => :environment do |t, args|
    year = args[:year] || "2014"
    Bill.where(:year => year).destroy
    bills = AssemblyBillHeader.where(:year => year).each do |bill|
      puts "storing bill #{bill.billType}-#{bill.billNumber}"
      CaliforniaWebCrawler.storeVotingHistoriesFor(bill)
      puts "~stored~ #{bill.billType}-#{bill.billNumber}"
    end
  end
  task :calculate_voting_relationships_and_store_for_year, [:year] => :environment do |t, args|
    year = args[:year] || "2014"
    Legislator.all.each do |legislator|
      if(VotingRecord.where(:legislator => legislator).where(:year => year).count === 0)
        puts "now saving for legislator: #{legislator.first_name} #{legislator.last_name}"
        CaliforniaLegislatureVoteTallier.saveVotesFor(legislator, year)
      end
    end
  end

  task add_senate_bill_headers: :environment do
    CaliforniaWebCrawler.refreshAvailableBillsForYear("2014", "senate")
  end

  task get_bill_voting_sessions: :environment do
    Bill.all.destroy
    bills = AssemblyBillHeader.all.each do |bill|
      puts "storing bill #{bill.billType}-#{bill.billNumber}"
      CaliforniaWebCrawler.storeVotingHistoriesFor(bill)
      puts "~stored~ #{bill.billType}-#{bill.billNumber}"
    end
  end

  task get_california_assembly_members_current_year: :environment do
    CaliforniaAssemblyLegislatureScraper.getCaliforniaAssembly().map {|legislator|
    other = Legislator.where(:first_name => legislator.first_name).where(:last_name => legislator.last_name).where(:middle_name => legislator.middle_name)
    if(other.count == 0)
      legislator.save!
    end
    }
end

  task get_california_senators: :environment do
    CaliforniaSenatorScraper.getCaliforniaSenators().map {|legislator|
      other = Legislator.where(:first_name => legislator.first_name).where(:last_name => legislator.last_name).where(:middle_name => legislator.middle_name)
      if(other.count == 0)
        legislator.save!
      end
    }
    CaliforniaSenatorLegislatureScraper.get_california_legislators().map{|legislator|
      other = Legislator.where(:first_name => legislator.first_name).where(:last_name =>legislator.last_name)
      if(other.count == 0)
        legislator.save!
      else
        legislatorToUpdate = other.first
        legislatorToUpdate.first_name = legislator.first_name
        legislatorToUpdate.last_name = legislator.last_name
        legislatorToUpdate.party = legislator.party
        legislatorToUpdate.district = legislator.district
        legislatorToUpdate.save!
      end
    }
  end

  task calculate_voting_relationships_and_store: :environment do
    Legislator.all.each do |legislator|
      if(VotingRecord.where(:legislator => legislator).count === 0)
        puts "now saving for legislator: #{legislator.first_name} #{legislator.last_name}"
        CaliforniaLegislatureVoteTallier.saveVotesFor(legislator)
      end
    end
  end

  task delete_voting_relationships_data: :environment do
    VotingRecord.all.destroy
  end

  task add_district_data: :environment do
    zipCodes = CaliforniaZipCodeCalculator.calculateZipCodesGiven("lib/tasks/Final CD 2013 Zip Codes.csv")
    zipCodes = zipCodes.map{|zipCode|
      zipCode.year = "2014"
      zipCode.save!
    }

  end

end
