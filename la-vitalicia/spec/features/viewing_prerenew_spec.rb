require 'spec_helper'
require 'capybara/rspec'

feature "Viewing policies pre renew" do
	before do
		#validate token from outside app
		visit '/intermediary/renewals/prerenew?t=3a83da44-9761-40fa-aae8-cb318fa68298'
		message = "Jimmy Antiquez"
  		expect(page).to have_content(message)  		
	end	

	scenario "Listing all policies for pre renew" do
		
		#expect a policyholder name from Oracle Acsel DATA	
		expect(page).to have_content("Roberto Sanchez")

		#Expect a pilcy number from same row
		expect(page).to have_content("0000031")

		#NOT expect this policyholder from Oracle Acsel DATA	
        expect(page).to_not have_content("Carlos Perez")

        #puts page.body
        #expect click in a print button for this row	 
        #<a href="/">Imprimir</a>

	    first(:link, 'Imprimir').click

	    #return to testing page
	    visit '/intermediary/renewals/prerenew?t=3a83da44-9761-40fa-aae8-cb318fa68298'

        #expect click in a plans button for this row       
        first(:link, 'Planes').click
        

        #return to testing page
	    visit '/intermediary/renewals/prerenew?t=3a83da44-9761-40fa-aae8-cb318fa68298'

        #expect table has 2 rows from a table with ID=mainPolicies        
		within('table#mainPolicies') do
		 expect(page).to have_xpath(".//tr", :count => 2)
		end 


	end 
end