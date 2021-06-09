class SMSNotReceivedDialogPositiveListener < DialogOnClickListener
	attr_accessor :activity
	def onClick(dialog, which)
		Android::Widget::Toast.makeText(activity.getContext,"Sending another SMS",Android::Widget::Toast::LENGTH_SHORT).show
	end
end