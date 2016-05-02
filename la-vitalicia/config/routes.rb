Rails.application.routes.draw do
  
 

  get 'home/index'

  root 'home#index' 


  namespace :intermediary do
  	 resources :renewals do
  	 	collection do
  	 		get 'prerenew'  
  	 		get 'get_policy_plans'	 
        get 'get_coverags_by_plan'
        get 'prerenew_by_policy'
        get 'renewal'	
        get 'get_not_renewal_policy'	
        get 'print_report_policy'  
  	 	end	
  	 end	
  end	

  namespace :provider do
      
      #insurabilities
      get 'insurabilities' => 'insurabilities#index' 
      get 'insurabilities/index'  
      get 'insurabilities/show_insured'
      get 'insurabilities/show_modal_ticket_request'
      get 'insurabilities/create_ticket'
      get 'insurabilities/list_recent_tickets'
      get 'insurabilities/cancel_request'

      #medicaments  
      get 'medicaments/index' 
      get 'medicaments' => 'medicaments#index'
      get 'medicaments/show_insured'
      get 'medicaments/request_medicament'
      get 'medicaments/request_medicament_item'
      post 'medicaments/create_medicament_item'
      get 'medicaments/delete_medicament_item'
      get 'medicaments/edit_medicament_item'
      post 'medicaments/update_medicament_item'
      get 'medicaments/confirm_medicament_request'
      get 'medicaments/request_history' 
      get 'medicaments/request_history_detail'
           
  end

  namespace :api do
    namespace :v1 do
      resources :medicaments
    end 
  end

end
