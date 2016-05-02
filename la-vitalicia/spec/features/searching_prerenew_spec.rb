feature "Searching policies" do
	scenario "Searching a policy" do
		
		visit '/intermediary/renewals/prerenew?t=3a83da44-9761-40fa-aae8-cb318fa68298'		

		fill_in "search", with: "Juan Perez"		
		click_button "Búsqueda"
		
		expect(page).to have_content("Juan Perez")

	end
end