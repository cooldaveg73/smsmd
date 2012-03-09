Mh::Application.routes.draw do 

  get "new_project/grant"
  get "new_project/new"
  post "new_project/create"
  get "new_project/confirm_email"
  get "new_project/setup1"

  match "/reporting", 	:to => "reporting#new"
  match "/datadive",    :to => "datadive#overview"

  match "/logout", 		:to => "sessions#destroy"
  get "/login", 		:to => "sessions#new"
  post "/login", 		:to => "sessions#create"
  match "/pick_project", 	:to => "sessions#pick_project"
  match "/sessions/project", 	:to => "sessions#project"

  match "/demo/new",			:to => "demo#new"
  match "/handle_demoer",		:to => "demo#new"
  match "/demo",			:to => "demo#setup"
  post "/demo/submit_doctors",		:to => "demo#submit_doctors"
  post "/demo/submit_vhds",		:to => "demo#submit_vhds"
  post "/demo/submit_receivers",	:to => "demo#submit_receivers"
  match "/demo/destroy",		:to => "demo#destroy"

  get "project/settings"
  get "new_project", 		:to => "project#new_project"
  match "page_doctors",		:to => "project#page_doctors"
  match "create_project", 	:to => "project#create_project"
  match "/project/update", 	:to => "project#update"
  match "/project/create", 	:to => "project#create"
  match "/project/settings",	:to => "project#settings"
  match "/project/new", 	:to => "project#new"
  match "/project/edit", 	:to => "project#edit"
  match "/project/destroy", 	:to => "project#destroy"
  match "/project/deactivate",  :to => "project#deactivate"
  match "/project/activate",    :to => "project#activate"
  match "/project/manage_patient_vhds", :to => "project#manage_patient_vhds"

  get "cases/main"
  get "cases/report"
  match "/cases/mark_fake", 	:to => "cases#mark_fake"

  # These routes don't require authentication
  match "/message_delivery_status", 	:to => "messages#delivery_status"
  match "/healthbeta/sms", 		:to => "messages#sms_responder"
  match "/message/send", 		:to =>"messages#send_sms"

  # These routes are only for people who are logged in
  match "/report",	:to => "cases#report"
  match "/cases",	:to => "cases#cases"
  match "/messages",	:to => "messages#messages"

  # Follow up
  match "/followup/options",   :to => "followup#options"
  match "/followup/results",   :to => "followup#results"
  match "/followup/form",      :to => "followup#form"
  match "/followup/success",   :to => "followup#success"

  # These routes are only for admins
  resources :users, 		:except => [:destroy]
  match "/users/destroy/:id", 	:to => "users#destroy"
  
  # By default, try to route to cases#main. This might 
  # get caught by the sessions controller, which will make you log in,
  # but that"s okay
  root :to => "cases#main"
end
