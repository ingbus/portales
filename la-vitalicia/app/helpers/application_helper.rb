module ApplicationHelper
	def active_class_menu(pcontroller_name)

		controller_name == pcontroller_name ? "active" : ""

 	end
end
