collection @unread_stories, :root => "stories"
attributes :id, :title, :permalink, :body, :published
child(:feed) { attributes :name, :url }
