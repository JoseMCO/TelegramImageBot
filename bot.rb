require 'net/http/post/multipart'
require 'open-uri'
require 'telegram/bot'


token = File.read('./botToken').strip

Telegram::Bot::Client.run(token) do |bot|
	bot.listen do |message|
		if message.photo && message.photo.last
			puts 'incomming photo'
			# bot.api.send_message(chat_id: message.chat.id, text: "incomming photo")

			photo = message.photo.last
			# puts "id: #{photo.file_id}, size: #{photo.width}x#{photo.height}"
			# bot.api.send_message(chat_id: message.chat.id, text: "id: #{photo.file_id}, size: #{photo.width}x#{photo.height}")

			file = bot.api.getFile(file_id: photo.file_id)

			if file['ok']
				file_path = file['result']['file_path']

				File.open('./image.jpg', 'wb') do |fo|
				  fo.write open("https://api.telegram.org/file/bot#{token}/#{file_path}").read
				end
				params = {
					"MAX_FILE_SIZE" => 3145728,
					"upload" => 1,
					"uploadedfile" => UploadIO.new(File.new("./image.jpg"), "image/jpeg", "image.jpg"),
					"expire" => 3,
					"x" => 129,
					"y" => 19
				}

				url = URI.parse('http://uploadpie.com/')

				req = Net::HTTP::Post::Multipart.new(url.path, params)

				res = Net::HTTP.start(url.host, url.port) do |http|
					http.request(req)
				end
				html = res.body.delete! '\\"'
				imgURL = /id=uploaded value=([^\s]+)/.match(html)[1]
				bot.api.send_message(chat_id: message.chat.id, text: imgURL)
			end
		end
		case message.text
		when '/hi'
			bot.api.send_message(chat_id: message.chat.id, text: "Hello World!")
		end
	end
end
