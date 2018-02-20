module ApplicationHelper
	def gravatar_url(user, size)
		if !!user
			email_address = user.email
			gravatar = Digest::MD5::hexdigest(email_address).downcase 
			url = "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
		else
			default_url = "http://www.gravatar.com/avatar/?d=identicon"
		end
	end

	def bootstrap_class_for flash_type
		{   success: "alert-success",
			error: "alert-danger", 
			alert: "alert-warning", 
			notice: "alert-info" 
		}[flash_type.to_sym] 
	end

	def flash_messages(opts = {})
		flash.each do |msg_type, message|
			concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
				concat content_tag(:button, 'x', class: "close", data: {dismiss: 'alert'})
				concat message
			end)
		end
		nil
	end
end
